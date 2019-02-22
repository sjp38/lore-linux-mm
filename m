Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 360F2C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 15:12:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F10C22075C
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 15:12:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F10C22075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8599A8E010F; Fri, 22 Feb 2019 10:12:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E0318E0109; Fri, 22 Feb 2019 10:12:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A9078E010F; Fri, 22 Feb 2019 10:12:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3E98C8E0109
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 10:12:09 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id s8so2255443qth.18
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:12:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=7aB/mHvzoTyiwek2wCX+dYKp7fcLL5P9GD+fSb71sn4=;
        b=mPPlnywAeKI8obhLKju1uGWjJaSvTJ2YDS4Q9pXYS6BNjwJ3VlTQpBotKOPenzDu0z
         jyFKuT0cJsoQyslCTW6mlvHInJx2KvxT1H5kpJsAapcdktmmLJwvwUFbH4/kkc1EBtR3
         C6wV1QwY8HD7EcjxaefOeKlR6pWag/QGOmz2H1L1xX93q0n48sUTZPsPqznKGD1024CD
         I3NIOCptQyN6p1We0DnAp6h0Xqg1+sT0rxujn4z7a9boLitvcVckIlTwD2BpwaVZE2E7
         xMD6AV8QRmT0RQiU9oRy/2e188bf4BhhgJEC4FGDWaCim2dKvLCqc1MvOjd2k96KyPAJ
         nuTg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZ3KhryXXccWe8Nknc5dnLuu6Vvex6m9K8Myd3ibxCBtijf0J+e
	EIdiduvJAbBHx9gT2eeDBkMb40z96sx0+gUdZB8REGMsNDlHnMbba32iGIHqMK2jS/Mpp0kK0Uq
	LRoILA9s/ulCAQ4T3qFE4MJOUJq3RRXZPs1m5uXMcHaYVptqhW+IjVOOizBq7mJGjKA==
X-Received: by 2002:ac8:3fd4:: with SMTP id v20mr3366056qtk.188.1550848328932;
        Fri, 22 Feb 2019 07:12:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IamXpQbLwJa2d7ul1cw6DKNKPueTgLmsPehlOjCDL+PKa6ie4OhRVsPWnq1L2Jk+2eMpReh
X-Received: by 2002:ac8:3fd4:: with SMTP id v20mr3365980qtk.188.1550848327835;
        Fri, 22 Feb 2019 07:12:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550848327; cv=none;
        d=google.com; s=arc-20160816;
        b=suoYJgoC0ncUXcUFXPIALwpwOuP4IAUr7a4v30wLR6RsuaWtNyjQYz0Dn8yNlgQIgg
         0elIDf/josvcN94/2QddYUgRPUaVE71q5TKgcUz/cKHrGycHoSz1Mne1NHz8kUH9KTHM
         89MiUjgbc1nYMNBKs/k5n/1lVylJQ+1Mvl4Ym9oJgGusDZdQennXntLv6D5gGkhWg7hi
         FBdYKcTiIp7ulQhkDa6f4mC8I62SBxgdxksfp8+mzwCCYWD1LDqT30hpTl2XbCoaK78e
         M/4tcn0+HIRN9AR09obgyj97PJgAamExWRReDVwfGtKaIsRZk0rzbGiTs1YJ91IfNFc/
         O/lw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=7aB/mHvzoTyiwek2wCX+dYKp7fcLL5P9GD+fSb71sn4=;
        b=X7A22psZTFWZlavfjGbOAW8UIt/RMUn23tCI4jnRWaiYw66p/bbFDBMakcPRz4FD8x
         BHqIRZX2JM52OVYSkuQiaQ0hexaTdWU459+lb7TGKuf/cEVOeWiVIHQfWclN0IgDT8fC
         VS+h3fFNAPWzIls0BmE2b/fZxT9ICD1iet9pPv1BHjUAeu+WfCBfXPbd0RxY7t1sruwl
         zocDlmtYbz4pLfK3553e1IaE2mEPGLU84nHJn+TmxfkWoUKob6KT4tTi9KTxpxXaPwpD
         N3VyiY6LVuiFF4BIPr+CtED7e2KSia3aNwU/XdIMuvC8O+tURl9Md9ERAy31wbtwFvLy
         +6QQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g14si1002322qvj.193.2019.02.22.07.12.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 07:12:07 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 82267308FF29;
	Fri, 22 Feb 2019 15:12:06 +0000 (UTC)
