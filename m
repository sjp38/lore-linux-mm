Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 17D696B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 03:43:21 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so101165140pdb.3
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 00:43:20 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id k2si7521705pdj.249.2015.03.20.00.43.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 20 Mar 2015 00:43:19 -0700 (PDT)
Received: from epcpsbgx1.samsung.com
 (u161.gpu120.samsung.co.kr [203.254.230.161])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NLI005HU2S5QU00@mailout4.samsung.com> for linux-mm@kvack.org;
 Fri, 20 Mar 2015 16:43:17 +0900 (KST)
Date: Fri, 20 Mar 2015 07:43:16 +0000 (GMT)
From: Yinghao Xie <yinghao.xie@samsung.com>
Subject: [PATCH] mm/zsmalloc.c: fix comment for get_pages_per_zspage
Reply-to: yinghao.xie@samsung.com
MIME-version: 1.0
Content-transfer-encoding: base64
Content-type: text/plain; charset=utf-8
MIME-version: 1.0
Message-id: <444988883.44981426837395023.JavaMail.weblogic@epmlwas06d>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

U3VnZ2VzdGVkLWJ5OiBNaW5jaGFuIEtpbSA8bWluY2hhbkBrZXJuZWwub3JnPg0KU2lnbmVkLW9m
Zi1ieTogWWluZ2hhbyBYaWUgPHlpbmdoYW8ueGllQHN1bXN1bmcuY29tPg0KLS0tDQogbW0venNt
YWxsb2MuYyB8ICAgIDMgKystDQogMSBmaWxlIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwgMSBk
ZWxldGlvbigtKQ0KDQpkaWZmIC0tZ2l0IGEvbW0venNtYWxsb2MuYyBiL21tL3pzbWFsbG9jLmMN
CmluZGV4IDQ2MTI0M2UuLjNlNjEzY2MgMTAwNjQ0DQotLS0gYS9tbS96c21hbGxvYy5jDQorKysg
Yi9tbS96c21hbGxvYy5jDQpAQCAtNzYwLDcgKzc2MCw4IEBAIG91dDoNCiAgKiB0byBmb3JtIGEg
enNwYWdlIGZvciBlYWNoIHNpemUgY2xhc3MuIFRoaXMgaXMgaW1wb3J0YW50DQogICogdG8gcmVk
dWNlIHdhc3RhZ2UgZHVlIHRvIHVudXNhYmxlIHNwYWNlIGxlZnQgYXQgZW5kIG9mDQogICogZWFj
aCB6c3BhZ2Ugd2hpY2ggaXMgZ2l2ZW4gYXM6DQotICogICAgIHdhc3RhZ2UgPSBacCAtIFpwICUg
c2l6ZV9jbGFzcw0KKyAqICAgICB3YXN0YWdlID0gWnAgJSBjbGFzc19zaXplDQorICogICAgIHVz
YWdlID0gWnAgLSB3YXN0YWdlDQogICogd2hlcmUgWnAgPSB6c3BhZ2Ugc2l6ZSA9IGsgKiBQQUdF
X1NJWkUgd2hlcmUgayA9IDEsIDIsIC4uLg0KICAqDQogICogRm9yIGV4YW1wbGUsIGZvciBzaXpl
IGNsYXNzIG9mIDMvOCAqIFBBR0VfU0laRSwgd2Ugc2hvdWxkDQotLQ0KMS43LjkuNQ0K


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
