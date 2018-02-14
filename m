Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7B33C6B0005
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 17:52:01 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id b6so11717086plx.3
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 14:52:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 61-v6si2069807plz.417.2018.02.14.14.51.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Feb 2018 14:52:00 -0800 (PST)
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
Subject: [LSF/MM ATTEND] memory allocation scope
Message-ID: <8b9d4170-bc71-3338-6b46-22130f828adb@suse.de>
Date: Wed, 14 Feb 2018 16:51:53 -0600
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org


Discussion with the memory folks towards scope based allocation
I am working on converting some of the GFP_NOFS memory allocation calls
to new scope API [1]. While other allocation types (noio, nofs,
noreclaim) are covered. Are there plans for identifying scope of
GFP_ATOMIC allocations? This should cover most (if not all) of the
allocation scope.

Transient Errors with direct I/O
In a large enough direct I/O, bios are split. If any of these bios get
an error, the whole I/O is marked as erroneous. What this means at the
application level is that part of your direct I/O data may be written
while part may not be. In the end, you can have an inconsistent write
with some parts of it written and some not. Currently the applications
need to overwrite the whole write() again.

Other things I am interested in:
 - new mount API
 - Online Filesystem Check
 - FS cache shrinking

[1] https://lwn.net/Articles/710545/


-- 
Goldwyn

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