Received: from redhat.com (ovpn-126-14.rdu2.redhat.com [10.10.126.14])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1C70B5D9CA;
	Fri, 22 Feb 2019 15:11:59 +0000 (UTC)
Date: Fri, 22 Feb 2019 10:11:58 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2.1 04/26] mm: allow VM_FAULT_RETRY for multiple times
Message-ID: <20190222151101.GA7783@redhat.com>
References: <20190212025632.28946-5-peterx@redhat.com>
 <20190221085656.18529-1-peterx@redhat.com>
 <20190221155311.GD2813@redhat.com>
 <20190222042544.GD8904@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190222042544.GD8904@xz-x1>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Fri, 22 Feb 2019 15:12:06 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 12:25:44PM +0800, Peter Xu wrote:
> On Thu, Feb 21, 2019 at 10:53:11AM -0500, Jerome Glisse wrote:
> > On Thu, Feb 21, 2019 at 04:56:56PM +0800, Peter Xu wrote:
> > > The idea comes from a discussion between Linus and Andrea [1].

[...]

> > > diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> > > index 248ff0a28ecd..d842c3e02a50 100644
> > > --- a/arch/x86/mm/fault.c
> > > +++ b/arch/x86/mm/fault.c
> > > @@ -1483,9 +1483,7 @@ void do_user_addr_fault(struct pt_regs *regs,
> > >  	if (unlikely(fault & VM_FAULT_RETRY)) {
> > >  		bool is_user = flags & FAULT_FLAG_USER;
> > >  
> > > -		/* Retry at most once */
> > >  		if (flags & FAULT_FLAG_ALLOW_RETRY) {
> > > -			flags &= ~FAULT_FLAG_ALLOW_RETRY;
> > >  			flags |= FAULT_FLAG_TRIED;
> > >  			if (is_user && signal_pending(tsk))
> > >  				return;
> > 
> > So here you have a change in behavior, it can retry indefinitly for as
> > long as they are no signal. Don't you want so test for FAULT_FLAG_TRIED ?
> 
> These first five patches do want to allow the page fault to retry as
> much as needed.  "indefinitely" seems to be a scary word, but IMHO
> this is fine for page faults since otherwise we'll simply crash the
> program or even crash the system depending on the fault context, so it
> seems to be nowhere worse.
> 
> For userspace programs, if anything really really go wrong (so far I
> still cannot think a valid scenario in a bug-free system, but just
> assuming...) and it loops indefinitely, IMHO it'll just hang the buggy
> process itself rather than coredump, and the admin can simply kill the
> process to retake the resources since we'll still detect signals.
> 
> Or did I misunderstood the question?

No i think you are right, it is fine to keep retrying while they are
no signal maybe just add a comment that says so in so many words :)
So people do not see that as a potential issue.

> > [...]
> > 
> > > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > > index 80bb6408fe73..4e11c9639f1b 100644
> > > --- a/include/linux/mm.h
> > > +++ b/include/linux/mm.h
> > > @@ -341,11 +341,21 @@ extern pgprot_t protection_map[16];
> > >  #define FAULT_FLAG_ALLOW_RETRY	0x04	/* Retry fault if blocking */
> > >  #define FAULT_FLAG_RETRY_NOWAIT	0x08	/* Don't drop mmap_sem and wait when retrying */
> > >  #define FAULT_FLAG_KILLABLE	0x10	/* The fault task is in SIGKILL killable region */
> > > -#define FAULT_FLAG_TRIED	0x20	/* Second try */
> > > +#define FAULT_FLAG_TRIED	0x20	/* We've tried once */
> > >  #define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
> > >  #define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
> > >  #define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
> > >  
> > > +/*
> > > + * Returns true if the page fault allows retry and this is the first
> > > + * attempt of the fault handling; false otherwise.
> > > + */
> > 
> > You should add why it returns false if it is not the first try ie to
> > avoid starvation.
> 
> How about:
> 
>         Returns true if the page fault allows retry and this is the
>         first attempt of the fault handling; false otherwise.  This is
>         mostly used for places where we want to try to avoid taking
>         the mmap_sem for too long a time when waiting for another
>         condition to change, in which case we can try to be polite to
>         release the mmap_sem in the first round to avoid potential
>         starvation of other processes that would also want the
>         mmap_sem.
> 
> ?

Looks perfect to me.

Cheers,
Jérôme

