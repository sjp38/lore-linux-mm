Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 396E9C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 02:33:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC37220645
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 02:33:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="G/aYnUXE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC37220645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96CCD8E0005; Tue, 25 Jun 2019 22:33:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 944128E0002; Tue, 25 Jun 2019 22:33:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85C328E0005; Tue, 25 Jun 2019 22:33:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 684F18E0002
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 22:33:22 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id x17so826743iog.8
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 19:33:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:user-agent:mime-version
         :message-id:date:from:to:cc:subject:content-transfer-encoding;
        bh=fawPQY/UISfSH6DvrztcWabWXm47TtXieQJWSELxOKQ=;
        b=OBcyUa0ooHvZkrS57gJcblHcKMPLwQomXpoEb8+ritm6MTVy2+BVLBB9HQQ7eVhdxe
         8mIj8xPYzp3NCipmo+lsttToeVP8LWJ+ybc4Opg6cBmguvT2r5qYdrKLohYPE06RFuuE
         D1oP3u5NBtz1OPHfYCZdpJNWVjb7liuxRCYGFGM1A5IRtlVZYJVT8eK6zDwk1KTAQMi6
         LrXpjloB12eH1AG9BO/R7tU9M8sLeqTaCb53inEOrleCq4m4EjJ9SdZCKp0MRMVupKBz
         pWiARIdhBg9tUvT5HM8b2hc8pNyTdnGNs8G1rVXZhYLD/R4NHJmbYVbd1nP5Nygmq/Mi
         yu2A==
X-Gm-Message-State: APjAAAVRmBGVqpGERiYbc9AkGi/HQzidHYyDC+VLEpc/LDKRNq3sjfVs
	hJwkEtBAmaA0AyLwIXFkI/So/PMkWpwzrbyAkL579DQUYe4Z6tMG8JNR2GH/Bg3hcA3vkTvBvjK
	1Ay/hF4f1sKSHqCBk2cGz/edDN/1hWk8iJzh1qfDricdikuN2JqESDJU3FXWArt8y4A==
X-Received: by 2002:a5d:9416:: with SMTP id v22mr2266168ion.4.1561516402118;
        Tue, 25 Jun 2019 19:33:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwnTvFS1q6CSOV0Dfr8y2j1Rys9TtwOpkV904e8ynRKPeTYp3WG35ZX+UQbNCcW8TvP0OR
X-Received: by 2002:a5d:9416:: with SMTP id v22mr2266118ion.4.1561516401289;
        Tue, 25 Jun 2019 19:33:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561516401; cv=none;
        d=google.com; s=arc-20160816;
        b=S+g1MaB9Ae4Ask0wzJF7KhUkJHDmOzfeFfwGqKOmpIW/FYyoUAfZHIFUp+uIEZeZkA
         lXCfN7YoxCNA0gWG9Ltt+rJRI/+uA/Q0Ju0I8pTs/+29+JBveAOZHKTVf18lSYtBRc5Y
         DKL9Z8CAKfDNi+iRm9Hc8SiKgqUa0X9A7gM1ysMzRrcujEdgzT6KtyWrR1CCcJ9EYT9c
         2oRP2qr/11J70YNVFVtm8CijqaPc/fEM5Xo8tNmJr18ZRW2uKxIhCG2Fc6e1ZXwxrVIO
         06Jyqp79sqlmhp8GxfVugR7BlWza5aNr6E+QJNXLChC6DLvX2Q6fdvsAN6+fjAmPVRDg
         dxHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:subject:cc:to:from:date:message-id
         :mime-version:user-agent:dkim-signature;
        bh=fawPQY/UISfSH6DvrztcWabWXm47TtXieQJWSELxOKQ=;
        b=peeH2vCeQYuPTsVITEHTXjKR2KXhQ5wh1OVdcJlvQj9XHCbB+saqPrDvnJlRFqxSmP
         fBo+sV4FzdU9TZX9aVuMvTUBmxK9wy0YidH31n834QZ2ZDiAKUIPy9mDDr9RVWy27AP3
         LPMJ+ceVVufPYduw4PRCIMYQXf3TeLM+Wpk9VOpqoJ0dulMZZut8fmWTeLGcS/QnDkbL
         gZ6TPjnD673yKcv7O1yI1y8SRbktmOXmvjLtcjzAm+fORMTgf/5hwhrWo8B2u2tZvDqR
         kGV2TQuttQgK2TSdPEWB/a8XZlEP6EzV/D2lV2b2b+5esskJC/EuBknKrh2fS+fCIDKQ
         iVXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="G/aYnUXE";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id y14si26907002jan.93.2019.06.25.19.33.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 19:33:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="G/aYnUXE";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5Q2TYh8026692;
	Wed, 26 Jun 2019 02:33:08 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=mime-version :
 message-id : date : from : to : cc : subject : content-type :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=fawPQY/UISfSH6DvrztcWabWXm47TtXieQJWSELxOKQ=;
 b=G/aYnUXEphMoz0tS57JlzzJidDTnCP3JwQDBotgjzdUejbyDPYJP0ww7UIoJ9qziXtze
 V8WfKNQm07ANAuCm8B36a/SSrlnF4iTQcfj6+NLwHRqJVTP47OZew3gQAlm23ALl0Umk
 xq3Im7dO6UOb8iISWt8zfUFMNhrviliNGlkVCg5a0cfeb27h0Drq5G4rl1p6MZONDA9T
 LOJ0700Z6AtHwS+rK56pnb/hADrt/VxtC4zKanyLYIE10jvKJ1zJCdEbZq2d2Ps/KjeI
 pOTljCBSvtHNdPtMRfVj73W2qgv94B8p+0UE9rS1oOhD12Oac8PGEIcskWt9iHiUUTuy 2A== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2120.oracle.com with ESMTP id 2t9c9pqjk5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 26 Jun 2019 02:33:08 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5Q2Wj2o020612;
	Wed, 26 Jun 2019 02:33:07 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3020.oracle.com with ESMTP id 2t9p6uh2eh-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 26 Jun 2019 02:33:07 +0000
Received: from aserp3020.oracle.com (aserp3020.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5Q2X7If021156;
	Wed, 26 Jun 2019 02:33:07 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2t9p6uh2ec-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 26 Jun 2019 02:33:07 +0000
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5Q2X6O7021146;
	Wed, 26 Jun 2019 02:33:06 GMT
Received: from localhost (/10.159.230.235) by default (Oracle Beehive Gateway
 v4.0) with ESMTP ; Tue, 25 Jun 2019 19:32:55 -0700
USER-AGENT: StGit/0.17.1-dirty
MIME-Version: 1.0
Message-ID: <156151637248.2283603.8458727861336380714.stgit@magnolia>
Date: Tue, 25 Jun 2019 19:32:52 -0700 (PDT)
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
Subject: [PATCH v5 0/5] vfs: make immutable files actually immutable
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9299 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906260027
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

