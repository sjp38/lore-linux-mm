Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f173.google.com (mail-vc0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 21FCF6B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 03:31:50 -0400 (EDT)
Received: by mail-vc0-f173.google.com with SMTP id ik5so1677900vcb.18
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 00:31:49 -0700 (PDT)
Received: from mail-vc0-x233.google.com (mail-vc0-x233.google.com [2607:f8b0:400c:c03::233])
        by mx.google.com with ESMTPS id j5si5145721veb.21.2014.04.30.00.31.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 00:31:48 -0700 (PDT)
Received: by mail-vc0-f179.google.com with SMTP id ij19so1675018vcb.38
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 00:31:48 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 30 Apr 2014 09:31:48 +0200
Message-ID: <CAM3PqV42h6eGPSKVu3ihcPy1pJT0Op=hafE8SGVPcALm=WV2=Q@mail.gmail.com>
Subject: Question regarding memory maps in VFS
From: Maksym Planeta <mcsim.planeta@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello,

are there any invariants for f->f_mapping, f->f_inode->i_mapping and
f->f_path.dentry->d_inode->i_mapping (where f is struct file*)? And
what is the difference between these pointers?

-- 
Regards,
Maksym Planeta.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
