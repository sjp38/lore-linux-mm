Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6D3BC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 11:42:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 847C320881
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 11:42:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bxDWtOim"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 847C320881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38D6F6B000A; Thu, 23 May 2019 07:42:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 318C56B000C; Thu, 23 May 2019 07:42:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DF2B6B000D; Thu, 23 May 2019 07:42:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id AC36C6B000A
	for <linux-mm@kvack.org>; Thu, 23 May 2019 07:42:43 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id d11so1194314lji.21
        for <linux-mm@kvack.org>; Thu, 23 May 2019 04:42:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ykcxKAu1yeS0S8j9F2MpC8e5r2yjSE1W4U9t77O1hrw=;
        b=HRPgX1dcXd4KIvTRpvEoLT4upuU4Wc/zTnKn4gtpMOTvuBQV0ymPeLHqXtuwhflquS
         NYMUkAEaiD3g7+8jJ/ZefAySKcw4pHpOmsR8AJ0nitFmxxJbcskHKBLzSGC2AgPX5d0X
         62oxVOemLOhWn1hCr6FENBuPNftCoshOjFnbGG1PYbJG4JmEl93lFELTrQ90z0CcgRYZ
         PFPGLoHjQ3d97S4P4uSxoAcpHEVMeXMkXMGnkcdA7oI/1Gtsq72aNBnq2fEhmRah5bad
         6CZYOchKI02Xz4OWF2fv6bxdoe1UZ3aVBXpZ/rTbPq9d0uEHCmGBbwK6HbunG5AjhquH
         3PCQ==
X-Gm-Message-State: APjAAAVgCv2a61ALW3Qc6bhBpDGbcyzxGFrMTBj9i9KGSfjI3Y2SeMQP
	Vm+se9ivOqIUU21RxF2T4l2y4QwTdG4sKx3avifpNlBON8r5A1KvlpZsjLqBSKh2TMeH7JV/SJr
	tfnOonjN0v85UIdHwsqWxGSAz9qXuf8L08kytrucE9pijUNQEHRE3iGv8hwYM8dDaRA==
X-Received: by 2002:a19:2791:: with SMTP id n139mr39129457lfn.67.1558611762824;
        Thu, 23 May 2019 04:42:42 -0700 (PDT)
X-Received: by 2002:a19:2791:: with SMTP id n139mr39129411lfn.67.1558611761912;
        Thu, 23 May 2019 04:42:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558611761; cv=none;
        d=google.com; s=arc-20160816;
        b=qwPEgUI2++6gnMYVculP/j2hys67XpsmaOMSf4dcBlIEaBEI7v4uGSk84B+5M2UGrj
         YZrK7I7OCG41o4R1YWimG3a1gZqfF/1xwqs8mxMnoxnV2n6tnekJmrSrZ3LG9gbkK+6R
         Q/uTKNwUVXVe8p63ONiPENEU6IDVVOv78Hz/1pBartiPhGdcuX02tjl2QAdEUpDG1Fo0
         ZrIfnqAThtzDgbQMJnkHpM7coPXuSQhK8taDIOHi1d/Zyn6FndZT8/+ie9paULRnqzFE
         B27v/DEdh5htWq3euh5tUMX0gK6lQ9PDC6v7HsF4WyVdjqRu+21Ecc7RAWIuw84vz5+Z
         IKLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=ykcxKAu1yeS0S8j9F2MpC8e5r2yjSE1W4U9t77O1hrw=;
        b=H/iHfXUw1H59gh4AvtXSc93rVdx2u3OrN/4C0LPc7vxe44+t1DIT+48JG6DMOqesBR
         fNE+1Aa13oCBcoUp0ArQU8HQ7OAY5ZK0uVNsqwjwoVMclpCmqTcGr6MFNcCBgTY0vNC9
         o07KPdF+VNCN0WlJwaQjbH0ShrFX0cCPqeL93aTb14jX6W9ONwKuzdLI6Snf9WfrTDhS
         Q45QDVlRm3OL56Diy9XOab086AA3yE2Bc8fyF6Yb4OIRwWObwf5gVKdO+QUnG5G3rpZF
         3Y7DqlNIXB+s6QIYovUw+54fbNEUB4vIan8EKZO5nvfgQO9C4IPLcMlxpT0M7soyodFD
         UGXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bxDWtOim;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p68sor2436886ljb.43.2019.05.23.04.42.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 04:42:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bxDWtOim;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ykcxKAu1yeS0S8j9F2MpC8e5r2yjSE1W4U9t77O1hrw=;
        b=bxDWtOim1MzeFIRJ4yJcYUh1Dw3qOhMolSjiAWZK35KArCVHj9+qeaFO/wDKpjtFOJ
         VKQiRY6lBiNNEKoL/8qpuriuvioqdWqiwrVD2VWcqhJ1rd30/4A6TBd4U9Q5UiMxpwpF
         Pg0P1nepoQ0UN9BSsoEjc21Q6KfN5kgc561hxwJINZnf/V7vjCrIRrLZ1wiOpWehqeUQ
         iUtwD+Iao4G9ehRfxCfF0EE2D8Jh02QF3B2te5X2MERgVgi5oKN/6JvcpllaCzYaOa1p
         whqK+YN4EhCOmf9a0s6lJ0FcCKKldxGi5IM+5mwfJmFDHvWzNrBuARQu471WsO7PzXnN
         1GPQ==
