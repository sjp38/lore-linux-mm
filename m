Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CBBDC3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 06:49:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E14320644
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 06:49:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="AOWi0izM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E14320644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BC856B0005; Fri, 16 Aug 2019 02:49:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96DBD6B0006; Fri, 16 Aug 2019 02:49:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85AA26B0007; Fri, 16 Aug 2019 02:49:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0171.hostedemail.com [216.40.44.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5EAA56B0005
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 02:49:09 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id E7B378771
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 06:49:08 +0000 (UTC)
X-FDA: 75827363976.06.geese86_159b26040b641
X-HE-Tag: geese86_159b26040b641
X-Filterd-Recvd-Size: 4383
Received: from userp2130.oracle.com (userp2130.oracle.com [156.151.31.86])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 06:49:08 +0000 (UTC)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7G6iLRN059619;
	Fri, 16 Aug 2019 06:49:02 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2019-08-05;
 bh=/G+76/W1zby1jpownBKRPCeTP5Tx6JGAbv6QBHhjTGE=;
 b=AOWi0izMZmjlvXpyLpNgmdV4Wdm3NzzLkMtrTvYu9HH0kQfO5WZ7O4fm16ZzB/aL2BpY
 WO4W0Av7gGmt+oFKXaM7rrLlbV6kOpzpJA2juGAHLPaThQ4OHVrCHgoh51LJKoZVwNUC
 wks7fcmgbBWoZnnGq0tzg9ukZFk+xXGe4d8/iCBjYENAXtm0Ecyt7fXPppTD1DNX9Ggz
 P5eiiACeihE9GrbEXBs5xIfLhMTrugAOeVYMBfIgB8tjLmVIS12sbnKtH0sEwaoH8bho
 dr7xA5/8ENdqNNZbjIpgVVNLUDoDPYSAhz8Nphb0rgP774pzCobq01g9hQA0EUX/PocC bw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2u9nbtxrfx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 16 Aug 2019 06:49:02 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7G6mHDA074355;
	Fri, 16 Aug 2019 06:49:01 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3020.oracle.com with ESMTP id 2udgqfskct-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 16 Aug 2019 06:49:01 +0000
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x7G6n0Y2026884;
	Fri, 16 Aug 2019 06:49:00 GMT
Received: from localhost (/10.159.134.197)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 15 Aug 2019 23:48:59 -0700
Date: Thu, 15 Aug 2019 23:48:58 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: akpm@linux-foundation.org, tytso@mit.edu, viro@zeniv.linux.org.uk,
        linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 2/2] vfs: don't allow writes to swap files
Message-ID: <20190816064858.GG15186@magnolia>
References: <156588514105.111054.13645634739408399209.stgit@magnolia>
 <156588515613.111054.13578448017133006248.stgit@magnolia>
 <20190816064121.GB2024@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190816064121.GB2024@infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9350 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=807
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908160071
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9350 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=864 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908160070
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 11:41:21PM -0700, Christoph Hellwig wrote:
> The new checks look fine to me, but where does the inode_drain_writes()
> function come from, I can't find that in my tree anywhere.

Doh.  Forgot to include that patch in the series. :(

/*
 * Flush file data before changing attributes.  Caller must hold any locks
 * required to prevent further writes to this file until we're done setting
 * flags.
 */
static inline int inode_drain_writes(struct inode *inode)
{
       inode_dio_wait(inode);
       return filemap_write_and_wait(inode->i_mapping);
}

> Also what does inode_drain_writes do about existing shared writable
> mapping?  Do we even care about that corner case?

We probably ought to flush and invalidate the pagecache for the entire
file so that page_mkwrite can bounce off the swapfile.

--D

