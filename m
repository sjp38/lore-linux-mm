Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BF7DC4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 03:26:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A12442086D
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 03:26:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="lTw3n6sf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A12442086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D5C46B0005; Mon, 10 Jun 2019 23:26:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0874B6B000D; Mon, 10 Jun 2019 23:26:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8FCE6B0010; Mon, 10 Jun 2019 23:26:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B19696B0005
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 23:26:12 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id b127so8659270pfb.8
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 20:26:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+KMHTpIPHehmYr7PrnoKeQGFw46qVIvlu8jfHMIONJs=;
        b=Wey2Nmz50bAbbHgcP3D5GBAIwFTGiawVCzbEZP1ma8AJISHcL+lTpYj7haymcU4wkj
         63IZ7YPovPf6ZJVQ0Vs3Bi3MK2m2JEM8YRwOaBtdUjoqq/uJR9wjbniHpf/ZyefNVKJr
         WzBFemD81+dyw2mwubQ8rb3Xc4s7TazQj0QFfYHwVsI7YBSkNFSO5kBlssuOnl3GsVrW
         jFKfnLyVnpoaK324JFt+5Dtysbk/bc/Z2ORsPe75zmiUxr6GUrycdWPdgm5zn0B9opRU
         BcJkSJpxb05OT4fNg5l4jB0+hlzAFCqOrgP8Y2fGcFJjGToTePYDeHHku7SPYgLWt0qj
         Bh8Q==
X-Gm-Message-State: APjAAAUIJ7AkHpQt3R43WO4CHep3Qokngkth/CMpo8J8k0YDdqz51uNJ
	Vcc6eTeTkdoW2Em5L/9XXDoJhEai7f1uZ9uuiKcgX+3K+Lbeq4PuFRjx2JntONymeSnTVxmKk/U
	kP/rCYgXJ4GdSiOHsTbbDYuwh9Hq/zDcRkWxdP5z4rLJSUhbdhSSgXZ+odIvZK+Z05Q==
X-Received: by 2002:a63:445b:: with SMTP id t27mr18334116pgk.56.1560223572004;
        Mon, 10 Jun 2019 20:26:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyffavA7T0cibQA2qS2Ku/uuso+QN4Ugl5OpMhM11cR5YLtFad1BGKs2j/tVKG98Z2fb+47
X-Received: by 2002:a63:445b:: with SMTP id t27mr18334068pgk.56.1560223570894;
        Mon, 10 Jun 2019 20:26:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560223570; cv=none;
        d=google.com; s=arc-20160816;
        b=UOfTsW208veuA3eAVtdRDB2bJsBNRcbecRTAdHt1UVSjqat80157HslC9NtYjiosIM
         eyYmw5mxgzs3a8CGB0k+f4jMoztNDIiM50XpyMpoFL32QeHH86bkIOtJekpG1we1K0cD
         7YxwXkU9fvexQtTfd8xEiGpM4YwXz+ma/gKEGSpux1UGpuduDoVwajfgljDVl7ZJTpaR
         +YyMOMlUnSIcJ2K6ur4WrurAeB4ZvCAp10saGoG0ZFaJIoPdtNouEWD6huoU7p2ptiyc
         nooOzRSuIz9vXfX2+8eXkyCZfE4p1zIruq5h4xulxGig2e2n4BBgMj5iumnKwAirg1Z9
         TwDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+KMHTpIPHehmYr7PrnoKeQGFw46qVIvlu8jfHMIONJs=;
        b=lGYKc2JAqkd9zibiyqc7lU9/XmuaXArGEEBxWlSLvtiJ2C/gVhbGyhUaMKCJsFMrQg
         KZzRxEH0DG1HNu8WJ/QV34k63T7KY5ksfrvD6zgy1P916FwX5VVgsscy1opmex4+QPL3
         /G800yKXopna2/S09rxRyJQ6zGjYoG9R7qGIfYTAjUNH3G7r3in3sos36C5fiXeh5bpt
         vW3loFnAt8kJvmXLLOJHgPg6Wg1XO1IBFXOqyBb93EQlJK2XGVaywEID6zRwaSPIsI0K
         9tWsGsXpZnHGup+MiLIDHLUtiBI44V4tf8Y+ClC4m9v17/2SkbpswcXR44/zmEaYLXXm
         SC4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=lTw3n6sf;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id a12si11368791pgl.178.2019.06.10.20.26.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 20:26:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=lTw3n6sf;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5B3JYbq122570;
	Tue, 11 Jun 2019 03:26:09 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=+KMHTpIPHehmYr7PrnoKeQGFw46qVIvlu8jfHMIONJs=;
 b=lTw3n6sfAuJxerQIcWvvAzMYQN+AqtCPDfst2dOgTcdT2K7l70GXNYMqGHsNnCdk6wWJ
 c7B8KxtKCiw/HIyg0TzHinvugM77U16TWDIV4RUqydwstE2v/O6WmbklmNTHt9ONL6Hf
 8nix+RvdOj4fFnrZWzqEqBGocz0+c/cYECmtDtfNx42zPkkJePXJWXe7Hh7CPw4YOW9s
 4yqshFav8Do/yNkdOJCBXL2mI4X3yT493ZlzXH1rdALCUQWxVW53N8gWI7PU+/0hSDva
 e/vYpQcoD4tQPYop3LFIttJa/6DA6+oherOHnagItEI4/fDKCBn6gnQuy8H0a/HVH5Zq ug== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2130.oracle.com with ESMTP id 2t02hejhjw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 03:26:09 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5B3Q8lN021788;
	Tue, 11 Jun 2019 03:26:09 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3020.oracle.com with ESMTP id 2t0p9r2a63-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 03:26:08 +0000
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5B3Q4J4008815;
	Tue, 11 Jun 2019 03:26:04 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 10 Jun 2019 20:26:04 -0700
Date: Mon, 10 Jun 2019 20:26:03 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: "Theodore Ts'o" <tytso@mit.edu>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: [PATCH 1/8] mm/fs: don't allow writes to immutable files
Message-ID: <20190611032603.GB1872258@magnolia>
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
 engine=8.0.1-1810050000 definitions=main-1906110021
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906110021
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 11, 2019 at 04:41:54PM -0400, Theodore Ts'o wrote:
> On Mon, Jun 10, 2019 at 09:09:34AM -0700, Darrick J. Wong wrote:
> > > I was planning on only taking 8/8 through the ext4 tree.  I also added
> > > a patch which filtered writes, truncates, and page_mkwrites (but not
> > > mmap) for immutable files at the ext4 level.
> > 
> > *Oh*.  I saw your reply attached to the 1/8 patch and thought that was
> > the one you were taking.  I was sort of surprised, tbh. :)
> 
> Sorry, my bad.  I mis-replied to the wrong e-mail message  :-)
> 
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

<nod> It started as "just do this to xfs" and has now become a vfs level
change...

> And then when I saw that Amir had included a patch that would cause
> test failures unless that patch series was applied, it seemed that we
> had all thought that the change was a done deal.  Perhaps we should
> have had a more explicit discussion when the test was sent for review,
> but I had assumed it was exclusively a copy_file_range set of tests,
> so I didn't realize it was going to cause ext4 failures.

And here we see the inconsistent behavior causing developer confusion. :)

I think Amir's c_f_r tests just check the existing behavior (of just
c_f_r) that you can't (most of the time) copy into a file that you
opened for write but that the administrator has since marked immutable.

/That/ behavior in turn came from the original implementation that would
try reflink which would fail on the immutable destination check and then
fail the whole call ... I think?

--D

>      	    	       	   	 - Ted

