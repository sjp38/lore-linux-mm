Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B8EFC4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:34:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C6D320828
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:34:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="MSV3k1wR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C6D320828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B707A8E0003; Fri, 28 Jun 2019 14:34:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFA448E0002; Fri, 28 Jun 2019 14:34:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99B688E0003; Fri, 28 Jun 2019 14:34:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f206.google.com (mail-qt1-f206.google.com [209.85.160.206])
	by kanga.kvack.org (Postfix) with ESMTP id 77A6D8E0002
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 14:34:55 -0400 (EDT)
Received: by mail-qt1-f206.google.com with SMTP id d26so6960122qte.19
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 11:34:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=fawPQY/UISfSH6DvrztcWabWXm47TtXieQJWSELxOKQ=;
        b=niY+TEf41rhTgK66ZUOnOEedTboDdJ+zjZmhTgHTV4OMvOsWeSB0PZ8i3Hb+/43UIV
         9k2QqedK43lmbuVyKH7gzHLaXJv86yxqZbpkpy5oNbIfoPhUCFUwvhAinq11FRMIrBqG
         Kfd5BMpqiGCGGoxgxujgI7l4b9QYZeWnrpSZi7WoID9wglCqZmaVNX3aW8NQJmXJHEYI
         GHDZJYHmrXWlGSjuer5cKL0QDuR1GYFDry5FWTVjXbaEU0OewRQ1VPTXyeNTssW61QTe
         7s7su6eU0quvRNQnIcPaTPvbXgAhyo4A5Q0pVL3pqvzmGMHUlKYOfAkIbYDuEu0H9pFF
         4lUQ==
X-Gm-Message-State: APjAAAWaf/GeUWHPwBWbUosMiGrVq+MstVBz7MrTEBcO2OvMa8ZkxGmD
	FIK1D8ysPSwTxh/9RdS7KNGZOvL9l7gYIVjJPCR5Wzc1xF9Y38H7f/ic9NSeeyaO4WFvbO8GSIr
	J9dUizKWqbQe6bPKevUUy94gB4TTMq/JfYG4vdclTtCnMUYChOCPZmJ/8//8PWvaojw==
X-Received: by 2002:a37:b045:: with SMTP id z66mr9949607qke.501.1561746895097;
        Fri, 28 Jun 2019 11:34:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx21HGghw8FSO4ue9MFICsfqzWF61iyuOuxVhgGEs0gZ38kreCSCYf4nVMehTr4/BQ4/yD5
X-Received: by 2002:a37:b045:: with SMTP id z66mr9949563qke.501.1561746894424;
        Fri, 28 Jun 2019 11:34:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561746894; cv=none;
        d=google.com; s=arc-20160816;
        b=cH8n7PZF0YErF29O2TBEXvHHVdZQTJ0kfzeNcTy6sg6kvsfbq1dPiUkjIINu2vPlUl
         ykuvwP9fXO/QPBmAewUDjCR3pjoZXalyWwJWw1aET1UBKmqLrN1PmqXQ9qgaS8PpRYcf
         /iEfiz06HC4It+s05+fRZHrRkY6GGc2FQbY6M4vPsyS80JnOZYXQrJRjrPUhFz09oHTb
         jZG2mBwx7MnfNoql0EXgKtrQW09CEHAXuPlDTfxTa0BQilizAO6WjRtyIA8B77GXesP3
         5Ivo9038glRzn/7pG7bMDGQajKvXKT//3GGFcG3zi8OKv3nKGupCO4Gi4WmW1xF1mgUG
         ihwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=fawPQY/UISfSH6DvrztcWabWXm47TtXieQJWSELxOKQ=;
        b=0iQLwE+KJuirkLcGF2VZO0ctEhqflXhfAkaYM74lSB4QNTsgkcgPxFivrxfI/wfClH
         82cTn9HnP5E0RbSE7K5Pdfn6DS/Dr/RUWJioPUZabZ5Yidd3JTtrpkYKEDwbmNROGBl9
         t8jmVGNMG1qdrdj2TFPCmrD5+82jze/O5bpLXm64ZObD1T7XpQylyXKWLMDAVuSKZtQk
         tAkHmyKHuTaOMkCvLfXEGuwKeN9ccKnPF7qpP1AU/ZkL3GFHlaZ65h2kDM5Tsf4nadWj
         Ow6RifUC7h4v+PWotakseHfBcYXb/rPiiHZ0R7guweJ0yn2f5uM71fBHfPO5ORfuiiKO
         y3Uw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=MSV3k1wR;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id m9si2643401qke.19.2019.06.28.11.34.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 11:34:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=MSV3k1wR;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5SIYFKk027580;
	Fri, 28 Jun 2019 18:34:40 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : mime-version : content-type :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=fawPQY/UISfSH6DvrztcWabWXm47TtXieQJWSELxOKQ=;
 b=MSV3k1wREyOZiFpPpvgY3Rux39mU5lQ1KuniYc4Ie6w7JtZJmHKecvubM23dsIDGuJZj
 0kBZKXN2nVbEu420ZAKAI1xRCkRYIV2YwintD6ID8Ef9AbMSdXwgcgptihQ1MHeFh2xq
 4rthJOp1LoqFymHqc7XUoAgWgyHhQQXJ6mUsYDiNcGbORfy7T7jZgONqr9D3Obf778mO
 OMaSDrTN639V6Y5LIwKcUxtwE9Aby8Sku8uUQgNDdtjD6t77xSNL7Dbg+p5SeDnXQdcl
 a2PsAdVk14mFbai1lLrR0i9JMF4YWvUjiuNurCUsTfH4inSLWA8dSmsARfc/6gXafxRO PQ== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2t9c9q72q0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 28 Jun 2019 18:34:39 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5SIXdhY078899;
	Fri, 28 Jun 2019 18:34:39 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3030.oracle.com with ESMTP id 2t9acdyeaf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Fri, 28 Jun 2019 18:34:39 +0000
