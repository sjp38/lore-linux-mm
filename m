Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C608EC32757
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 18:00:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 751BB214C6
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 18:00:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="txtm+14G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 751BB214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC3826B0003; Wed, 14 Aug 2019 14:00:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D74016B0005; Wed, 14 Aug 2019 14:00:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C62F76B0007; Wed, 14 Aug 2019 14:00:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0081.hostedemail.com [216.40.44.81])
	by kanga.kvack.org (Postfix) with ESMTP id A45DF6B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 14:00:44 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 5EEB26118
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 18:00:44 +0000 (UTC)
X-FDA: 75821798808.30.curve32_5dadbb2d5c92a
X-HE-Tag: curve32_5dadbb2d5c92a
X-Filterd-Recvd-Size: 6384
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com [209.85.215.195])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 18:00:43 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id n190so12655735pgn.0
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 11:00:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=dOMdAe6AqeWQZHyQVAAMCKAQHRACwZHKY6wC0SFV1+U=;
        b=txtm+14GF2FCSoDvBp13P47mYXIYr8VsHkaLQ9+qzdynxVrPmEdrI3/VF89cQ40aHO
         oxgSbC3sqrQqx4xtNgEWud9V7Y4Dwtgcs6TVrtMZcHWviQjqMfZK0m7rwk7t1BmWhL7L
         jWgqAFWfDcXmgPVogpvNZ1QoXmGGaF/uugJYIukTmXWp8cMQSuxBrfSLITM80ysXXMT3
         oWiTb+hlXjbV3rib2xR5s/FAWi4i3cAD/CvYQEfnRmwJ2sSeajSsXWxylBCiLmiZ4aPT
         c1/PlQHMFj3pkkIDK6pLYs3vrH9UYO5JkL3zkEzOVg8YFl/aVm51r/jjD2V+EuNOMKgA
         PQhQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=dOMdAe6AqeWQZHyQVAAMCKAQHRACwZHKY6wC0SFV1+U=;
        b=IhXzATjxsldsJXyJgF8frQF0cDDkRDpBse160sMIEEZ01m9A5hRL7JWaAJQoYHOnTg
         +nbVgRCKJPbaWgFXSkbvGiBpvNIWV8RgJQBjOTEcvfaxjm4BE07Mf+Bp99YOSg615NCo
         opTbDp1AS4p2dFYRRMWj/FbRG4xp0mxd9uuVrx+HIX8yP3bE3HCT6EGkJJzWqI36eLKV
         2xCMvdF2qj+edwJ0dapdtnJ8OlLhl7St9SWpxW29SHQvh2qf9LBfr7mXxKu+OE3vIa/q
         OKlDeF9VldTM1Tpi7t8/Lb/0aS8tYFdUCZzNEty0EFK4oKBUW4eaL8a0DgTR3XFCdR6u
         VmiA==
X-Gm-Message-State: APjAAAU/tzfjPMWVMBL4kfBCEdljkdOVcJhnRbA1QrNkRXW3hBfTB3zM
	h1ellm9Jx1iVrHNTYV5KgD8=
X-Google-Smtp-Source: APXvYqwQ2VCcn8bkJMBj4iGZSuOaB8ioPvLpamL0svo5YO/TVOQJzbQnplGw8s1N9sXKwpH97HUlUA==
X-Received: by 2002:a17:90a:fe01:: with SMTP id ck1mr866293pjb.89.1565805642428;
        Wed, 14 Aug 2019 11:00:42 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.36])
        by smtp.gmail.com with ESMTPSA id x25sm527942pfa.90.2019.08.14.11.00.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Aug 2019 11:00:41 -0700 (PDT)
Date: Wed, 14 Aug 2019 23:30:31 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dimitri Sivanich <sivanich@hpe.com>, jhubbard@nvidia.com,
	gregkh@linuxfoundation.org, arnd@arndb.de, ira.weiny@intel.com,
	jglisse@redhat.com, william.kucharski@oracle.com, hch@lst.de,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel-mentees@lists.linuxfoundation.org
Subject: Re: [Linux-kernel-mentees][PATCH v5 1/1] sgi-gru: Remove *pte_lookup
 functions, Convert to get_user_page*()
Message-ID: <20190814180031.GB5121@bharath12345-Inspiron-5559>
References: <1565379497-29266-1-git-send-email-linux.bhar@gmail.com>
 <1565379497-29266-2-git-send-email-linux.bhar@gmail.com>
 <20190813145029.GA32451@hpe.com>
 <20190813172301.GA10228@bharath12345-Inspiron-5559>
 <20190813181938.GA4196@hpe.com>
 <20190814173034.GA5121@bharath12345-Inspiron-5559>
 <20190814173830.GC13770@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190814173830.GC13770@ziepe.ca>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 02:38:30PM -0300, Jason Gunthorpe wrote:
> On Wed, Aug 14, 2019 at 11:00:34PM +0530, Bharath Vedartham wrote:
> > On Tue, Aug 13, 2019 at 01:19:38PM -0500, Dimitri Sivanich wrote:
> > > On Tue, Aug 13, 2019 at 10:53:01PM +0530, Bharath Vedartham wrote:
> > > > On Tue, Aug 13, 2019 at 09:50:29AM -0500, Dimitri Sivanich wrote:
> > > > > Bharath,
> > > > > 
> > > > > I do not believe that __get_user_pages_fast will work for the atomic case, as
> > > > > there is no guarantee that the 'current->mm' will be the correct one for the
> > > > > process in question, as the process might have moved away from the cpu that is
> > > > > handling interrupts for it's context.
> > > > So what your saying is, there may be cases where current->mm != gts->ts_mm
> > > > right? __get_user_pages_fast and get_user_pages do assume current->mm.
> > > 
> > > Correct, in the case of atomic context.
> > > 
> > > > 
> > > > These changes were inspired a bit from kvm. In kvm/kvm_main.c,
> > > > hva_to_pfn_fast uses __get_user_pages_fast. THe comment above the
> > > > function states it runs in atomic context.
> > > > 
> > > > Just curious, get_user_pages also uses current->mm. Do you think that is
> > > > also an issue? 
> > > 
> > > Not in non-atomic context.  Notice that it is currently done that way.
> > > 
> > > > 
> > > > Do you feel using get_user_pages_remote would be a better idea? We can
> > > > specify the mm_struct in get_user_pages_remote?
> > > 
> > > From that standpoint maybe, but is it safe in interrupt context?
> > Hmm.. The gup maintainers seemed fine with the code..
> > 
> > Now this is only an issue if gru_vtop can be executed in an interrupt
> > context. 
> > 
> > get_user_pages_remote is not valid in an interrupt context(if CONFIG_MMU
> > is set). If we follow the function, in __get_user_pages, cond_resched()
> > is called which definitly confirms that we can't run this function in an
> > interrupt context. 
> > 
> > I think we might need some advice from the gup maintainers here.
> > Note that the comment on the function __get_user_pages_fast states that
> > __get_user_pages_fast is IRQ-safe.
> 
> vhost is doing some approach where they switch current to the target
> then call __get_user_pages_fast in an IRQ context, that might be a
> reasonable pattern
> 
> If this is a regular occurance we should probably add a
> get_atomic_user_pages_remote() to make the pattern clear.
> 
> Jason

That makes sense. get_atomic_user_pages_remote() should not be hard to
write. AFAIKS __get_user_pages_fast is special_cased for current, we
could probably just add a new parameter of the mm_struct to the page
table walking code in gup.c

But till then I think we can approach this by the way vhost approaches
this problem by switching current to the target. 

Thank you
Bharath

