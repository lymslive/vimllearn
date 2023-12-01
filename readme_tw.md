# VimL 語言編程指北 [[简](./readme.md)]

<a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/4.0/"><img alt="知識共享許可協議" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-nd/4.0/88x31.png" /></a>

本教程按技術書籍方式組織。書名叫“指北”而不是“指南”，主要是考慮有很多指南類書籍
講 vim 這編輯器工具的使用，而本書則側重于 VimL 這種腳本語言編程。

GitHub Page 在線閱讀：
[https://lymslive.github.io/vimllearn](https://lymslive.github.io/vimllearn)

PDF 格式書籍下載：
[vim-script-guide-book-zh-cn.pdf](p/vim-script-guide-book-zh-cn.pdf)
感謝 @[QMHTMY](https://github.com/QMHTMY) 編譯 pdf 版本及相關排版工作。

版權聲明：基于知識共享協議。允許自由擴散，以及援用部分段落解說與示例代碼。
但其他人不允許將整書或整章節用于商業性的出版或電子平台。

擁抱 github 開源社區。雖非軟件項目，但 issue/fork/pr 等功能亦可使用。
歡迎反饋意見或文字糾錯。源文件們于 `content/` 子目錄。

本書引用的代碼段示例都很短，按書照敲或複制也是壹種學習方式。 `example/` 目錄整
理了部分示例代碼，但是建議以書內講敘或外鏈接爲准。作者自己在 linux 系統下以
vim8.1 版本測試，Windows 與低版本雖未全面測試，但相信 vim 本身的兼容性也基本適
用了。

<hr>

## 變更記錄

初稿在本地我用自己的筆記插件 [vnote](https://github.com/lymslive/vnote) 寫的，
保存在筆記本 [notebook](https://github.com/lymslive/notebook)。然後將這個較爲
系統化的教程獨立出來，進行後續的修改與調整。而原 notebook 倉庫適合設爲私有。

初稿在 `z/` 子目錄，另有壹頁[目錄](./content.md) 。

後來，選了個靜態網站生成工具 [zola](https://github.com/getzola/zola) 編譯爲
html ，使用 gitbook 風格的主題，即 [book](https://www.getzola.org/themes/book/)。
此技術選型純屬個人口味，偏好 rust 而已。
因此將 `z/` 目錄下的初稿 `.md` 文件，重命名、重組放在 `content/` 目錄之下。
每個 `.md` 文件最前面加上了必要元數據頭（Front matter），刪除或注釋了重複的章
節標題。
