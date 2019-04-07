Return-Path: <SRS0=rDiK=SJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E527AC10F0E
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 20:27:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F2AB20880
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 20:27:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="i/pDYUgc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F2AB20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B758C6B0005; Sun,  7 Apr 2019 16:27:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B23C36B0006; Sun,  7 Apr 2019 16:27:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C4D06B0007; Sun,  7 Apr 2019 16:27:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2936B0005
	for <linux-mm@kvack.org>; Sun,  7 Apr 2019 16:27:14 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n5so8474978pgk.9
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 13:27:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=35ifg42zEenL7YYdIzei8tu3bHGzCDlXvpdEmpGEZok=;
        b=dShoD+4ie36cAOJR01SiX2kXnqfDiG4MaTF2iEHFWrJGk0Qt8x7qbTkHzJ55AZs4Gj
         w9Man+KSZiMqHmd9sKJCP4oBNfix+G63osK+Pz9YpUzrkFKjzuHDDLirNslxhk+Qsnpt
         DWxqudPQ2JR3kO2AS7LaDwucCPITq//1M+wyq0bOv1M04NhkuRXLXSPPRnD+jU6LAjCG
         Zl5HQNmsjTKsuBZWKkcYEe+bij04ucfUOfENyLf+2xoB1TIcOk9Yoa7cEwsSzFamvfd1
         l59D2XQJX7ET+KIO6O5jJHg/4j2gjrDF06LccIXeGg0VYuFZrDQcbHgsb1hxcsnRINFR
         JGog==
X-Gm-Message-State: APjAAAUaBrDPx/l6e9V4Vbgy4hQhvmt8/bfC/WzNFNMf7SVXBWuhauKv
	Jub47AGJ1jA/v3AnG0T8mgpWDWKbDma1xQoHZZ7iShjF2k5UGU16PHj8UoLyNJokC1vkgLrkFLw
	nOCOivUGUCFfDtl9yL7J3kOsU2wTASnhEvUQlkdyXA8oQm5rU6XScBKeot7Gt4DhgLg==
X-Received: by 2002:a63:7141:: with SMTP id b1mr24459206pgn.331.1554668833752;
        Sun, 07 Apr 2019 13:27:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQddtga6CQPZEPUBu4HKaZ5SP1I5kItLqWJsUCuzT+qXPIRvSXs1WQqwmMM0WDzq/wtBUu
X-Received: by 2002:a63:7141:: with SMTP id b1mr24459172pgn.331.1554668832984;
        Sun, 07 Apr 2019 13:27:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554668832; cv=none;
        d=google.com; s=arc-20160816;
        b=w9sXIkWYy25HPJl5rQHnnxvkJMZlxnKOytu4T+MSycgmHradFcvauujUkbqK5qN3kR
         9iwGC8OAjuVWdNKsyM8hkiGDMm4a34PcirjEUWA6lmOiR6wg4KrfuUSQiqoiUaZR/CJN
         CxrOHGrB9fyMmw6Wde4oX4gj/0hm35O/F64X/KSKvlh55VUfTVWk6q4W49AOzqCuEJxz
         SjguCxWh0vpculygoBQCFmaYXbPFfJ65lzylXqvRiwbhpKxxoeb8+zepDc46zFFcqtm6
         S4nHzHj+z6Hl+PYxTtKa8QT9odhm4scjv9oX82VzLonObou2NnOaSHhMZbSfFq3BEEt/
         3FNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=35ifg42zEenL7YYdIzei8tu3bHGzCDlXvpdEmpGEZok=;
        b=Aadf/L8RPg9ZE8jXIOWGEb624DWhbAPrRV6XyPm5QOeH3kw14xdo8r7mBKTVPxX+z+
         hJ7gfJ95BRcG2VKCuoiIbzUG0xQcw1gKahuG3E0Pp5a6zemR1L+KQGxDOVdRRLrHkfXP
         zYhxroO3KrbHxN90hqRC5XQ2oxvzvnBFzOqw2QfTnkEQPmzQ/5zVibXJ92sLCH462PVq
         Y5cWOzGcjlK0GbRY1wu7XH6nsXZZDked1Oz6uKKH7RO0KxSN0AweTAdptZcdwWp2tj6+
         qB2w90vIxsZL9JPt7DjyxLRKUenIjo0mBIYPeSAiXDtp9dlKGpCDUNVbOj1uuCMusIAp
         8VAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="i/pDYUgc";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id k10si21600498pgq.293.2019.04.07.13.27.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Apr 2019 13:27:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="i/pDYUgc";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x37KN3Zc070689;
	Sun, 7 Apr 2019 20:27:11 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : mime-version : content-type :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=35ifg42zEenL7YYdIzei8tu3bHGzCDlXvpdEmpGEZok=;
 b=i/pDYUgcoqB269ddpKABvxhrxLkJqqLgpAzhiuesP7D0l6OAhEZcOvkF6siap0yGqFz/
 kzWPS2V9t5yZ7FZ+wAqyXbbDLDhaTdR1Mh1qkUDDiBoPQgArZGQOCTa2bP/Q1v6TMiDF
 l3SB3uCcXCSEEau64WqIbnZxy2ytpNLRrVNBm+r82VZvwzbeEYG8XmceDoPSQCEXgulC
 xvFeLHCqyuvfwHu+CCx381BtQS1uNxAXpk1mm3EPNGbq2jfPpzuWnkvDwmTTw6g6rvJi
 kLy27dVAGxodOCF/nm6mmm7fkbfdsDGUAyY/EinEFWIivwvm/j+nOnlo12xcX4niwyhA 3g== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2130.oracle.com with ESMTP id 2rphme3bdu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 07 Apr 2019 20:27:11 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x37KQN6u165532;
	Sun, 7 Apr 2019 20:27:10 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3030.oracle.com with ESMTP id 2rph7rqdfn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 07 Apr 2019 20:27:10 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x37KR8wa025403;
	Sun, 7 Apr 2019 20:27:09 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Sun, 07 Apr 2019 13:27:08 -0700
Subject: [PATCH v2 0/4] vfs: make immutable files actually immutable
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: darrick.wong@oracle.com
Cc: david@fromorbit.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Date: Sun, 07 Apr 2019 13:27:01 -0700
Message-ID: <155466882175.633834.15261194784129614735.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9220 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=954
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904070193
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9220 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=981 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904070193
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
the flag is set, the file cannot be modified, period.

If you're going to start using this mess, you probably ought to just
pull from my git trees, which are linked below.

This has been lightly tested with fstests.  Enjoy!
Comments and questions are, as always, welcome.

--D

kernel git tree:
https://git.kernel.org/cgit/linux/kernel/git/djwong/xfs-linux.git/log/?h=immutable-files

