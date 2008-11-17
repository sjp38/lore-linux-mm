Message-ID: <4921A706.9030501@redhat.com>
Date: Mon, 17 Nov 2008 12:16:54 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: [PATCH] vmscan: fix get_scan_ratio comment
References: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081115210039.537f59f5.akpm@linux-foundation.org> <alpine.LFD.2.00.0811161013270.3468@nehalem.linux-foundation.org> <49208E9A.5080801@redhat.com> <20081116204720.1b8cbe18.akpm@linux-foundation.org> <20081117153012.51ece88f.kamezawa.hiroyu@jp.fujitsu.com> <2f11576a0811162239w58555c6dq8a61ec184b22bd52@mail.gmail.com> <20081117155417.5cc63907.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.0811170802010.3468@nehalem.linux-foundation.org> <alpine.LFD.2.00.0811170830320.3468@nehalem.linux-foundation.org> <4921A1AF.1070909@redhat.com> <alpine.LFD.2.00.0811170904160.3468@nehalem.linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.0811170904160.3468@nehalem.linux-foundation.org>
Content-Type: multipart/mixed;
 boundary="------------070505020608090304010000"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Gene Heskett <gene.heskett@gmail.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070505020608090304010000
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit


--------------070505020608090304010000
Content-Type: text/plain;
 name="get-scan-ratio-comment.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="get-scan-ratio-comment.patch"

Rml4IHRoZSBvbGQgY29tbWVudCBvbiB0aGUgc2NhbiByYXRpbyBjYWxjdWxhdGlvbnMuCgpT
aWduZWQtb2ZmLWJ5OiBSaWsgdmFuIFJpZWwgPHJpZWxAcmVkaGF0LmNvbT4KLS0tCiBtbS92
bXNjYW4uYyB8ICAgIDYgKysrLS0tCiAxIGZpbGUgY2hhbmdlZCwgMyBpbnNlcnRpb25zKCsp
LCAzIGRlbGV0aW9ucygtKQoKSW5kZXg6IGxpbnV4LTIuNi4yOC1yYzUvbW0vdm1zY2FuLmMK
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PQotLS0gbGludXgtMi42LjI4LXJjNS5vcmlnL21tL3Ztc2Nhbi5jCTIw
MDgtMTEtMTYgMTc6NDc6MTMuMDAwMDAwMDAwIC0wNTAwCisrKyBsaW51eC0yLjYuMjgtcmM1
L21tL3Ztc2Nhbi5jCTIwMDgtMTEtMTcgMTI6MDU6MDMuMDAwMDAwMDAwIC0wNTAwCkBAIC0x
Mzg2LDkgKzEzODYsOSBAQCBzdGF0aWMgdm9pZCBnZXRfc2Nhbl9yYXRpbyhzdHJ1Y3Qgem9u
ZSAqCiAJZmlsZV9wcmlvID0gMjAwIC0gc2MtPnN3YXBwaW5lc3M7CiAKIAkvKgotCSAqICAg
ICAgICAgICAgICAgICAgYW5vbiAgICAgICByZWNlbnRfcm90YXRlZFswXQotCSAqICVhbm9u
ID0gMTAwICogLS0tLS0tLS0tLS0gLyAtLS0tLS0tLS0tLS0tLS0tLSAqIElPIGNvc3QKLQkg
KiAgICAgICAgICAgICAgIGFub24gKyBmaWxlICAgICAgcm90YXRlX3N1bQorCSAqICAgICAg
ICAgcmVjZW50X3NjYW5uZWRbYW5vbl0KKwkgKiAlYW5vbiA9IC0tLS0tLS0tLS0tLS0tLS0t
LS0tICogc2MtPnN3YXBwaW5lc3MKKwkgKiAgICAgICAgIHJlY2VudF9yb3RhdGVkW2Fub25d
CiAJICovCiAJYXAgPSAoYW5vbl9wcmlvICsgMSkgKiAoem9uZS0+cmVjZW50X3NjYW5uZWRb
MF0gKyAxKTsKIAlhcCAvPSB6b25lLT5yZWNlbnRfcm90YXRlZFswXSArIDE7Cg==
--------------070505020608090304010000--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
