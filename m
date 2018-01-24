Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B547A800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 13:44:13 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id u65so3669566pfd.7
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 10:44:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k190sor1481860pfc.26.2018.01.24.10.44.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jan 2018 10:44:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <001a113f932c939af705638a07fd@google.com>
References: <CACT4Y+apdswWOB1XW6HsG+AUowVhozhO1ZeHDeCRBCkY8gkYfg@mail.gmail.com>
 <001a113f932c939af705638a07fd@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 24 Jan 2018 19:43:51 +0100
Message-ID: <CACT4Y+aRpitnB_0JFNAyLVzbZnGSx+vNCOig3XiLL7dV988XWw@mail.gmail.com>
Subject: Re: possible deadlock in shmem_file_llseek
Content-Type: multipart/mixed; boundary="001a1142a7e0a2b15905638a0c5c"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+8ec30bb7bf1a981a2012@syzkaller.appspotmail.com>
Cc: arve@android.com, devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, maco@android.com, syzkaller-bugs@googlegroups.com, tkjos@android.com

--001a1142a7e0a2b15905638a0c5c
Content-Type: text/plain; charset="UTF-8"

On Wed, Jan 24, 2018 at 7:42 PM, syzbot
<syzbot+8ec30bb7bf1a981a2012@syzkaller.appspotmail.com> wrote:
> Hello,
>
> syzbot tried to test the proposed patch but build/boot failed:
>
> patch is already applied
>
>
> Tested on https://github.com/joelagnel/linux.git/test-ashmem commit
> 32f813bb0d06c1e189ac336f8c3c7377f85c71f0 (Wed Jan 24 01:45:04 2018 +0000)
> ashmem: Fix lockdep issue during llseek
>
> compiler: gcc (GCC) 7.1.1 20170620
> Patch is attached.

Right. We probably want:

#syz test: git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
master

--001a1142a7e0a2b15905638a0c5c
Content-Type: application/octet-stream; name=patch
Content-Disposition: attachment; filename=patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_jctf46141

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvc3RhZ2luZy9hbmRyb2lkL2FzaG1lbS5jIGIvZHJpdmVycy9z
dGFnaW5nL2FuZHJvaWQvYXNobWVtLmMKaW5kZXggMGY2OTVkZjE0YzlkLi4yNDg5ODNjZjJkYjEg
MTAwNjQ0Ci0tLSBhL2RyaXZlcnMvc3RhZ2luZy9hbmRyb2lkL2FzaG1lbS5jCisrKyBiL2RyaXZl
cnMvc3RhZ2luZy9hbmRyb2lkL2FzaG1lbS5jCkBAIC0zNDMsNyArMzQzLDkgQEAgc3RhdGljIGxv
ZmZfdCBhc2htZW1fbGxzZWVrKHN0cnVjdCBmaWxlICpmaWxlLCBsb2ZmX3Qgb2Zmc2V0LCBpbnQg
b3JpZ2luKQogCQlnb3RvIG91dDsKIAl9CiAKKwltdXRleF91bmxvY2soJmFzaG1lbV9tdXRleCk7
CiAJcmV0ID0gdmZzX2xsc2Vlayhhc21hLT5maWxlLCBvZmZzZXQsIG9yaWdpbik7CisJbXV0ZXhf
bG9jaygmYXNobWVtX211dGV4KTsKIAlpZiAocmV0IDwgMCkKIAkJZ290byBvdXQ7CiAK
--001a1142a7e0a2b15905638a0c5c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
