Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0DE8C282E1
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 14:14:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56DE12133D
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 14:14:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gp7Smd3J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56DE12133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA0FD6B0005; Fri, 24 May 2019 10:14:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A51D26B0006; Fri, 24 May 2019 10:14:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 940506B0007; Fri, 24 May 2019 10:14:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 317746B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 10:14:55 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id v21so1811021ljh.15
        for <linux-mm@kvack.org>; Fri, 24 May 2019 07:14:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Z0JaSGWsUOOsyTjzNatwSpIa5L1qUcHPrgbNW+8vGCc=;
        b=K8XyVPzM7AKrUGAxse25466Tg68tuoT75fk0Il6TKA72dQMyikVX1YfVT1bQfK3dyT
         hjuNyq33yaVMoAddJVNmQ7oVWUs1mdIpEQOJrYQD1QwQoEhyNhkx7Xb1jpG6wqjTssST
         Y41Q8QtoDPHxEmZBhHW5beKMWskiA23lFD9QHOGiXP8P+OhobkVsITg/15ABsLrAHdas
         jAK4dmF0W9MkSY6DJzogCshrhwzbvlRdpbw+Q/5+uRTAdGZ5XVJO3nj02zgNbtZXCbo3
         avl3lkut7osXLdAWLGgjalOVCPq4/PvgX4bSC6zUX91erHwjMhasuLo5jmKc8X9xkb6G
         JKCg==
X-Gm-Message-State: APjAAAUuKOYqhrwm76vqbPSGfPIjDa55qH4HzeA5+f6B+RUEnW/563RA
	rpaPkx2mooPt58s5H2oTZYJTs6PIJx9NBudNTAwgsem5H7TOTXSvoJGxYqhJNXxBcNyqAhx2zVI
	edgiBgNmattkOBAbU+xIUn5jHOjeuOmezo70amOVC+DBAUZFxCGWPTTDPVYl+BWlo5Q==
X-Received: by 2002:a2e:8143:: with SMTP id t3mr28412152ljg.131.1558707294397;
        Fri, 24 May 2019 07:14:54 -0700 (PDT)
X-Received: by 2002:a2e:8143:: with SMTP id t3mr28412093ljg.131.1558707293290;
        Fri, 24 May 2019 07:14:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558707293; cv=none;
        d=google.com; s=arc-20160816;
        b=NEpTNTaCp8VJgZMmtqnEWF6XVE0aNVd6yexZnPBjxl2eEREjeKAJgWCDjjp9k0y3Zn
         I+VzuSRnxR8TugDQKhW3uClztBlLP6ZSsLmSdX116C40uMqf2oFz1ghpHJnUELCpc8Kz
         oy44w5RCyydrrCZT4YAgTWZg3xd2nBT6e7YEpSzdPd9iE/BQCifpL6ZQHeIEsr98QM1l
         x/y0egBp0Xhpu32yFDsgzSC/i6GccPCtqJZg9Dwvnh/fEh2IONNYLvgxPlewZD4AFumi
         D23rI9y1li9CvSYGvGTPxX0THJfPxvwtoROcpRPgbb2JM1awz8vhxYKu7qCKnQFalEDd
         tJgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=Z0JaSGWsUOOsyTjzNatwSpIa5L1qUcHPrgbNW+8vGCc=;
        b=cQ9fQkzmyC+qHZCAy8iTSom2evelTEGQpzu4VuLrUx5jvz6hQSAiUI3w4+ZcgzG7P7
         P17nE2G+uHMllq2QZKLqyjeAMi4679PMQCS9xgbSF0Bg2FkPsJeZeWDr8GYpMcqPscOm
         rGRu5pDQeqsdcM5JOER9chCseri+3VU3vC5rYDOGNV2FwVjF8+sbnUPyKa/unJn/5C1c
         JpGK03kRG3G8Q2JyR8tGPpLoLemzqXH6Flk+HZYwAxaG9isEifAJtQHlqCZKBNurexjQ
         DAnuCzYdKlFOZq2Z3v7k/mqcW7DMow887A/Hc14mdFQJjWO3zTRy5DdYWSwGLrXPEu9E
         SxlA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gp7Smd3J;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j24sor1577764ljg.21.2019.05.24.07.14.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 07:14:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gp7Smd3J;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Z0JaSGWsUOOsyTjzNatwSpIa5L1qUcHPrgbNW+8vGCc=;
        b=gp7Smd3Jd+5pX7F9omsqf2JIeSGIoHCIahJb/dMVIE7rwXs9sUZAuqwyNhVtcZr0Ue
         c5UISRf0crmCFgg3vO8t61ECMxFCbtuVUxL0/mUL2LIrXVPpMDCyYO3lozQ5Yujba8qM
         12WOyekDu7ziSihEYxVTT7BtM6CBDEk1BxA879HbqUDGCifHz+/mwdl6ynerrw5hxork
         wdCJF3HYv/iGYnXj9Ijg1jE5BqEvTFijN1+Qhx3VX/eT95/ElOVrCudNNF/VWM3hBgAr
         H1OsLRDwy6QK9TWuHIzDJCDtvo65s2cIwwMaggHm1ZnwZYLQSdCDwQppSkmNean937tb
         aEBg==
X-Google-Smtp-Source: APXvYqwFkQzvO6hWW6ullJJyh+NG3eaQN2NeozeQUBII+qBWXm7fvPmjm1WpPzUVrDmnBipLdflo4Q==
X-Received: by 2002:a2e:8796:: with SMTP id n22mr42220465lji.75.1558707292823;
        Fri, 24 May 2019 07:14:52 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id w27sm645388lfn.19.2019.05.24.07.14.51
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 24 May 2019 07:14:52 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Fri, 24 May 2019 16:14:44 +0200
To: Hillf Danton <hdanton@sina.com>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
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
Message-ID: <20190524141444.hrkp5eizlemx4dd5@pc636>
References: <20190522150939.24605-1-urezki@gmail.com>
 <20190524103316.1352-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190524103316.1352-1-hdanton@sina.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 06:33:16PM +0800, Hillf Danton wrote:
> 
> On Wed, 22 May 2019 17:09:37 +0200 Uladzislau Rezki (Sony) wrote:
> >  /*
> > + * Preload this CPU with one extra vmap_area object to ensure
> > + * that we have it available when fit type of free area is
> > + * NE_FIT_TYPE.
> > + *
> > + * The preload is done in non-atomic context thus, it allows us
> > + * to use more permissive allocation masks, therefore to be more
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
> 
> Alternatively, can you please take another look at the upside to use
> the memory node parameter in alloc_vmap_area() for allocating va slab,
> given that this preload, unlike adjust_va_to_fit_type() is invoked
> with the vmap_area_lock not aquired?
> 
Agree. That makes sense. I will upload the v2 where fix all comments.

Thank you!

--
Vlad Rezki

