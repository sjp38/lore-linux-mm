Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3015C3A589
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 02:14:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7AF342086C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 02:14:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="CrDWYXm3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7AF342086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1FE06B0003; Thu, 15 Aug 2019 22:14:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCFA66B0005; Thu, 15 Aug 2019 22:14:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83DF16B0006; Thu, 15 Aug 2019 22:14:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0251.hostedemail.com [216.40.44.251])
	by kanga.kvack.org (Postfix) with ESMTP id 5B6966B0003
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 22:14:01 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 088D68248ABD
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 02:14:01 +0000 (UTC)
X-FDA: 75826670682.20.fall26_5d347953c451c
X-HE-Tag: fall26_5d347953c451c
X-Filterd-Recvd-Size: 4548
Received: from userp2120.oracle.com (userp2120.oracle.com [156.151.31.85])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 02:14:00 +0000 (UTC)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7G29JWk069079;
	Fri, 16 Aug 2019 02:13:46 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2019-08-05;
 bh=vvbu60KIKuj2V/M8HyUSUiae8i9AsQEjSkmMklAQSU8=;
 b=CrDWYXm3qcuFQaeesiwkTrgwYVJv1DCtUNMqQDKH19cdfsgdhbvkvj/C9W4fcvcAAhkS
 xcel/2InimHmZCfN0WEYZJ1c2wbM/F+p/CbwiGtV2C2N7M0BdsyXtJvPyhtQUkRUpn76
 VNmdsYRT2xF4dfmUOxaYLcp1Xm4j1Zc/qkAyt7bOrb1DqVdBgv+XKYb2sAis9gG7b/IF
 apQt0JWxEFa/v1KP9NEE45U+BhuuxpGY9MVDMjiLfU9+cHMRbnZe1fpFJSaOPJep4u0o
 SjQlFwpuo97CH/2XjO6DZihFE0ZpZKlKizLUmHMooEFojnQAW0Q1iMx5oXyOa39RhvgF HA== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2120.oracle.com with ESMTP id 2u9pjqwtur-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 16 Aug 2019 02:13:46 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7G2D5aQ169960;
	Fri, 16 Aug 2019 02:13:46 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3030.oracle.com with ESMTP id 2udgr2br7w-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 16 Aug 2019 02:13:45 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x7G2DTqb018193;
	Fri, 16 Aug 2019 02:13:29 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 15 Aug 2019 19:13:29 -0700
Date: Thu, 15 Aug 2019 19:13:27 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: hch@infradead.org, tytso@mit.edu, viro@zeniv.linux.org.uk,
        linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        fstests <fstests@vger.kernel.org>
Subject: Re: [PATCH RFC 3/2] fstests: check that we can't write to swap files
Message-ID: <20190816021327.GD15198@magnolia>
References: <156588514105.111054.13645634739408399209.stgit@magnolia>
 <20190815163434.GA15186@magnolia>
 <20190815142603.de9f1c0d9fcc017f3237708d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815142603.de9f1c0d9fcc017f3237708d@linux-foundation.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9350 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908160022
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9350 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908160021
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 02:26:03PM -0700, Andrew Morton wrote:
> On Thu, 15 Aug 2019 09:34:34 -0700 "Darrick J. Wong" <darrick.wong@oracle.com> wrote:
> 
> > While active, the media backing a swap file is leased to the kernel.
> > Userspace has no business writing to it.  Make sure we can't do this.
> 
> I don't think this tests the case where a file was already open for
> writing and someone does swapon(that file)?
> 
> And then does swapoff(that file), when writes should start working again?
> 
> Ditto all the above, with s/open/mmap/.

Heh, ok.  I'll start working on a C program to do that.

> Do we handle (and test!) the case where there's unwritten dirty
> pagecache at the time of swapon()? Ditto pte-dirty MAP_SHARED pages?

One of the tests I wrote for iomap_swapfile_activate way back when
checks that.  The iomap version calls vfs_fsync, but AFAICT
generic_swapfile_activate doesn't do that.

--D