Received: from aserp3030.oracle.com (aserp3030.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5SIYdKY080557;
	Fri, 28 Jun 2019 18:34:39 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2t9acdyeac-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 28 Jun 2019 18:34:39 +0000
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5SIYcPk001892;
	Fri, 28 Jun 2019 18:34:38 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 28 Jun 2019 11:34:38 -0700
Subject: [PATCH v6 0/4] vfs: make immutable files actually immutable
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: matthew.garrett@nebula.com, yuchao0@huawei.com, tytso@mit.edu,
        darrick.wong@oracle.com, ard.biesheuvel@linaro.org,
        josef@toxicpanda.com, hch@infradead.org, clm@fb.com,
        adilger.kernel@dilger.ca, viro@zeniv.linux.org.uk, jack@suse.com,
        dsterba@suse.com, jaegeuk@kernel.org, jk@ozlabs.org
Cc: reiserfs-devel@vger.kernel.org, linux-efi@vger.kernel.org,
        devel@lists.orangefs.org, linux-kernel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org, linux-nilfs@vger.kernel.org,
        linux-mtd@lists.infradead.org, ocfs2-devel@oss.oracle.com,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Date: Fri, 28 Jun 2019 11:34:35 -0700
Message-ID: <156174687561.1557469.7505651950825460767.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9302 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906280210
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

The chattr(1) manpage has this to say about the immutable bit that
system administrators can set on files:

"A file with the 'i' attribute cannot be modified: it cannot be deleted
or renamed, no link can be created to this file, most of the file's
metadata can not be modified, and the file can not be opened in write
mode."

Given the clause about how the file 'cannot be modified', it is
surprising that programs holding writable file descriptors can continue
to write to and truncate files after the immutable flag has been set,
but they cannot call other things such as utimes, fallocate, unlink,
link, setxattr, or reflink.

Since the immutable flag is only settable by administrators, resolve
this inconsistent behavior in favor of the documented behavior -- once
the flag is set, the file cannot be modified, period.  We presume that
administrators must be trusted to know what they're doing, and that
cutting off programs with writable fds will probably break them.

Therefore, add immutability checks to the relevant VFS functions, then
refactor the SETFLAGS and FSSETXATTR implementations to use common
argument checking functions so that we can then force pagefaults on all
the file data when setting immutability.

Note that various distro manpages points out the inconsistent behavior
of the various Linux filesystems w.r.t. immutable.  This fixes all that.

I also discovered that userspace programs can write and create writable
memory mappings to active swap files.  This is extremely bad because
this allows anyone with write privileges to corrupt system memory.  The
final patch in this series closes off that hole, at least for swap
files.

If you're going to start using this mess, you probably ought to just
pull from my git trees, which are linked below.

This has been lightly tested with fstests.  Enjoy!
Comments and questions are, as always, welcome.

--D

kernel git tree:
https://git.kernel.org/cgit/linux/kernel/git/djwong/xfs-linux.git/log/?h=immutable-files

fstests git tree:
https://git.kernel.org/cgit/linux/kernel/git/djwong/xfstests-dev.git/log/?h=immutable-files

