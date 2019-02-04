Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EF59C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 10:50:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F404217D6
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 10:50:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XeCtv/mU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F404217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE28E8E003E; Mon,  4 Feb 2019 05:50:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C694E8E001C; Mon,  4 Feb 2019 05:50:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B33098E003E; Mon,  4 Feb 2019 05:50:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 45E8E8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 05:50:09 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id c5so2414426lfi.7
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 02:50:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=dY3R/Ow+sIeuZQPXwSYWif9PqrB6TJOohx4Dod2DIvA=;
        b=UH84S+LviWxgDe0HB2X5ZALhJrV6W9Er4Cpabub0Th5EILSMeSvWN1D5/J6esM3mhk
         r5N7At/l54t41ZmP1IB/PHD/X0JIEStqECn8sQ/29QReJ2NSYcppPB+zZYgb3XKB5YnJ
         U5QzK0IHVl5RvDqbz6QIo5x8ZyIfDjnHIZKyWWRMLVQ+gtBYbsNa/dyxesThkK0bTP+u
         MMklLqWvV0RXT9eszagnBZsVm59JGCmqeojm66nOzaacsykrC5KDQ89fTtxlhj+P86ya
         01FaRtPK5cW6uHAJua6JTMiG9LvGzjexRIuBhQuYCQF+Ll15JAU4iqOmvrBabg+pqtEl
         GsqA==
X-Gm-Message-State: AJcUukcDNcB6qRhbYmDDKd0xlPAQdOfDiV5bkhwjo+zaXTYuEYiBMqMb
	T/rd09ATmz2l9ybcjUymYnnri3NVRSpZW7Q2UXHreTfYhOp7qiMPk+yBZ+S6KSW8fpLOVLGII4w
	RnsHQmS9B+9kCaBzf1sXGPIZtc0hGD+8x9iJur8vXCqa1frkDWWWEmMHZR1sqi5Q8THYsAZUppk
	sxNeBhBu23rvulZPhl8k1g1avC4LEE/vghNwStaHQcnnk01vuYRLgdvufXwYNUzC7VG/g0bhP0v
	z88xbTUkEPXIgn67POQJ58jJ6NOmU6MFT/PStOWwx63WOytFhylIfyR+wHyycJiNtpqYwMJRHkY
	4NPjfEFkWGc7hkip2jI2L0VbuZUeJrdqLqkoyhuWBL6oMqLU5+m0OsE9UTAu5hTu2cESb50NTFV
	l
X-Received: by 2002:a2e:7615:: with SMTP id r21-v6mr39597201ljc.131.1549277408208;
        Mon, 04 Feb 2019 02:50:08 -0800 (PST)
