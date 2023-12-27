//
//  RecordViewController.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/7/23.
//

import UIKit
import Alamofire


// TAB2. 기록 게시물 업로드(추가) 화면
class BoardViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    var boardId: Int?
    
    //init data
    var categorie = ""
    var emotion = ""
    var factor = ""
    var satisfaction = ""
    var content = ""
    
    @IBOutlet weak var objectImageView: UIImageView!
    
    @IBOutlet weak var tagListView1: UIView!
    @IBOutlet weak var tagListView2: UIView!
    @IBOutlet weak var tagListView3: UIView!
    @IBOutlet weak var tagListView4: UIView!
    
    @IBOutlet weak var tagListViewHeight1: NSLayoutConstraint!
    @IBOutlet weak var tagListViewHeight2: NSLayoutConstraint!
    @IBOutlet weak var tagListViewHeight3: NSLayoutConstraint!
    @IBOutlet weak var tagListViewHeight4: NSLayoutConstraint!
    
    @IBOutlet weak var goalLabel: UILabel!{
        didSet{
            goalLabel.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet weak var recordTextView: UITextView!{
        didSet{
            recordTextView.text = textViewPlaceHolder
            recordTextView.textColor = .lightGray
        }
    }
    
    let textViewPlaceHolder = "이 물건만의 매력 포인트나 구매 동기 등을 적어보세요!"
    func textViewDidEndEditing(_ textView: UITextView) {
        if recordTextView.text.isEmpty {
            recordTextView.text = textViewPlaceHolder
            recordTextView.textColor = .lightGray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if recordTextView.textColor == .lightGray {
            recordTextView.text = nil // 텍스트를 날려줌
            recordTextView.textColor = .black
        }
    }
    var selectedImg = UIImage()
    var tagButtonArray = [UIButton]()
    var Picker = UIImagePickerController()
    // 갤러리 이미지 선택시 실행되는 메소드
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //선택한 이미지 처리
            //1. imageView로 보여주기
            let resizedImage = resizeImage(image: image, newWidth: 300)
            self.selectedImg = resizedImage
            
            DispatchQueue.main.async {
                self.objectImageView.image = self.selectedImg
                self.objectImageView.contentMode = .scaleAspectFill
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width // 새 이미지 확대/축소 비율
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.draw(in: CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    // 키보드 올라갔다는 알림을 받으면 실행되는 메서드
    @objc func keyboardWillShow(_ sender:Notification){
        self.view.frame.origin.y = -265
    }
    // 키보드 내려갔다는 알림을 받으면 실행되는 메서드
    @objc func keyboardWillHide(_ sender:Notification){
        self.view.frame.origin.y = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private lazy var tagCollectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        //tag 위아래
        layout.minimumLineSpacing = 5
        //tag 좌우
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        recordTextView.delegate = self
        
        //collection view test
        tagCollectionView.delegate = self
        tagCollectionView.dataSource = self
        tagCollectionView.register(TagCell.self, forCellWithReuseIdentifier: TagCell.identifier)
        tagListView1.addSubview(tagCollectionView)
        
        NSLayoutConstraint.activate([
            tagCollectionView.leadingAnchor.constraint(equalTo: tagListView1.leadingAnchor),
            tagCollectionView.trailingAnchor.constraint(equalTo: tagListView1.trailingAnchor),
            tagCollectionView.topAnchor.constraint(equalTo: tagListView1.safeAreaLayoutGuide.topAnchor),
            tagCollectionView.bottomAnchor.constraint(equalTo: tagListView2.safeAreaLayoutGuide.topAnchor, constant: 500)
        ])

        
        //button list view
        initTagViews()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        objectImageView.isUserInteractionEnabled = true
        objectImageView.addGestureRecognizer(tapGestureRecognizer)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
    }
    
    /// 태그뷰 초기화
    private func initTagViews() {
        initTagView(tagListView: tagListView2,
                    tagListViewHeight: tagListViewHeight2,
                    tagList: Tags.TagList2 ,
                    viewTag:2)
        
        initTagView(tagListView: tagListView3,
                    tagListViewHeight: tagListViewHeight3,
                    tagList: Tags.TagList3 ,
                    viewTag:3)
        
        initTagView(tagListView: tagListView4,
                    tagListViewHeight: tagListViewHeight4,
                    tagList: Tags.TagList4 ,
                    viewTag:4)
    }
    
    private func initTagView(tagListView: UIView,
                             tagListViewHeight: NSLayoutConstraint,
                             tagList: [String],
                             viewTag:Int) {
        // 태그버튼들 생성
        var tagStringArray = [String]()
        for i in tagList {
            tagStringArray.append(i)
        }
        
        tagButtonArray = tagStringArray.map { createButton(with: $0) }
        let frame = CGRect(x: 0, y: 0, width: tagListView.frame.width, height: tagListView.frame.height)
        let tagView = UIView(frame: frame)
        attachTagButtons(at: tagView, tagButtonArray)
        
        // addSubview
        tagListView.addSubview(tagView)
        tagListView.viewWithTag(viewTag)
        tagListViewHeight.constant = tagListView.frame.height
    }
    
    
    /// 기록 게시물 작성 페이지 VC
    ///     /// 작성한 기록 서버 전송 api
    @IBAction func sendRecordToServer(_ sender: Any) {
        content = recordTextView.text
        let recordParam: Parameters = ["contents": content,
                                       "emotions": emotion,
                                       "satisfactions": satisfaction,
                                       "factors": factor,
                                       "categories": categorie]
        if let imgData = self.objectImageView.image {
            APIService.shared.fileUpload(imageData: imgData, completion: { postNumber in
                var alert = UIAlertController()
                alert = UIAlertController(title:"소비기록이 저장됐어요!",
                                          message: "",
                                          preferredStyle: UIAlertController.Style.alert)
                self.present(alert,animated: true,completion: nil)
                let buttonLabel = UIAlertAction(title: "확인", style: .default, handler: {_ in
                    self.dismiss(animated:true, completion: nil)
                    UIViewController.changeRootViewControllerToHome()
                })
                alert.addAction(buttonLabel)
            })
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        showActionSheet()
    }
    
    /// 이미지 변경 버튼 클릭시 생성되는 action sheet
    func showActionSheet() {
        
        // 액션 시트 초기화
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // UIAlertAction 설정
        // handler : 액션 발생시 호출
        let actionAlbum = UIAlertAction(title: "앨범에서 선택할래요", style: .default, handler: {(alert:UIAlertAction!) -> Void in
            self.openGallery()
        })
        let actionCamera = UIAlertAction(title: "사진 찍을래요", style: .default, handler: {(alert:UIAlertAction!) -> Void in
            self.openCamera()
        })
        
        let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        actionSheet.addAction(actionCamera)
        actionSheet.addAction(actionAlbum)
        actionSheet.addAction(actionCancel)
        
        self.present(actionSheet, animated: true)
    }
    /// actionsheet1. 카메라 촬영
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            self.Picker.sourceType = UIImagePickerController.SourceType.camera;
            self .present(self.Picker, animated: true, completion: nil)
            self.Picker.allowsEditing = false
            self.Picker.delegate = self
        }
    }
    
    @IBOutlet weak var saveBtn: UIButton!{
        didSet{
            saveBtn.layer.cornerRadius = 15
        }
    }
    /// actionsheet2. 앨범에서 가져오기
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum){
            self.Picker.sourceType = UIImagePickerController.SourceType.photoLibrary;
            self.Picker.allowsEditing = false
            self.Picker.delegate = self
            self.present(self.Picker, animated: true, completion: nil)
        }
    }
    
    private func createButton(with title: String) -> CustomButton {
        let font = UIFont.systemFont(ofSize: 15)
        let fontAttributes: [NSAttributedString.Key: Any] = [.font: font]
        let fontSize = title.size(withAttributes: fontAttributes)
        
        let tag = CustomButton(type: .custom)
        
        tag.setTitle(title, for: .normal)
        tag.titleLabel?.font = font
        tag.setTitleColor(.lightGray, for: .normal)
        tag.layer.cornerRadius = 14
        tag.layer.backgroundColor = UIColor.white.cgColor
        
        tag.frame = CGRect(x: 0.0, y: 0.0, width: fontSize.width + 30.0, height: fontSize.height + 13.0)
        tag.contentEdgeInsets = UIEdgeInsets(top: 6.5, left: 15, bottom: 6.5, right: 15)
        
        return tag
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        recordTextView.resignFirstResponder() // TextField 비활성화
        return true
    }
    
    class CustomButton:UIButton {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            configeBtn()
        }
        var isClicked = false
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            configeBtn()
        }
        
        func configeBtn() {
            self.addTarget(self, action: #selector(btnClicked(_:)), for: .touchUpInside)
        }
        
        @objc func btnClicked (_ sender:UIButton) {
            if let tagTitle = sender.titleLabel?.text{
                print(tagTitle)
            }
            if sender.isSelected {
                sender.backgroundColor = .white
                sender.setTitleColor(.lightGray, for: .normal)
                sender.isSelected = false
            }else{
                sender.backgroundColor = UIColor(hexCode: "343C19")
                sender.setTitleColor(UIColor(hexCode: "FCFDFC"), for: .normal)
                sender.isSelected = true
            }
        }
    }
    
    func searchCategory(buttonTitle: String) -> String {
        if Tags.TagList1.contains(buttonTitle){
            return "contents"
        }else if Tags.TagList1.contains(buttonTitle){
            return "emotions"
        }else if Tags.TagList1.contains(buttonTitle){
            return "factors"
        }else if Tags.TagList1.contains(buttonTitle){
            return "satisfactions"
        }
        return ""
    }
    
    func setBackgroundColor(btn: UIButton, color: UIColor) -> UIButton{
        btn.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            btn.setBackgroundImage(colorImage, for: .selected)
        }
        return btn
    }
    
    private func attachTagButtons(at view: UIView, _ tagButtons: [UIButton]) {
        var lineCount: CGFloat = 1
        let marginX: CGFloat = 5
        let marginY: CGFloat = 8
        
        var positionX: CGFloat = 0
        var positionY: CGFloat = 0
        
        for (index, tagButton) in tagButtons.enumerated() {
            tagButton.tag = index
            tagButton.frame = CGRect(x: positionX, y: positionY, width: tagButton.frame.width, height: tagButton.frame.height)
            view.addSubview(tagButton)
            
            if index < tagButtons.count - 1 {
                // 다음 태그버튼 좌표 설정
                positionX += tagButton.frame.width + marginX
                
                // 현재 줄에 공간이 부족해 다음 태그버튼이 붙을 수 없으면 다음 줄로 내리기
                if positionX + tagButtons[index + 1].frame.width > view.frame.width {
                    positionX = 0
                    positionY += tagButton.frame.height + marginY
                    lineCount += 1
                }
            }
        }
        
        // 태그뷰 높이 계산
        let height = view.subviews.first?.frame.height ?? 0
        let margins: CGFloat = (lineCount - 1) * marginY
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: (lineCount * height) + margins)
    }
}

extension BoardViewController: UICollectionViewDelegate , UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return Tags.TagList1.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.identifier, for: indexPath) as? TagCell else {
            return UICollectionViewCell()
        }
        
        cell.backgroundColor = .orange
        cell.tagLabel.text = Tags.TagList1[indexPath.row]
        

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCell {
            print(cell.tagLabel.text!)
        }
    }
}

extension BoardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let label: UILabel = {
            let customLabel = UILabel()
            customLabel.font = .systemFont(ofSize: 16)
            customLabel.text = Tags.TagList1[indexPath.item]
            customLabel.sizeToFit()
            return customLabel
        }()

        let size = label.frame.size
        return CGSize(width: size.width + 24, height: 40)
    }
}

extension UserDefaults {
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }
    
    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        self.set(data, forKey: key)
    }
}

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.representedElementCategory == .cell {
                if layoutAttribute.frame.origin.y >= maxY {
                    leftMargin = sectionInset.left
                }
                layoutAttribute.frame.origin.x = leftMargin
                leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
                maxY = max(layoutAttribute.frame.maxY, maxY)
            }
        }
        return attributes
    }
}
