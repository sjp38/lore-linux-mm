Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62CABC43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 02:50:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2BC82147A
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 02:50:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="tEOHWeps"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2BC82147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42F186B0003; Mon, 29 Apr 2019 22:50:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3CD9E6B0005; Mon, 29 Apr 2019 22:50:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A75F6B0007; Mon, 29 Apr 2019 22:50:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id E4F566B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 22:50:39 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x2so8324751pge.16
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 19:50:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=7f8at92urxBnhxmK5RisQak2n2RS9MsVx744PF44sMk=;
        b=JJyikkpfm9faBgB+Cnr+BvEIwRHRH14ocPD7fy/neVNteT1Z1YQfVdcZO3OW94qE/0
         3Hnav3l6ikX62RLn3jWEghSQ/ERNxPY0EWI6plQj68WKyEDzpYJ87WLCnF+MRQvTv9tm
         HS8/k0+ec26gibsc4iqRh2eHom+mt9Jus5ZbRFy37mnq5MxUCRpJtjEgoafzPs+CkOj/
         Uwc+0iIYzgr0M3mEHS+KYc+x0OfTzOpdNNE01N6Z9MChMl0iRrvwU/LLXClRwSjQ80o4
         H+MtkE2RNBY04Ohos/iofLP3EfqgugBJts1T6Ghem4FSgEhCqBJmxjuiyITMRQoYmkfF
         GiEw==
X-Gm-Message-State: APjAAAV35NLo4j8Z9aN0v/b+zO6NAbErkB5yt2GsUan3cf8+1F7qUfi4
	wyAMtqCpXcKUqCARTmw8UMmNwCXulEIZTb6uFabShliXK08TQis/7XY4p7I8y0iQLWUBs2qQipx
	x08X8m9xfeslkUI2dEevDsG1dOMiHzNAtuReiXk9mSYonBmEZ1e5QEtsCisyDU05g2Q==
X-Received: by 2002:a63:d908:: with SMTP id r8mr30592980pgg.268.1556592639504;
        Mon, 29 Apr 2019 19:50:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzM4BaowMspIGXqEKSsdH5nhSU4NtxfWoxYN3Gd4eZYaGbQHFrWKdbWMr+9JH5+XlZCVhNF
