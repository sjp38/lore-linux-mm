Return-Path: <SRS0=3rjY=XO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEE04C4CEC4
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 00:05:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88C90218AF
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 00:05:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="AjqmTn/8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88C90218AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 149686B0313; Wed, 18 Sep 2019 20:05:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FB4B6B0316; Wed, 18 Sep 2019 20:05:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 011056B0318; Wed, 18 Sep 2019 20:05:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0197.hostedemail.com [216.40.44.197])
	by kanga.kvack.org (Postfix) with ESMTP id D5BE86B0313
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 20:05:12 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 6FA8B1F34D
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 00:05:12 +0000 (UTC)
X-FDA: 75949725264.03.name63_4a7727ca19860
X-HE-Tag: name63_4a7727ca19860
X-Filterd-Recvd-Size: 4868
Received: from userp2130.oracle.com (userp2130.oracle.com [156.151.31.86])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 00:05:11 +0000 (UTC)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8J04dNr001766;
	Thu, 19 Sep 2019 00:04:58 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2019-08-05;
 bh=jm76AVvNTRqXzomI5+75pr5R8Jjx/ucZQga7UMnCvc0=;
 b=AjqmTn/8H1RNTeog5qLark8dNi12SiveW0xvyhRgGcR1Qx+/dYTSCeaD9V2eXBLXr2PR
 x+bOvCUgdbG9Dnnb2mI6mxbY+6zL6dS2QCASwZYRvRR273sPKw7Cb8IwAPLSgE3kwHxD
 p66610os/SC4qzO4zXziZSLth8I8Q2BgJWCwbiUFu2RqlJ6OZYmLTKAxmjlYdTJt0djt
 BnDld+ECdj1hpH8fghgVznoEn1or+Ib+4D8bCCmfR5JcEtMuARPw3R5Yt6pZLRfesUmd
 bEZAlCd0311OXF4v1rhvGgk8NYqQg4ZEUuex8Nnx0pJGDyexdg9AiI98pKKsndKZyjgy iw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2v3vb50ftc-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 19 Sep 2019 00:04:58 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8J043hl151174;
	Thu, 19 Sep 2019 00:04:57 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2v3vbqxe3y-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 19 Sep 2019 00:04:57 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x8J04tFl008989;
	Thu, 19 Sep 2019 00:04:55 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 18 Sep 2019 17:04:55 -0700
Date: Wed, 18 Sep 2019 17:04:54 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, hch@lst.de, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 2/5] mm: Add file_offset_of_ helpers
Message-ID: <20190919000454.GI2229799@magnolia>
References: <20190821003039.12555-1-willy@infradead.org>
 <20190821003039.12555-3-willy@infradead.org>
 <20190918211755.GC2229799@magnolia>
 <20190918234924.GE9880@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190918234924.GE9880@bombadil.infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9384 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=985
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1908290000 definitions=main-1909180204
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9384 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1908290000
 definitions=main-1909180204
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[add dave to cc]

On Wed, Sep 18, 2019 at 04:49:24PM -0700, Matthew Wilcox wrote:
> On Wed, Sep 18, 2019 at 02:17:55PM -0700, Darrick J. Wong wrote:
> > On Tue, Aug 20, 2019 at 05:30:36PM -0700, Matthew Wilcox wrote:
> > > From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> > > 
> > > The page_offset function is badly named for people reading the functions
> > > which call it.  The natural meaning of a function with this name would
> > > be 'offset within a page', not 'page offset in bytes within a file'.
> > > Dave Chinner suggests file_offset_of_page() as a replacement function
> > > name and I'm also adding file_offset_of_next_page() as a helper for the
> > > large page work.  Also add kernel-doc for these functions so they show
> > > up in the kernel API book.
> > > 
> > > page_offset() is retained as a compatibility define for now.
> > 
> > No SOB?
> > 
> > Looks fine to me, and I appreciate the much less confusing name.  I was
> > hoping for a page_offset conversion for fs/iomap/ (and not a treewide
> > change because yuck), but I guess that can be done if and when this
> > lands.
> 
> Sure, I'll do that once everything else has landed.

You might also want to ask Dave Chinner what changes he's making to
iomap to support blocksize > pagesize filesystems, since that's
/definitely/ going to clash. :)

--D