X-Google-Smtp-Source: APXvYqyrZe2fAQKOHmst89glduY9pajtxTe3ThVEhZPA2ZPid0/GG8g1d8IuJatP734wPfzzn4vDng==
X-Received: by 2002:a2e:89cb:: with SMTP id c11mr16002872ljk.16.1558611761401;
        Thu, 23 May 2019 04:42:41 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id e19sm5293138ljj.62.2019.05.23.04.42.39
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 04:42:40 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Thu, 23 May 2019 13:42:32 +0200
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/4] mm/vmap: preload a CPU with one object for split
 purpose
Message-ID: <20190523114232.unx6f6h4s4onb3cr@pc636>
References: <20190522150939.24605-1-urezki@gmail.com>
 <20190522150939.24605-2-urezki@gmail.com>
 <20190522111904.ff2cd5011c8c3b3207e3f3fa@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190522111904.ff2cd5011c8c3b3207e3f3fa@linux-foundation.org>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 11:19:04AM -0700, Andrew Morton wrote:
> On Wed, 22 May 2019 17:09:37 +0200 "Uladzislau Rezki (Sony)" <urezki@gmail.com> wrote:
> 
> > Introduce ne_fit_preload()/ne_fit_preload_end() functions
> > for preloading one extra vmap_area object to ensure that
> > we have it available when fit type is NE_FIT_TYPE.
> > 
> > The preload is done per CPU and with GFP_KERNEL permissive
> > allocation masks, which allow to be more stable under low
> > memory condition and high memory pressure.
> 
> What is the reason for this change?  Presumably some workload is
> suffering from allocation failures?  Please provide a full description
> of when and how this occurs so others can judge the desirability of
> this change.
>
It is not driven by any particular workload that suffers from it.
At least i am not aware of something related to it.

I just think about avoid of using GFP_NOWAIT if it is possible. The
reason behind it is GFP_KERNEL has more permissive parameters and
as an example does __GFP_DIRECT_RECLAIM if no memory available what
can be beneficial in case of high memory pressure or low memory
condition.

Probably i could simulate some special conditions and come up with
something, but i am not sure. I think this change will be good for
"small" systems without swap under high memory pressure where direct
reclaim and other flags can fix the situation.

Do you want me to try to find a specific test case? What do you think?

> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -364,6 +364,13 @@ static LIST_HEAD(free_vmap_area_list);
> >   */
> >  static struct rb_root free_vmap_area_root = RB_ROOT;
> >  
> > +/*
> > + * Preload a CPU with one object for "no edge" split case. The
> > + * aim is to get rid of allocations from the atomic context, thus
> > + * to use more permissive allocation masks.
> > + */
> > +static DEFINE_PER_CPU(struct vmap_area *, ne_fit_preload_node);
> > +
> >  static __always_inline unsigned long
> >  va_size(struct vmap_area *va)
> >  {
> > @@ -950,9 +957,24 @@ adjust_va_to_fit_type(struct vmap_area *va,
> >  		 *   L V  NVA  V R
> >  		 * |---|-------|---|
> >  		 */
> > -		lva = kmem_cache_alloc(vmap_area_cachep, GFP_NOWAIT);
> > -		if (unlikely(!lva))
> > -			return -1;
> > +		lva = __this_cpu_xchg(ne_fit_preload_node, NULL);
> > +		if (unlikely(!lva)) {
> > +			/*
> > +			 * For percpu allocator we do not do any pre-allocation
> > +			 * and leave it as it is. The reason is it most likely
> > +			 * never ends up with NE_FIT_TYPE splitting. In case of
> > +			 * percpu allocations offsets and sizes are aligned to
> > +			 * fixed align request, i.e. RE_FIT_TYPE and FL_FIT_TYPE
> > +			 * are its main fitting cases.
> > +			 *
> > +			 * There are few exceptions though, as en example it is
> 
> "a few"
> 
> s/en/an/
> 
> > +			 * a first allocation(early boot up) when we have "one"
> 
> s/(/ (/
> 
Will fix that.

> > +			 * big free space that has to be split.
> > +			 */
> > +			lva = kmem_cache_alloc(vmap_area_cachep, GFP_NOWAIT);
> > +			if (!lva)
> > +				return -1;
> > +		}
> >  
> >  		/*
> >  		 * Build the remainder.
> > @@ -1023,6 +1045,50 @@ __alloc_vmap_area(unsigned long size, unsigned long align,
> >  }
> >  
> >  /*
> > + * Preload this CPU with one extra vmap_area object to ensure
> > + * that we have it available when fit type of free area is
> > + * NE_FIT_TYPE.
> > + *
> > + * The preload is done in non-atomic context thus, it allows us
> 
> s/ thus,/, thus/
> 
Will fix.

> > + * to use more permissive allocation masks, therefore to be more
> 
> s/, therefore//
> 
Will fix.

> > + * stable under low memory condition and high memory pressure.
> > + *
> > + * If success, it returns zero with preemption disabled. In case
> > + * of error, (-ENOMEM) is returned with preemption not disabled.
> > + * Note it has to be paired with alloc_vmap_area_preload_end().
> > + */
> > +static void
> > +ne_fit_preload(int *preloaded)
> > +{
> > +	preempt_disable();
> > +
> > +	if (!__this_cpu_read(ne_fit_preload_node)) {
> > +		struct vmap_area *node;
> > +
> > +		preempt_enable();
> > +		node = kmem_cache_alloc(vmap_area_cachep, GFP_KERNEL);
> > +		if (node == NULL) {
> > +			*preloaded = 0;
> > +			return;
> > +		}
> > +
> > +		preempt_disable();
> > +
> > +		if (__this_cpu_cmpxchg(ne_fit_preload_node, NULL, node))
> > +			kmem_cache_free(vmap_area_cachep, node);
> > +	}
> > +
> > +	*preloaded = 1;
> > +}
> 
> Why not make it do `return preloaded;'?  The
> pass-and-return-by-reference seems unnecessary?
>
Will rewrite. I just though about:

preload_start(preloaded)
...
preload_end(preloaded)

instead of doing it conditionally:

preloaded = preload_start()
...
if (preloaded)
    preload_end();

Thank you!

--
Vlad Rezki

