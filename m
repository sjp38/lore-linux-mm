Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f44.google.com (mail-oa0-f44.google.com [209.85.219.44])
	by kanga.kvack.org (Postfix) with ESMTP id 097676B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 22:43:36 -0400 (EDT)
Received: by mail-oa0-f44.google.com with SMTP id o6so1256198oag.17
        for <linux-mm@kvack.org>; Thu, 29 May 2014 19:43:36 -0700 (PDT)
Received: from mail-oa0-x244.google.com (mail-oa0-x244.google.com [2607:f8b0:4003:c02::244])
        by mx.google.com with ESMTPS id pt2si4870394oeb.20.2014.05.29.19.43.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 May 2014 19:43:36 -0700 (PDT)
Received: by mail-oa0-f68.google.com with SMTP id i7so321804oag.7
        for <linux-mm@kvack.org>; Thu, 29 May 2014 19:43:36 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 30 May 2014 10:43:36 +0800
Message-ID: <CAGO-9mo8aSBABPMzik0_gekUu=E2nxHk8DK7He_kQvHEBaU8HA@mail.gmail.com>
Subject: Ask for help on the memory allocation for process shared mutex
From: yang ben <benyangfsl@gmail.com>
Content-Type: multipart/alternative; boundary=001a11c32b201bf03904fa950357
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org

--001a11c32b201bf03904fa950357
Content-Type: text/plain; charset=UTF-8

Dear experts,

I came across a memory/mutex issue. Would you kindly shed some light on it?

I use pthread_mutex_xxx API to protect processes in user space. Since it
should be process shared, I allocated a shared memory to
store pthread_mutex_t structure.

The shared memory is allocated using vmalloc_user() and mapped using
remap_vmalloc_range() in driver. However, get_futex_key() will always
return -EFAULT, because page_head->mapping==0.

futex.c (Linux-3.10.31)
         if (!page_head->mapping) {
                 int shmem_swizzled = PageSwapCache(page_head);
                 unlock_page(page_head);
                 put_page(page_head);
                 if (shmem_swizzled)
                         goto again;
                 return -EFAULT;
         }
Is there special requirement on the memory to store mutex? What's the
correct way to allocate such memory in driver?
Thanks in advance!

Regards,
Ben

--001a11c32b201bf03904fa950357
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: base64

PGRpdj5EZWFyIGV4cGVydHMsPC9kaXY+DQo8ZGl2PsKgPC9kaXY+DQo8ZGl2PknCoGNhbWUgYWNy
b3NzwqBhIG1lbW9yeS9tdXRleCBpc3N1ZS4gV291bGQgeW91IGtpbmRseSBzaGVkIHNvbWUgbGln
aHQgb24gaXQ/PC9kaXY+DQo8ZGl2PsKgPC9kaXY+DQo8ZGl2PkkgdXNlIHB0aHJlYWRfbXV0ZXhf
eHh4IEFQSSB0byBwcm90ZWN0IHByb2Nlc3NlcyBpbiB1c2VyIHNwYWNlLiBTaW5jZSBpdCBzaG91
bGQgYmUgcHJvY2VzcyBzaGFyZWQsIEnCoGFsbG9jYXRlZCBhIHNoYXJlZCBtZW1vcnkgdG8gc3Rv
cmXCoHB0aHJlYWRfbXV0ZXhfdCBzdHJ1Y3R1cmUuPC9kaXY+DQo8ZGl2PsKgPC9kaXY+DQo8ZGl2
PlRoZSBzaGFyZWQgbWVtb3J5IGlzIGFsbG9jYXRlZCB1c2luZyB2bWFsbG9jX3VzZXIoKSBhbmQg
bWFwcGVkIHVzaW5nIHJlbWFwX3ZtYWxsb2NfcmFuZ2UoKSBpbiBkcml2ZXIuIEhvd2V2ZXIsIGdl
dF9mdXRleF9rZXkoKSB3aWxsIGFsd2F5cyByZXR1cm4gLUVGQVVMVCwgYmVjYXVzZSBwYWdlX2hl
YWQtJmd0O21hcHBpbmc9PTAuPC9kaXY+DQo8ZGl2PsKgPC9kaXY+DQo8ZGl2PmZ1dGV4LmMgKExp
bnV4LTMuMTAuMzEpPC9kaXY+DQo8ZGl2PsKgwqDCoMKgwqDCoMKgwqAgaWYgKCFwYWdlX2hlYWQt
Jmd0O21hcHBpbmcpIHs8YnI+wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqAgaW50IHNo
bWVtX3N3aXp6bGVkID0gUGFnZVN3YXBDYWNoZShwYWdlX2hlYWQpOzxicj7CoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoCB1bmxvY2tfcGFnZShwYWdlX2hlYWQpOzxicj7CoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoCBwdXRfcGFnZShwYWdlX2hlYWQpOzxicj7CoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoCBpZiAoc2htZW1fc3dpenpsZWQpPGJyPg0KwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgIGdvdG8gYWdhaW47PGJyPsKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgIHJldHVybiAtRUZBVUxUOzxicj7CoMKgwqDC
oMKgwqDCoMKgIH08YnI+PC9kaXY+DQo8ZGl2PklzIHRoZXJlIHNwZWNpYWwgcmVxdWlyZW1lbnQg
b24gdGhlIG1lbW9yeSB0byBzdG9yZSBtdXRleD8gV2hhdCYjMzk7cyB0aGUgY29ycmVjdCB3YXkg
dG8gYWxsb2NhdGUgc3VjaCBtZW1vcnkgaW4gZHJpdmVyPzwvZGl2Pg0KPGRpdj5UaGFua3MgaW4g
YWR2YW5jZSE8L2Rpdj4NCjxkaXY+wqA8L2Rpdj4NCjxkaXY+UmVnYXJkcyw8L2Rpdj4NCjxkaXY+
QmVuPC9kaXY+DQo8ZGl2PsKgPC9kaXY+DQo=
--001a11c32b201bf03904fa950357--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
