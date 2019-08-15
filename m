Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7413CC3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 16:06:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EBDB206C1
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 16:06:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="dNRIY7FJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EBDB206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDE996B02B3; Thu, 15 Aug 2019 12:06:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8D836B02B4; Thu, 15 Aug 2019 12:06:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A55696B02B5; Thu, 15 Aug 2019 12:06:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0049.hostedemail.com [216.40.44.49])
	by kanga.kvack.org (Postfix) with ESMTP id 826FA6B02B3
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 12:06:00 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 38930180AD806
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:06:00 +0000 (UTC)
X-FDA: 75825138480.23.kitty01_173c0d82f0149
X-HE-Tag: kitty01_173c0d82f0149
X-Filterd-Recvd-Size: 4195
Received: from aserp2120.oracle.com (aserp2120.oracle.com [141.146.126.78])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:05:59 +0000 (UTC)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7FG3sOU002998;
	Thu, 15 Aug 2019 16:05:46 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : mime-version : content-type :
 content-transfer-encoding; s=corp-2019-08-05;
 bh=5yuIMPIpR5tQleHFD55uwrKrfIrbzlh+2NW69UrzAmo=;
 b=dNRIY7FJevZFSa0/B3wDYb4rtEAIUYjO/HI0dgmgUfHHf90AiVoOV3KfrKNPQSApsD95
 vikkIX35sIVu0mChiuFu2eJREgzBywXKuwlj8AQ5dGvJqYgtKO4zMrqUikgFOtoYhMqI
 B19AYf9O1d4aAsFoc9fMZkJ0cJavC8VqyluSIChGYJ9GzB9WcG4PN3Q7Tz7EdkicNXlk
 M9geiGrNTrCS6fXai/oEZxdUi/b2osfW8ea6Y+itKAKkAitnaryez4inzMXgjAa8akBw
 BHP49vdEWRVgXcpLyaAqlK2W8JghBiPCOpcTTSs7A2FZS8n8gIiaUK/CUFjEmVvi8iZI FA== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2120.oracle.com with ESMTP id 2u9nvpkp2t-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 15 Aug 2019 16:05:46 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7FG3VCE058463;
	Thu, 15 Aug 2019 16:05:45 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3020.oracle.com with ESMTP id 2ucgf169rr-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 15 Aug 2019 16:05:45 +0000
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x7FG5gJN017382;
	Thu, 15 Aug 2019 16:05:42 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 15 Aug 2019 09:05:42 -0700
Subject: [PATCH v3 0/2] vfs: make active swap files unwritable
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: hch@infradead.org, akpm@linux-foundation.org, tytso@mit.edu,
        viro@zeniv.linux.org.uk, darrick.wong@oracle.com
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org
Date: Thu, 15 Aug 2019 09:05:41 -0700
Message-ID: <156588514105.111054.13645634739408399209.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9350 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908150157
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9350 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908150158
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

I discovered that it's possible for userspace to write to active swap
files and swap devices.  While activated, the kernel effectively holds
an irrevocable (except by swapoff) longterm lease on the storage
associated with the swap device, so we need to shut down this vector for
memory corruption of userspace programs.

Nothing new for v3 other than rebasing against 5.3-rc4.

If you're going to start using this mess, you probably ought to just
pull from my git trees, which are linked below.

This has been lightly tested with fstests.  Enjoy!
Comments and questions are, as always, welcome.

--D

kernel git tree:
https://git.kernel.org/cgit/linux/kernel/git/djwong/xfs-linux.git/log/?h=immutable-swapfiles

fstests git tree:
https://git.kernel.org/cgit/linux/kernel/git/djwong/xfstests-dev.git/log/?h=immutable-swapfiles

