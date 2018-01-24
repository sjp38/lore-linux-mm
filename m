Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 16532800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 13:40:33 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 205so3678542pfw.4
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 10:40:33 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a33-v6sor297148plc.12.2018.01.24.10.40.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jan 2018 10:40:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180124174723.25289-1-joelaf@google.com>
References: <001a1144d6e854b3c90562668d74@google.com> <20180124174723.25289-1-joelaf@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 24 Jan 2018 19:40:10 +0100
Message-ID: <CACT4Y+apdswWOB1XW6HsG+AUowVhozhO1ZeHDeCRBCkY8gkYfg@mail.gmail.com>
Subject: Re: possible deadlock in shmem_file_llseek
Content-Type: multipart/mixed; boundary="00000000000076eeab056389ff3e"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joelaf@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, syzbot <syzbot+8ec30bb7bf1a981a2012@syzkaller.appspotmail.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs@googlegroups.com

--00000000000076eeab056389ff3e
Content-Type: text/plain; charset="UTF-8"

On Wed, Jan 24, 2018 at 6:47 PM, Joel Fernandes <joelaf@google.com> wrote:
>
> #syz test: https://github.com/joelagnel/linux.git test-ashmem


Oops, this email somehow ended up without Content-Type header, which
was unexpected on syzbot side. Now should be fixed with:
https://github.com/google/syzkaller/commit/866f1102f786c19a67e3857f891eaf5107550663

Let's try again:

#syz test: https://github.com/joelagnel/linux.git test-ashmem

--00000000000076eeab056389ff3e
Content-Type: application/octet-stream; name=patch
Content-Disposition: attachment; filename=patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_jctez7qu0

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvc3RhZ2luZy9hbmRyb2lkL2FzaG1lbS5jIGIvZHJpdmVycy9z
dGFnaW5nL2FuZHJvaWQvYXNobWVtLmMKaW5kZXggMGY2OTVkZjE0YzlkLi4yNDg5ODNjZjJkYjEg
MTAwNjQ0Ci0tLSBhL2RyaXZlcnMvc3RhZ2luZy9hbmRyb2lkL2FzaG1lbS5jCisrKyBiL2RyaXZl
cnMvc3RhZ2luZy9hbmRyb2lkL2FzaG1lbS5jCkBAIC0zNDMsNyArMzQzLDkgQEAgc3RhdGljIGxv
ZmZfdCBhc2htZW1fbGxzZWVrKHN0cnVjdCBmaWxlICpmaWxlLCBsb2ZmX3Qgb2Zmc2V0LCBpbnQg
b3JpZ2luKQogCQlnb3RvIG91dDsKIAl9CiAKKwltdXRleF91bmxvY2soJmFzaG1lbV9tdXRleCk7
CiAJcmV0ID0gdmZzX2xsc2Vlayhhc21hLT5maWxlLCBvZmZzZXQsIG9yaWdpbik7CisJbXV0ZXhf
bG9jaygmYXNobWVtX211dGV4KTsKIAlpZiAocmV0IDwgMCkKIAkJZ290byBvdXQ7CiAK
--00000000000076eeab056389ff3e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
