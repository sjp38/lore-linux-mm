Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 827F7C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:35:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F50B20828
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:35:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="mnvLlQbV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F50B20828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B71578E0005; Fri, 28 Jun 2019 14:35:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B20D28E0002; Fri, 28 Jun 2019 14:35:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E87B8E0005; Fri, 28 Jun 2019 14:35:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f77.google.com (mail-yw1-f77.google.com [209.85.161.77])
	by kanga.kvack.org (Postfix) with ESMTP id 770458E0002
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 14:35:04 -0400 (EDT)
Received: by mail-yw1-f77.google.com with SMTP id b129so9957013ywe.22
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 11:35:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=SzhUagx5xKDjUPMnCOT6QDZ48tKdmDiAhiUc4dwBNMc=;
        b=NUwE6q145Mawt70RmfKYvR47hqFnztb6hO5jN19g8x7H0FCXPQREOm2NsX7oYzgFpy
         yUOl1zznj0b4xchJT4t6S7piPH7NrG/ArHkg+cyLtvrGDNbLm4Bnd8PmWPSwo+7rW3cr
         n6N0ZTyihdswPe6FE46hApGvMYj/TqXDtbis6jjybaABsOEXmPqCvwXiP7O21T7xPRgs
         MnGwS7uscRHAyd4l92xIG2o16CWw6X6FhaZymbYaSmN4kdGtBGp+BNyzmTP3PMygzc9K
         hpraIitrSRPm0aBG86TTYGG00B1B05GBhErUdUvFgXlQbeWNC2yUP3UJF+IAK5bbYzQE
         0X3g==
X-Gm-Message-State: APjAAAUR8CL2aL2ooEU/2TsviRWJc8XUxQGp4ZCWrBzACX5VSJKdVK7/
	wW607enroz5hDphrXVze/mY5bmquxnfoUSXca5WQR+XC9E5EcWA55fWAD5LDh7nrULSRvZRMMrB
	YWrRHQhm2In2M3nYIZqdkDAzGup66wo4TAqHT4qI6KLEs63O1QtYWTl6JYyb2lsbKRw==
X-Received: by 2002:a81:2713:: with SMTP id n19mr7517945ywn.399.1561746904100;
        Fri, 28 Jun 2019 11:35:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGvGLhaJ/CZM9yPsruo7LO94K5HRBmb8+bEhkwmnmb5VW06T3ACs6+Wegr7GCePWnJ+Sbl