X-Received: by 2002:a2e:7615:: with SMTP id r21-v6mr39597137ljc.131.1549277407045;
        Mon, 04 Feb 2019 02:50:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549277407; cv=none;
        d=google.com; s=arc-20160816;
        b=h/hz5ff046glceH6vZ7LdFmErQfsM0JzrN7oH54wjBYcHMwnEmv7qennEPt/k+YebY
         XtorNLpTxbgMuFzADfO5G/Lzz++vWLgRADXueRFlkHIM+cXcukfIgEFx/PviHSG5Bk50
         OjLNh0Pk1EZlc9Rpvdtjjwp/K5vzo+sFkplgnhockLjj1FkOtaVYl2oJvCBY4vPgSzSG
         pmQjB+XNSKkLcpDFu6+sn9t3wvmGwhVC+t+wtlNl1E3+CbTRc4KToCHhtsnAJx2Xlk84
         9VUsPDprENzlBjexVrmqxCMtEq/E2eCSzG+tsnVtL3gBqx8ev3LPA/88M9cV5P/B76Tp
         cNnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=dY3R/Ow+sIeuZQPXwSYWif9PqrB6TJOohx4Dod2DIvA=;
        b=OYajTEr4n9U7jkZ2t2pjNGrVy5RZWWXjzoyNtcN9eTCd3+TyS5S3/Gl0ZALV6ERnFG
         dF+ERWw40f5mflGHqHS8TNgRn/AvZXjMmY3/2tT5RX91tR9XnnEQRbhykGYMclAyVgf6
         plbfNZg6n6nAT/hV1GLkwa0+wNZZQDkNVXDTFO8vE/+VJJ1/fe7eds5e0aBBI9I+318a
         5D8RAsIsrMylJwaOVN5e6y2w5SeSzKA/x45maX/trO+u6rZRTfDjEXgkuzi4AYwwsgaU
         MZ5/menzORx6cXCo7d/sq8GmcvwHYDPYsFQKaKgJNbF9FQNzTArDVZJ1PQRyy3gpm9bE
         hB7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="XeCtv/mU";
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i11sor845463lfc.38.2019.02.04.02.50.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Feb 2019 02:50:07 -0800 (PST)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="XeCtv/mU";
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=dY3R/Ow+sIeuZQPXwSYWif9PqrB6TJOohx4Dod2DIvA=;
        b=XeCtv/mUeqzkTh01QL+ztLqKkSGxZSSHaolQOQgZBJyRDLdpRq/wncEv1xCU+8CTPM
         2G6/i84SrLKFQx14BMMEdXqb08cdjmhG3qY81sS8SJ8Q6iz1sum4nrmm9TOolTvUrz/h
         2BheaPoj+yEhAlS2Bgv/mXtEC22AL/0gPGE3YnbMMJj7mOpKug9rbrTGzxXJGfRE+eEF
         GZBPExq32YEeNGTFJRluLRe+g0PujL7oStTCi/5jZEdngDw192gzOGiy34/bOgb6RBwA
         on38OJkUdt59LOuA4tVCUq4IVRB0RCu65m/GiodOMqa+yLoegPJdhjvouGHRMnt157z2
         8gaA==
X-Google-Smtp-Source: AHgI3IZvNEuGctW3VgPzvNS4djJz9FWP3UoGaXwEspLnSmHhO0+hIYAbeglQFF5KtdamJr8dL0sjfA==
X-Received: by 2002:a19:df41:: with SMTP id q1mr19208298lfj.25.1549277406384;
        Mon, 04 Feb 2019 02:50:06 -0800 (PST)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id v9sm3010048lfg.15.2019.02.04.02.50.04
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Feb 2019 02:50:05 -0800 (PST)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Mon, 4 Feb 2019 11:49:56 +0100
To: Michal Hocko <mhocko@kernel.org>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Matthew Wilcox <willy@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/1] mm/vmalloc: convert vmap_lazy_nr to atomic_long_t
Message-ID: <20190204104956.vg3u4jlwsjd2k7jn@pc636>
References: <20190131162452.25879-1-urezki@gmail.com>
 <20190201124528.GN11599@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190201124528.GN11599@dhcp22.suse.cz>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Michal.

On Fri, Feb 01, 2019 at 01:45:28PM +0100, Michal Hocko wrote:
> On Thu 31-01-19 17:24:52, Uladzislau Rezki (Sony) wrote:
> > vmap_lazy_nr variable has atomic_t type that is 4 bytes integer
> > value on both 32 and 64 bit systems. lazy_max_pages() deals with
> > "unsigned long" that is 8 bytes on 64 bit system, thus vmap_lazy_nr
> > should be 8 bytes on 64 bit as well.
> 
> But do we really need 64b number of _pages_? I have hard time imagine
> that we would have that many lazy pages to accumulate.
> 
That is more about of using the same type of variables thus the same size
in 32/64 bit address space.

