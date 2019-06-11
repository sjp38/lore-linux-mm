Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D6EDC43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 04:02:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A8722080A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 04:02:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="V149dt1z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A8722080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA5E96B0010; Tue, 11 Jun 2019 00:02:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A563F6B0266; Tue, 11 Jun 2019 00:02:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96B136B0269; Tue, 11 Jun 2019 00:02:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 61E9C6B0010
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 00:02:03 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id r142so7432302pfc.2
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 21:02:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=6nlMSeiHXuaAoKt04VW27Qxb3rdRfOkxL7bmQeftPRU=;
        b=qJYg7Xvf+gUek1OxvvAwTNeJN0mLVU20pMAgz5XwYYg8TQnHdzOVK9VivbRwMJepuy
         TBA2CIn0cAMyV7v6OlHMjhM6SnEE5vgXsy57mTBo5rrZ7z0hDkbFAblCF13NeF88j4Oi
         PK3DeAvu1jftuKQe99yXNECSvHgG4kb9KudOaxt35IUiXoeNKhAOB0Unhr1XX+icdKqH
         mUq5iLWm+3tGxoxy4+wy4oQ/4EFUYJ73k3lag46P2CDQ89WjwhvEXMlQw2K98yYgoABt
         2YE+Zz55/qtRcTAR5iG4MJzcC80+Bi2SL7ZZlSxilRr6GGj1GKLz17c+S244TRYCVbMK
         8lOw==
X-Gm-Message-State: APjAAAUmlntGCBed92y/TvGEo+/oNvGiElNiKNyxFRaS05FtrT1cb+hE
	H5oULe85RL9fnL5XjLyhpmkL0yAAD6jDUrGec3x7lghrsa+6VBsEyM+7hj5emeOGf93Hu2yX4u6
	a4C2/J0g28AEbLY1EvGj1RQy7IgwDqqKoNj0lgBI1V9QYoidlhtctuOEGHgP9SCOQFQ==
X-Received: by 2002:a63:441c:: with SMTP id r28mr18577527pga.255.1560225722861;
        Mon, 10 Jun 2019 21:02:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDMkAK42I9EVPdSqi3wNGKsfasE08wHetZGTGZthXAP8oYATA/n+k4l/zX6jICmz0RsdOj
X-Received: by 2002:a63:441c:: with SMTP id r28mr18577476pga.255.1560225721964;
        Mon, 10 Jun 2019 21:02:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560225721; cv=none;
        d=google.com; s=arc-20160816;
        b=HIjMklPUNvHZaU7U7FP22lFVt43dxYNDnFGF3fHypESECJJn3w+1e1Gj6X8/5VdvRs
         NLqxS+aq/rNEyQP1MFWEmuGLP6yHlqhyFztCSrfm0G8WhXglP9/KqVkTrurkohgD/Vbz
         IfDXc4dPOaOKqleQiNpGg2jgc/697U7e2iv6keWyt61Dri7R5mI4G8B3ZIjNLNEo8AHv
         35Ifu11DB2uOzpKviRfCatJ3LjXkW13TVlf0F0ZVXS5yNI0wu1fwPto2tBAQYoFFOyPl
         EhI/FGNfhzL3R8yLT7S9eygNymiyVU2Sp+Jh/d2LaCmyN1urejxleeaodO6bxsQST28K
         PczQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=6nlMSeiHXuaAoKt04VW27Qxb3rdRfOkxL7bmQeftPRU=;
        b=gyH7UJt7XSOjZeI+eZoLYLxx87pvF+SJX0f+wxppt+To9JRsxuG3ftaz8S88mhxdOu
         byLlJ7aRtSjp3WnOSoNGv2/SMZ1/BWH7bvZJmisC2wAEi0QnNca9elbcITsCg7nlLEpL
         q8DlcnKh9aBGAzUnDuowQOj5wxRV+FwEJt9/TNGvD1Nmls01sdHl6ZlXLeLam6DYjXsk
         Ja2MHA09u6hX1cGykBVNq/ZWT3AfG8EQGJfjcD8fGHuEYTgo2M8XAH2KTB+xZ4Z6u+Vy
         eWC3gnKrYFrD8IeljKrxt374/hPa1pRl3NuU08etNf1Hd7Cet+JtMrBdbnzPA/VvqsUq
         TBYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=V149dt1z;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id d5si12717482pfc.131.2019.06.10.21.02.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 21:02:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=V149dt1z;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5B3xS3t127380;
	Tue, 11 Jun 2019 04:02:01 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=6nlMSeiHXuaAoKt04VW27Qxb3rdRfOkxL7bmQeftPRU=;
 b=V149dt1zKjTA5ARNFnvnnFWV0docEvxmTSemcrCOFNTBc7a30mdN9ueFKeqUrC1M/bpR
 fs01vi/l+hr8Am8PGvYC/C9oW1KA3/QUskLjHaqodZ9gVJw7TY0j0oz/TVgZjXO2neIC
 8TyBZsoQzeZEQZ8RdrR62+jG2flGbpF07ES67pgYg5kSLy9cBSE24h3xZP0eJgV2Onhx
 eHOipnR7wZRvvze+b39WADeDfrjEDALm3zOjfPeQSv7OBMbYphu7c4rrH+vULUHcw9y6
 vW1T/SkAr/raAloXc48bVr+mxjnTj3wW7Ryq82eyxY8UfJGfUbaEqnevwzqpzUVsoEUD tQ== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2t04etjfgn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 04:02:01 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5B41F1h078043;
	Tue, 11 Jun 2019 04:02:00 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3030.oracle.com with ESMTP id 2t024u63pf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 04:02:00 +0000
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5B41xkA029089;
	Tue, 11 Jun 2019 04:01:59 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 10 Jun 2019 21:01:59 -0700