X-Received: by 2002:a81:2713:: with SMTP id n19mr7517914ywn.399.1561746903468;
        Fri, 28 Jun 2019 11:35:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561746903; cv=none;
        d=google.com; s=arc-20160816;
        b=CqjlGKIk52gXr6CmQ7o3abAUijg7tjPO3kPBC1iR+W9sLzBrgd0xeqJV8eGKdgYXw7
         e0m+6u0fLf117Wtagi1fFhK4KwwM7XD9bUZ4zqmtZ506EunYImV11xfbCa1yBqv1RmMX
         f73I+Y8QYcOn2kxkhlswxGNFPgooVn2wEiQKB/taqPlqXmWAUoFwHqBLETjq2+f+oIqh
         BGhpWj+NfuNG0rnveJh32Km9T7RZ4aqtGOGIBCT7LkV64OqWvbjRRFib7qJbfxBEs0yT
         xBN2CfamPq8HvcuOd+8D2xIGe2/pq1/dOpWJWADprwU4IWM4x8+RBGX+vIhwxYM1XXaV
         TQBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=SzhUagx5xKDjUPMnCOT6QDZ48tKdmDiAhiUc4dwBNMc=;
        b=WCDt307OjOiqtS8c0euaaXi72pI7v9OBSXJcRxQCV2ZLosiJw71JLEMEWxfaTepybQ
         30pLWq0S1q50yUWF5MQfbOSjVvgJ3cn1RPNQCyQOeJ3qiYRVEqaRP/AT3Zax6eTdQo12
         kSeANwQ1746s2gWEjiIeco1F8lejdsa+42QN5RK018BJnBoGKK1KUT63lTN8xVALa/SL
         Zao6oOFdXXX7W3BHKMBJPoJf20mpoXOzUsE7lWkS34Ix4TKrcEVdxzqLJnI9F0fKMJBF
         JeVnIL+v5X+TiC8SwrrT7YFxBJUSLexgURnZ4VbwUZeV/CWzUZgHGRFHxSu2X+oVXUea
         MO7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=mnvLlQbV;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id q126si1288840ybq.99.2019.06.28.11.35.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 11:35:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=mnvLlQbV;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5SIYFLu114564;
	Fri, 28 Jun 2019 18:34:51 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=SzhUagx5xKDjUPMnCOT6QDZ48tKdmDiAhiUc4dwBNMc=;
 b=mnvLlQbV2QHV26kqG92l3MXPrAPzWnlJDT7iMchyHjON0BMde8Sg9j+NJSQ2cgtq+RKW
 GtWC0aXPwH4JWFvGkbIDc22Kpnp3GPUUwn/X+y7MbUPXCMHqkJHXTM3sf3ePxCPgGQTR
 Ik6oOyIb8/35YREB7LMH6RLuFlRi5sjofcBUaHWl210Cqx59Cuy3psQwF5i939AWsCZH
 0eByhkqF2267VS9+c8UPrsMZ+4ehuzeqW4nIe7Lc0ETccrtY9ADYq8g6iQDQxz6qcAb9
 spxjGujEt8id50pXB71YFUjUEKKpzcUsz3+oVF3hJ6svSdLkNQjVZZEXy9sdSHInKJxt PQ== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2t9cyqxyj6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 28 Jun 2019 18:34:50 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5SIXcw7078820;
	Fri, 28 Jun 2019 18:34:50 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3030.oracle.com with ESMTP id 2t9acdyec3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Fri, 28 Jun 2019 18:34:50 +0000
