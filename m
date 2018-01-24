Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 32AC5800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 13:42:48 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id r74so4900310iod.15
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 10:42:48 -0800 (PST)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id s204sor464519iod.326.2018.01.24.10.42.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jan 2018 10:42:47 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 24 Jan 2018 10:42:47 -0800
In-Reply-To: <CACT4Y+apdswWOB1XW6HsG+AUowVhozhO1ZeHDeCRBCkY8gkYfg@mail.gmail.com>
Message-ID: <001a113f932c939af705638a07fd@google.com>
Subject: possible deadlock in shmem_file_llseek
From: syzbot <syzbot+8ec30bb7bf1a981a2012@syzkaller.appspotmail.com>
Content-Type: multipart/mixed; boundary="001a113f932c939ac605638a07fc"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arve@android.com, devel@driverdev.osuosl.org, dvyukov@google.com, gregkh@linuxfoundation.org, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, maco@android.com, syzkaller-bugs@googlegroups.com, tkjos@android.com

--001a113f932c939ac605638a07fc
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes

Hello,

syzbot tried to test the proposed patch but build/boot failed:

patch is already applied


Tested on https://github.com/joelagnel/linux.git/test-ashmem commit
32f813bb0d06c1e189ac336f8c3c7377f85c71f0 (Wed Jan 24 01:45:04 2018 +0000)
ashmem: Fix lockdep issue during llseek

compiler: gcc (GCC) 7.1.1 20170620
Patch is attached.




--001a113f932c939ac605638a07fc
Content-Type: text/plain; charset="US-ASCII"; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64

LS0tIGEvZHJpdmVycy9zdGFnaW5nL2FuZHJvaWQvYXNobWVtLmMKKysrIGIvZHJpdmVycy9zdGFn
aW5nL2FuZHJvaWQvYXNobWVtLmMKQEAgLTM0Myw3ICszNDMsOSBAQCBzdGF0aWMgbG9mZl90IGFz
aG1lbV9sbHNlZWsoc3RydWN0IGZpbGUgKmZpbGUsIGxvZmZfdCBvZmZzZXQsIGludCBvcmlnaW4p
CiAJCWdvdG8gb3V0OwogCX0KIAorCW11dGV4X3VubG9jaygmYXNobWVtX211dGV4KTsKIAlyZXQg
PSB2ZnNfbGxzZWVrKGFzbWEtPmZpbGUsIG9mZnNldCwgb3JpZ2luKTsKKwltdXRleF9sb2NrKCZh
c2htZW1fbXV0ZXgpOwogCWlmIChyZXQgPCAwKQogCQlnb3RvIG91dDsKIAo=
--001a113f932c939ac605638a07fc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
