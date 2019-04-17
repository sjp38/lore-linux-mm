Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6D9AC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:06:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74EF2206BA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:06:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="sYhTtogV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74EF2206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DB676B027C; Wed, 17 Apr 2019 15:06:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18C216B027E; Wed, 17 Apr 2019 15:06:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 053CC6B027F; Wed, 17 Apr 2019 15:06:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id D58656B027C
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 15:06:37 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id g17so23377714qte.17
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 12:06:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=JouHYqapC+Bru3b7LvDckRkkxunv72G7Ij9fwNIVhtw=;
        b=J/TGqjFfraqqhTHKhhcedFQR4gvHSdOCUTPU5lwJrIpOqwSYHn4/C3lcbm+fFMOn8B
         gSFAW7g2OMuk+BINqSzhFA5gqLvIpr5ceDr4sye09V0F9I4Fm+N95BccJsBCW6uiV3I0
         csT7nmut0/ssPG0LRguKhCWrRcGHDdMvg45/R8q7Y79oIiusLBReSVhzIdvMRfonSj/V
         8Vzgb+LlBFiAjTwIBDOAWvw5KJ366JV9rI9PZv4DI0DkvE2Hp0r3ALqqK1kTk5CfVIVp
         YY1+HVIGTl/+Uo7ZZcUw5yaANAwA/LJC2N/MkPBC+JeP7GvAAzFr5L0npLMA09YXtlwg
         EzYA==
X-Gm-Message-State: APjAAAW/KNOt9kHgCv3otuSSpxQAGyE8LZ/azk+Wb0qRRV8iMYp0cRgp
	AwQZ44YjGHLEDpaI1EU/dqCA7T+2I1ZWNZ6hThucICXizo4NDxwjfRZvE5tnbOcV1uTVF/j+XBs
	+v3hwQai7cr8ocbXqgPneLfpsla3jv6uKodBY6QmqsM7B+vgK38Mcyan6DDCKp+Kzwg==
X-Received: by 2002:a37:5805:: with SMTP id m5mr68716947qkb.136.1555527997627;
        Wed, 17 Apr 2019 12:06:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyoMwh5aMahs71fS17+DDIfXcM82xVCA8n9uZJSwnIRmKYr/Kt5M3uH/RPt7Bm3VqKXs92k
X-Received: by 2002:a37:5805:: with SMTP id m5mr68716881qkb.136.1555527996872;
        Wed, 17 Apr 2019 12:06:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555527996; cv=none;
        d=google.com; s=arc-20160816;
        b=PvgrNcul9Bo4KG50vU67hHPMMyOZJmlYg2M4wI4lWNuaq6xZvKnL3ue5ghJi5c7rvP
         bRxwsyCnYhl2WyQLFEdUv56BKgu9/vGN6nIu+G8DtO/ctWwTHunjkAJPHuhL0sszLD/O
         keYZukLYDPYD3H6sdEhk9yfbRW0shNJ/p+VB67VeQFjN/k6yOCRWdXZeL6xKnA0x12MQ
         Mr3D5vz2mAiT1KiTAy1+To++KIEiMPE7TO7/vGcB9G56f7AT42beOV9cJUUHH1DWrc8T
         EfXT2TGD/5xlbtk2EuAB9Whu7ac4uC9Ig/m2WnUIvn9Y9WLVC+ygeftDhZw0NXWHkWO9
         CAoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=JouHYqapC+Bru3b7LvDckRkkxunv72G7Ij9fwNIVhtw=;
        b=DBz+Ky7e1W3clccqoheDoUF+GufUGMFPDhmpAOFjEZx9HYtK23RJ8edNL+Vap1eT2J
         qHiHt6udt2H8sB/VRz28lBsQ/5X32ec3setYB6haais0EW2aOQ0xS2pszgRS5nkRO3Pw
         08MqjVy46tOSeEjx0qVSLQ2pBlgjTQ1nTRy+kAzLe75tFS2zBR2agEqEj/TuNUwiV6NG
         vAtaMPPj6G3FHqraLBivdxWlp/yS8f8Jt3oms/cFVLG96ravlJNpfi7AIyHdxD9/VGvH
         QuaQaooVK0gEdcEAgYvmzVjPQ+gNspM3CrOa8SFD+kEpzSD7JnXjT/LIR8GGEEQmFN7r
         2oOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=sYhTtogV;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id n18si9773898qvn.17.2019.04.17.12.06.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 12:06:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=sYhTtogV;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3HIwrW0174911;
	Wed, 17 Apr 2019 19:06:36 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=JouHYqapC+Bru3b7LvDckRkkxunv72G7Ij9fwNIVhtw=;
 b=sYhTtogV2rz0CQ7WtQZBxg27VjT2c0iYvfnb7MkAJHjwYWyrFXX6d2yTmAznDmyilqJB
 d9OepAaFTrcZi9wpBI7rBESJRoaT0WSSYhAUssNFj/G2xlcBkOYOCjddOG1LIfQtQ4qz
 PTMnFG8X0NjYd7F982V9yU1WjX/KOcluZaBD2LzIqWcHZsy4njOrTS32V6UrEAPZ6z7T
 oaM12PSyqVObWxMFI7ckyHglKDXbpbSsY8pON5zwmFRPj93BLpv3AAq6Hj5qYi76xbTF
 LImlFac+FuXVRvr6GL7FGrEWHWE49GT1YxhLtDrfYyIZwStbi1ZswjmAyxCQlYdDb2j/ HQ== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2130.oracle.com with ESMTP id 2ru59dcxbv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 17 Apr 2019 19:06:35 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3HJ4ScB119486;
	Wed, 17 Apr 2019 19:04:35 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3020.oracle.com with ESMTP id 2rubq744gy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 17 Apr 2019 19:04:34 +0000
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3HJ4YpM020984;
	Wed, 17 Apr 2019 19:04:34 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 17 Apr 2019 12:04:34 -0700