Received: from aserp3030.oracle.com (aserp3030.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5SIYdKa080557;
	Fri, 28 Jun 2019 18:34:49 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2t9acdyebu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 28 Jun 2019 18:34:49 +0000
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5SIYk5o021913;
	Fri, 28 Jun 2019 18:34:47 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 28 Jun 2019 11:34:46 -0700
Subject: [PATCH 1/4] mm/fs: don't allow writes to immutable files
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: matthew.garrett@nebula.com, yuchao0@huawei.com, tytso@mit.edu,
        darrick.wong@oracle.com, ard.biesheuvel@linaro.org,
        josef@toxicpanda.com, hch@infradead.org, clm@fb.com,
        adilger.kernel@dilger.ca, viro@zeniv.linux.org.uk, jack@suse.com,
        dsterba@suse.com, jaegeuk@kernel.org, jk@ozlabs.org
Cc: reiserfs-devel@vger.kernel.org, linux-efi@vger.kernel.org,
        Jan Kara <jack@suse.cz>, devel@lists.orangefs.org,
        linux-kernel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-nilfs@vger.kernel.org, linux-mtd@lists.infradead.org,
        ocfs2-devel@oss.oracle.com, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org
Date: Fri, 28 Jun 2019 11:34:43 -0700
Message-ID: <156174688345.1557469.793195935067841912.stgit@magnolia>
In-Reply-To: <156174687561.1557469.7505651950825460767.stgit@magnolia>
References: <156174687561.1557469.7505651950825460767.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9302 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=375 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906280210
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Darrick J. Wong <darrick.wong@oracle.com>

The chattr manpage has this to say about immutable files:

"A file with the 'i' attribute cannot be modified: it cannot be deleted
or renamed, no link can be created to this file, most of the file's
metadata can not be modified, and the file can not be opened in write
mode."

Once the flag is set, it is enforced for quite a few file operations,
such as fallocate, fpunch, fzero, rm, touch, open, etc.  However, we
don't check for immutability when doing a write(), a PROT_WRITE mmap(),
a truncate(), or a write to a previously established mmap.

If a program has an open write fd to a file that the administrator
subsequently marks immutable, the program still can change the file
contents.  Weird!

The ability to write to an immutable file does not follow the manpage
promise that immutable files cannot be modified.  Worse yet it's
inconsistent with the behavior of other syscalls which don't allow
modifications of immutable files.

Therefore, add the necessary checks to make the write, mmap, and
truncate behavior consistent with what the manpage says and consistent
with other syscalls on filesystems which support IMMUTABLE.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/attr.c    |   13 ++++++-------
 mm/filemap.c |    3 +++
 mm/memory.c  |    4 ++++
 mm/mmap.c    |    8 ++++++--
 4 files changed, 19 insertions(+), 9 deletions(-)


diff --git a/fs/attr.c b/fs/attr.c
index d22e8187477f..1fcfdcc5b367 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -233,19 +233,18 @@ int notify_change(struct dentry * dentry, struct iattr * attr, struct inode **de
 
 	WARN_ON_ONCE(!inode_is_locked(inode));
 
-	if (ia_valid & (ATTR_MODE | ATTR_UID | ATTR_GID | ATTR_TIMES_SET)) {
-		if (IS_IMMUTABLE(inode) || IS_APPEND(inode))
-			return -EPERM;
-	}
+	if (IS_IMMUTABLE(inode))
+		return -EPERM;
+
+	if ((ia_valid & (ATTR_MODE | ATTR_UID | ATTR_GID | ATTR_TIMES_SET)) &&
+	    IS_APPEND(inode))
+		return -EPERM;
 
 	/*
 	 * If utimes(2) and friends are called with times == NULL (or both
 	 * times are UTIME_NOW), then we need to check for write permission
 	 */
 	if (ia_valid & ATTR_TOUCH) {
-		if (IS_IMMUTABLE(inode))
-			return -EPERM;
-
 		if (!inode_owner_or_capable(inode)) {
 			error = inode_permission(inode, MAY_WRITE);
 			if (error)
diff --git a/mm/filemap.c b/mm/filemap.c
index aac71aef4c61..dad85e10f5f8 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2935,6 +2935,9 @@ inline ssize_t generic_write_checks(struct kiocb *iocb, struct iov_iter *from)
 	loff_t count;
 	int ret;
 
+	if (IS_IMMUTABLE(inode))
+		return -EPERM;
+
 	if (!iov_iter_count(from))
 		return 0;
 
diff --git a/mm/memory.c b/mm/memory.c
index ddf20bd0c317..abf795277f36 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2235,6 +2235,10 @@ static vm_fault_t do_page_mkwrite(struct vm_fault *vmf)
 
 	vmf->flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
 
+	if (vmf->vma->vm_file &&
+	    IS_IMMUTABLE(vmf->vma->vm_file->f_mapping->host))
+		return VM_FAULT_SIGBUS;
+
 	ret = vmf->vma->vm_ops->page_mkwrite(vmf);
 	/* Restore original flags so that caller is not surprised */
 	vmf->flags = old_flags;
diff --git a/mm/mmap.c b/mm/mmap.c
index 7e8c3e8ae75f..b3ebca2702bf 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1483,8 +1483,12 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 		case MAP_SHARED_VALIDATE:
 			if (flags & ~flags_mask)
 				return -EOPNOTSUPP;
-			if ((prot&PROT_WRITE) && !(file->f_mode&FMODE_WRITE))
-				return -EACCES;
+			if (prot & PROT_WRITE) {
+				if (!(file->f_mode & FMODE_WRITE))
+					return -EACCES;
+				if (IS_IMMUTABLE(file->f_mapping->host))
+					return -EPERM;
+			}
 
 			/*
 			 * Make sure we don't allow writing to an append-only