Date: Mon, 10 Jun 2019 21:01:57 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: "Theodore Ts'o" <tytso@mit.edu>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: [PATCH 1/8] mm/fs: don't allow writes to immutable files
Message-ID: <20190611040157.GC1872258@magnolia>
References: <155552786671.20411.6442426840435740050.stgit@magnolia>
 <155552787330.20411.11893581890744963309.stgit@magnolia>
 <20190610015145.GB3266@mit.edu>
 <20190610044144.GA1872750@magnolia>
 <20190610131417.GD15963@mit.edu>
 <20190610160934.GH1871505@magnolia>
 <20190610204154.GA5466@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190610204154.GA5466@mit.edu>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906110026
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906110026
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 10, 2019 at 04:41:54PM -0400, Theodore Ts'o wrote:
> On Mon, Jun 10, 2019 at 09:09:34AM -0700, Darrick J. Wong wrote:
> > > I was planning on only taking 8/8 through the ext4 tree.  I also added
> > > a patch which filtered writes, truncates, and page_mkwrites (but not
> > > mmap) for immutable files at the ext4 level.
> > 
> > *Oh*.  I saw your reply attached to the 1/8 patch and thought that was
> > the one you were taking.  I was sort of surprised, tbh. :)
> 
> Sorry, my bad.  I mis-replied to the wrong e-mail message  :-)

Also ... after flailing around with the v2 series I decided that it
would be much less work to refactor all the current implementations to
call a common parameter-checking function, which will hopefully make the
behavior of SETFLAGS and FSSETXATTR more consistent across filesystems.

That makes the immutable series much less code and fewer patches, but
also means that the 8/8 patch isn't needed anymore.

I'm about to send both out.

--D

> > > I *could* take this patch through the mm/fs tree, but I wasn't sure
> > > what your plans were for the rest of the patch series, and it seemed
> > > like it hadn't gotten much review/attention from other fs or mm folks
> > > (well, I guess Brian Foster weighed in).
> > 
> > > What do you think?
> > 
> > Not sure.  The comments attached to the LWN story were sort of nasty,
> > and now that a couple of people said "Oh, well, Debian documented the
> > inconsistent behavior so just let it be" I haven't felt like
> > resurrecting the series for 5.3.
> 
> Ah, I had missed the LWN article.   <Looks>
> 
> Yeah, it's the same set of issues that we had discussed when this
> first came up.  We can go round and round on this one; It's true that
> root can now cause random programs which have a file mmap'ed for
> writing to seg fault, but root has a million ways of killing and
> otherwise harming running application programs, and it's unlikely
> files get marked for immutable all that often.  We just have to pick
> one way of doing things, and let it be same across all the file
> systems.
> 
> My understanding was that XFS had chosen to make the inode immutable
> as soon as the flag is set (as opposed to forbidding new fd's to be
> opened which were writeable), and I was OK moving ext4 to that common
> interpretation of the immmutable bit, even though it would be a change
> to ext4.
> 
> And then when I saw that Amir had included a patch that would cause
> test failures unless that patch series was applied, it seemed that we
> had all thought that the change was a done deal.  Perhaps we should
> have had a more explicit discussion when the test was sent for review,
> but I had assumed it was exclusively a copy_file_range set of tests,
> so I didn't realize it was going to cause ext4 failures.
> 
>      	    	       	   	 - Ted