<snip>
static void free_vmap_area_noflush(struct vmap_area *va)
{
    int nr_lazy;
 
    nr_lazy = atomic_add_return((va->va_end - va->va_start) >> PAGE_SHIFT,
                                &vmap_lazy_nr);
...
    if (unlikely(nr_lazy > lazy_max_pages()))
        try_purge_vmap_area_lazy();
<snip>

va_end/va_start are "unsigned long" whereas atomit_t(vmap_lazy_nr) is "int". 
The same with lazy_max_pages(), it returns "unsigned long" value.

Answering your question, in 64bit, the "vmalloc" address space is ~8589719406
pages if PAGE_SIZE is 4096, i.e. a regular 4 byte integer is not enough to hold
it. I agree it is hard to imagine, but it also depends on physical memory a
system has, it has to be terabytes. I am not sure if such systems exists.

Thank you.

--
Vlad Rezki

> > 
> > Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> > ---
> >  mm/vmalloc.c | 20 ++++++++++----------
> >  1 file changed, 10 insertions(+), 10 deletions(-)
> > 
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > index abe83f885069..755b02983d8d 100644
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -632,7 +632,7 @@ static unsigned long lazy_max_pages(void)
> >  	return log * (32UL * 1024 * 1024 / PAGE_SIZE);
> >  }
> >  
> > -static atomic_t vmap_lazy_nr = ATOMIC_INIT(0);
> > +static atomic_long_t vmap_lazy_nr = ATOMIC_LONG_INIT(0);
> >  
> >  /*
> >   * Serialize vmap purging.  There is no actual criticial section protected
> > @@ -650,7 +650,7 @@ static void purge_fragmented_blocks_allcpus(void);
> >   */
> >  void set_iounmap_nonlazy(void)
> >  {
> > -	atomic_set(&vmap_lazy_nr, lazy_max_pages()+1);
> > +	atomic_long_set(&vmap_lazy_nr, lazy_max_pages()+1);
> >  }
> >  
> >  /*
> > @@ -658,10 +658,10 @@ void set_iounmap_nonlazy(void)
> >   */
> >  static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
> >  {
> > +	unsigned long resched_threshold;
> >  	struct llist_node *valist;
> >  	struct vmap_area *va;
> >  	struct vmap_area *n_va;
> > -	int resched_threshold;
> >  
> >  	lockdep_assert_held(&vmap_purge_lock);
> >  
> > @@ -681,16 +681,16 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
> >  	}
> >  
> >  	flush_tlb_kernel_range(start, end);
> > -	resched_threshold = (int) lazy_max_pages() << 1;
> > +	resched_threshold = lazy_max_pages() << 1;
> >  
> >  	spin_lock(&vmap_area_lock);
> >  	llist_for_each_entry_safe(va, n_va, valist, purge_list) {
> > -		int nr = (va->va_end - va->va_start) >> PAGE_SHIFT;
> > +		unsigned long nr = (va->va_end - va->va_start) >> PAGE_SHIFT;
> >  
> >  		__free_vmap_area(va);
> > -		atomic_sub(nr, &vmap_lazy_nr);
> > +		atomic_long_sub(nr, &vmap_lazy_nr);
> >  
> > -		if (atomic_read(&vmap_lazy_nr) < resched_threshold)
> > +		if (atomic_long_read(&vmap_lazy_nr) < resched_threshold)
> >  			cond_resched_lock(&vmap_area_lock);
> >  	}
> >  	spin_unlock(&vmap_area_lock);
> > @@ -727,10 +727,10 @@ static void purge_vmap_area_lazy(void)
> >   */
> >  static void free_vmap_area_noflush(struct vmap_area *va)
> >  {
> > -	int nr_lazy;
> > +	unsigned long nr_lazy;
> >  
> > -	nr_lazy = atomic_add_return((va->va_end - va->va_start) >> PAGE_SHIFT,
> > -				    &vmap_lazy_nr);
> > +	nr_lazy = atomic_long_add_return((va->va_end - va->va_start) >>
> > +				PAGE_SHIFT, &vmap_lazy_nr);
> >  
> >  	/* After this point, we may free va at any time */
> >  	llist_add(&va->purge_list, &vmap_purge_list);
> > -- 
> > 2.11.0
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

