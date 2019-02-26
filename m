Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02060C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 07:29:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADC94217F9
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 07:29:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADC94217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46E1C8E0003; Tue, 26 Feb 2019 02:29:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F7978E0002; Tue, 26 Feb 2019 02:29:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 272718E0003; Tue, 26 Feb 2019 02:29:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D867A8E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 02:29:47 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id q21so9788862pfi.17
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 23:29:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=oY843cfEG2wNXx0RKUAsM/iCo0a5eXkPj1HvAC7GcfY=;
        b=LyjHFQGKz29gE+UI5RvzIWameuV7Melph9/+tbhG6Rpuxmkot7D/k48NP/I+LkvKV6
         0tfuDnixAIHL3ZI7BPQrCDSfToHjmuEU2Nu2NN8TG6wfw4W6wAZa9P6D9tzV15JdTcBa
         YaNrBT6DAKhluNgI7ez1mIM7MVVNMG9Hn2Mzk1ARKEooOQKSXlM/EA6J9rX2unvDuyb3
         KocK+luAOlcFXTaH3V/IAIzXwxKlVrTJvMX7MjiiQAdIHJwk3zpFGMTNLsG7oauqDx3V
         Yn02w5YGK5lvdkK9/dxdA3ORklCp4LbWrQrgxrOxYQNNjiZrxLaMNQYxSr8d+OmUy2jP
         ECTw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubP7tvd6F+uqoHQ6Lk+mGjVfo7xaHI6vISxNjWJXW6wNEMKb8Qb
	KbQJA6wjUPb1IUdWYIhont2bhHYFNPJ04MJv6/GzGvlpihr08zo7jKWNCdh6MuZ2VJ/XOexgRg/
	DelDZcKObYhU4mWkSHGZ/oVef4alTe2D190B1vqMeygFKi0eJzDKBGMJAlw5tN83cFQ==
X-Received: by 2002:a65:4284:: with SMTP id j4mr4447734pgp.334.1551166187519;
        Mon, 25 Feb 2019 23:29:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbeFfKBEBz9EmXifSTtx3LxbkJf973/nxAeqMjN5VfGC6zXoNA+NWdRNssGLXVGp3pJwlSS
X-Received: by 2002:a65:4284:: with SMTP id j4mr4447680pgp.334.1551166186463;
        Mon, 25 Feb 2019 23:29:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551166186; cv=none;
        d=google.com; s=arc-20160816;
        b=kNepSxyLc0LdJIqABVDji76gUJG5t2BoWKodaT9I7WQ0+2ep+OX+HmgKd+vFaYXWEx
         LbGG1uCL5/ds5dtZzUH+lLTe6X9ZVkTlx5NwtgEsluUciq11PSbyXWoPYNAC/bCUqyOg
         oo+ED76VnWUnV6bb9CuNYih2URsr61KiMkAY2pqO4p0Ot8Iaun6D8xUDG7NFUliKWlQo
         pPVBzm/VHk8ef7zM6shynH0RdARtDeoo9+q4lIDdS+eokdw2VXXDyXUewnhp+XWLzBzw
         bZFm0cwu2h/4UjOVw4HONxZUBr3kmmNuoTERdwEnWDgJ8rhKSaZMrDHg/EMGAMRlLLqb
         JtVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=oY843cfEG2wNXx0RKUAsM/iCo0a5eXkPj1HvAC7GcfY=;
        b=S7/cA81bcAocZqfHodllmpD0bl4NHrOPgiPxMdec4AxGbPCkyQWMTi5D4hfyECYMa0
         YPVSXPgmLg60PouiRzU2UGkfSoeaUKMM4cLjZjesDZ1tljGBkAZDD8rZG1MFNLp/cVaG
         R1M1e65kQH+x6hNBws0JbWGwzVjuMUZkR7Hzx8ehcZX9tmviyMRlOd3L/3kouAhqV9c8
         4S5ZhylBpFor1lyeCqUe23rgnR/GCS+a/s8m2Buu4Bl08xjlStoF+IbLtAD8X8iVLRoM
         bLXOanSqAdzL+he5qBDOC8iGeKUIbc4CJ0A0rQOut2SlQ9Cow4Lhe1+PVNZ67X1hrNRS
         xdKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v3si12091784plo.147.2019.02.25.23.29.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 23:29:46 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1Q7Tah5094207
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 02:29:46 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qvyr1bxpu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 02:29:45 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 26 Feb 2019 07:29:42 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 26 Feb 2019 07:29:37 -0000
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1Q7Ta4h28115006
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 26 Feb 2019 07:29:36 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B00E2AE058;
	Tue, 26 Feb 2019 07:29:36 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 59744AE045;
	Tue, 26 Feb 2019 07:29:35 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 26 Feb 2019 07:29:35 +0000 (GMT)