X-Received: by 2002:a63:d908:: with SMTP id r8mr30592931pgg.268.1556592638596;
        Mon, 29 Apr 2019 19:50:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556592638; cv=none;
        d=google.com; s=arc-20160816;
        b=ytnYV/Uu+Rji+JhYsRqj3F2uCvnEdIGNovqhq7ylHxjssd5OxkXaaCoADSGCoCxoXw
         7WGf+lutJgqRV6reVC4pY0CAUe03+h42MWZ6nfWhaLxro9pdb0Q6RcnPM3a4btQjCec5
         eJQ9OeFLv+S+D5m4Kgrnt/M709W1feunUUR+BefAHhuaLz96FIC6D2sesLNzl2PQo3u9
         F95r7p3LBrkpt7STK5xTUMHNuF8KLaFIzS7VXZzuh4ksA8dQwK419PyC8Xff6EZnDRqb
         x31ujorOsWzCh6GZa2pL+AESCbjKnOq8L4D6N33fcFlnhZaEoVNKdo06q+6DquHvubGI
         E/mA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=7f8at92urxBnhxmK5RisQak2n2RS9MsVx744PF44sMk=;
        b=ecYwN53VD2eUZYgO6YDGlHV/ucrPAw6tJYmYpXb7iX7fjbDmxb5/Mzc3jmld+XRba5
         BjpbHgNXHJBUdEhF1pnXg3vAgdh33hsQNCVQ1ixU0nwXQXMtEMBV8kFAdwfvsyISdWzc
         a8DKVzz3GceZUCscWJqeFIbbc9gJhdndyp71b0UYpqGCAJ7ZV4CcRrjp/dFCBFb4TmMi
         Vv8dFJNGIGVocFVZ9bCTQewET+ZOZbAvmN9czqYjnmJ6/ksM74pwrDb3/1ACXR541v8/
         JPrd6AIw3FHenFn6jC4HBCD0RPg5OyDQc5+cZfhsmuuhefo1v0txzErY7l7qzDTiU6yL
         taSg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=tEOHWeps;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id a3si20716840pgm.455.2019.04.29.19.50.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 19:50:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=tEOHWeps;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3U2hrVn113580;
	Tue, 30 Apr 2019 02:50:35 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=7f8at92urxBnhxmK5RisQak2n2RS9MsVx744PF44sMk=;
 b=tEOHWepsllY8/YH2O39+c80pQXQZormVpmCTu6IN1mkJdkXLA4j9hQfcJj3BkSMIO5pb
 z+0zYJD4l84BmJDCrvvvmdkcduQR6n6wAnUjgiAchCrTbtPE2GuOfxPP+0LqJ+3LaUO7
 cgmMpp+EKqCtDQZsZ508qywYwdOY8DaD5lf3vOfzoziE7QOTj5UYPWahChumAzhcYOX1
 xrDyrKV/KJ0rBD2DAso8InNIlQFwqLrsiPEcsAMe4PPrvaw36c4RMrpNsSwVAfUVmp9i
 tobttfcBOUbFm6eFpQWVdhr8bt1sGfZIxu/a66N1MYqq33HwVfzxgwpWhT9ZvkaavTdX HQ== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2s4fqq1r0k-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 30 Apr 2019 02:50:35 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3U2mjab127419;
	Tue, 30 Apr 2019 02:50:34 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2s4d4a8xuu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 30 Apr 2019 02:50:34 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x3U2oUIM027571;
	Tue, 30 Apr 2019 02:50:30 GMT
Received: from localhost (/10.159.138.192)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 29 Apr 2019 19:50:30 -0700
Date: Mon, 29 Apr 2019 19:50:28 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: cluster-devel@redhat.com, Christoph Hellwig <hch@lst.de>,
        Bob Peterson <rpeterso@redhat.com>, Jan Kara <jack@suse.cz>,
        Dave Chinner <david@fromorbit.com>,
        Ross Lagerwall <ross.lagerwall@citrix.com>,
        Mark Syms <Mark.Syms@citrix.com>,
        Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v7 0/5] iomap and gfs2 fixes
Message-ID: <20190430025028.GA5200@magnolia>
References: <20190429220934.10415-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190429220934.10415-1-agruenba@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9242 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904300017
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9242 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904300017
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 12:09:29AM +0200, Andreas Gruenbacher wrote:
> Here's another update of this patch queue, hopefully with all wrinkles
> ironed out now.
> 
> Darrick, I think Linus would be unhappy seeing the first four patches in
> the gfs2 tree; could you put them into the xfs tree instead like we did
> some time ago already?

Sure.  When I'm done reviewing them I'll put them in the iomap tree,
though, since we now have a separate one. :)

--D

> Thanks,
> Andreas
> 
> Andreas Gruenbacher (4):
>   fs: Turn __generic_write_end into a void function
>   iomap: Fix use-after-free error in page_done callback
>   iomap: Add a page_prepare callback
>   gfs2: Fix iomap write page reclaim deadlock
> 
> Christoph Hellwig (1):
>   iomap: Clean up __generic_write_end calling
> 
>  fs/buffer.c           |   8 ++--
>  fs/gfs2/aops.c        |  14 ++++--
>  fs/gfs2/bmap.c        | 101 ++++++++++++++++++++++++------------------
>  fs/internal.h         |   2 +-
>  fs/iomap.c            |  55 ++++++++++++++---------
>  include/linux/iomap.h |  22 ++++++---
>  6 files changed, 124 insertions(+), 78 deletions(-)
> 
> -- 
> 2.20.1
> 