Subject: [PATCH 1/8] mm/fs: don't allow writes to immutable files
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: darrick.wong@oracle.com
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mm@kvack.org
Date: Wed, 17 Apr 2019 12:04:33 -0700
Message-ID: <155552787330.20411.11893581890744963309.stgit@magnolia>
In-Reply-To: <155552786671.20411.6442426840435740050.stgit@magnolia>
References: <155552786671.20411.6442426840435740050.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9230 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=1 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=265
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904170125
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9230 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=292 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904170125
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
---
 fs/attr.c    |   13 ++++++-------
 mm/filemap.c |    3 +++
 mm/memory.c  |    3 +++
 mm/mmap.c    |    8 ++++++--
 4 files changed, 18 insertions(+), 9 deletions(-)


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
index d78f577baef2..9fed698f4c63 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -3033,6 +3033,9 @@ inline ssize_t generic_write_checks(struct kiocb *iocb, struct iov_iter *from)
 	loff_t count;
 	int ret;
 
+	if (IS_IMMUTABLE(inode))
+		return -EPERM;
+
 	if (!iov_iter_count(from))
 		return 0;
 
diff --git a/mm/memory.c b/mm/memory.c
index ab650c21bccd..dfd5eba278d6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2149,6 +2149,9 @@ static vm_fault_t do_page_mkwrite(struct vm_fault *vmf)
 
 	vmf->flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
 
+	if (vmf->vma->vm_file && IS_IMMUTABLE(file_inode(vmf->vma->vm_file)))
+		return VM_FAULT_SIGBUS;
+
 	ret = vmf->vma->vm_ops->page_mkwrite(vmf);
 	/* Restore original flags so that caller is not surprised */
 	vmf->flags = old_flags;
diff --git a/mm/mmap.c b/mm/mmap.c
index 41eb48d9b527..697a101bda59 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1481,8 +1481,12 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 		case MAP_SHARED_VALIDATE:
 			if (flags & ~flags_mask)
 				return -EOPNOTSUPP;
-			if ((prot&PROT_WRITE) && !(file->f_mode&FMODE_WRITE))
-				return -EACCES;
+			if (prot & PROT_WRITE) {
+				if (!(file->f_mode & FMODE_WRITE))
+					return -EACCES;
+				if (IS_IMMUTABLE(file_inode(file)))
+					return -EPERM;
+			}
 
 			/*
 			 * Make sure we don't allow writing to an append-only