Date: Tue, 26 Feb 2019 09:29:33 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        David Hildenbrand <david@redhat.com>, Hugh Dickins <hughd@google.com>,
        Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>,
        Pavel Emelyanov <xemul@virtuozzo.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
        Marty McFadden <mcfadden8@llnl.gov>,
        Andrea Arcangeli <aarcange@redhat.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        Denis Plotnikov <dplotnikov@virtuozzo.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>,
        "Kirill A . Shutemov" <kirill@shutemov.name>,
        "Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 23/26] userfaultfd: wp: don't wake up when doing write
 protect
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-24-peterx@redhat.com>
 <20190225210934.GE10454@rapoport-lnx>
 <20190226062424.GH13653@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226062424.GH13653@xz-x1>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022607-0012-0000-0000-000002FA3BE4
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022607-0013-0000-0000-00002131DE9B
Message-Id: <20190226072933.GF5873@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-26_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902260057
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 02:24:52PM +0800, Peter Xu wrote:
> On Mon, Feb 25, 2019 at 11:09:35PM +0200, Mike Rapoport wrote:
> > On Tue, Feb 12, 2019 at 10:56:29AM +0800, Peter Xu wrote:
> > > It does not make sense to try to wake up any waiting thread when we're
> > > write-protecting a memory region.  Only wake up when resolving a write
> > > protected page fault.
> > > 
> > > Signed-off-by: Peter Xu <peterx@redhat.com>
> > > ---
> > >  fs/userfaultfd.c | 13 ++++++++-----
> > >  1 file changed, 8 insertions(+), 5 deletions(-)
> > > 
> > > diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> > > index 81962d62520c..f1f61a0278c2 100644
> > > --- a/fs/userfaultfd.c
> > > +++ b/fs/userfaultfd.c
> > > @@ -1771,6 +1771,7 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
> > >  	struct uffdio_writeprotect uffdio_wp;
> > >  	struct uffdio_writeprotect __user *user_uffdio_wp;
> > >  	struct userfaultfd_wake_range range;
> > > +	bool mode_wp, mode_dontwake;
> > > 
> > >  	if (READ_ONCE(ctx->mmap_changing))
> > >  		return -EAGAIN;
> > > @@ -1789,18 +1790,20 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
> > >  	if (uffdio_wp.mode & ~(UFFDIO_WRITEPROTECT_MODE_DONTWAKE |
> > >  			       UFFDIO_WRITEPROTECT_MODE_WP))
> > >  		return -EINVAL;
> > > -	if ((uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP) &&
> > > -	     (uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE))
> > > +
> > > +	mode_wp = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP;
> > > +	mode_dontwake = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE;
> > > +
> > > +	if (mode_wp && mode_dontwake)
> > >  		return -EINVAL;
> > 
> > This actually means the opposite of the commit message text ;-)
> > 
> > Is any dependency of _WP and _DONTWAKE needed at all?
> 
> So this is indeed confusing at least, because both you and Jerome have
> asked the same question... :)
> 
> My understanding is that we don't have any reason to wake up any
> thread when we are write-protecting a range, in that sense the flag
> UFFDIO_WRITEPROTECT_MODE_DONTWAKE is already meaningless in the
> UFFDIO_WRITEPROTECT ioctl context.  So before everything here's how
> these flags are defined:
> 
> struct uffdio_writeprotect {
> 	struct uffdio_range range;
> 	/* !WP means undo writeprotect. DONTWAKE is valid only with !WP */
> #define UFFDIO_WRITEPROTECT_MODE_WP		((__u64)1<<0)
> #define UFFDIO_WRITEPROTECT_MODE_DONTWAKE	((__u64)1<<1)
> 	__u64 mode;
> };
> 
> To make it clear, we simply define it as "DONTWAKE is valid only with
> !WP".  When with that, "mode_wp && mode_dontwake" is indeed a
> meaningless flag combination.  Though please note that it does not
> mean that the operation ("don't wake up the thread") is meaningless -
> that's what we'll do no matter what when WP==1.  IMHO it's only about
> the interface not the behavior.
> 
> I don't have a good way to make this clearer because firstly we'll
> need the WP flag to mark whether we're protecting or unprotecting the
> pages.  Later on, we need DONTWAKE for page fault handling case to
> mark that we don't want to wake up the waiting thread now.  So both
> the flags have their reason to stay so far.  Then with all these in
> mind what I can think of is only to forbid using DONTWAKE in WP case,
> and that's how above definition comes (I believe, because it was
> defined that way even before I started to work on it and I think it
> makes sense).

There's no argument how DONTWAKE can be used with !WP. The
userfaultfd_writeprotect() is called in response of the uffd monitor to WP
page fault, it asks to clear write protection to some range, but it does
not want to wake the faulting thread yet but rather it will use uffd_wake()
later.

Still, I can't grok the usage of DONTWAKE with WP=1. In my understanding,
in this case userfaultfd_writeprotect() is called unrelated to page faults,
and the monitored thread runs freely, so why it should be waked at all?

And what happens, if the thread is waiting on a missing page fault and we
do userfaultfd_writeprotect(WP=1) at the same time?

> Thanks,
> 
> -- 
> Peter Xu
> 

-- 
Sincerely yours,
Mike.

