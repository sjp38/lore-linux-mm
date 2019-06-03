Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06164C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:53:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADF7825053
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:53:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hBvj2a/S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADF7825053
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BB436B0007; Mon,  3 Jun 2019 13:53:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 444366B0276; Mon,  3 Jun 2019 13:53:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30C5D6B0278; Mon,  3 Jun 2019 13:53:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id C08696B0007
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 13:53:17 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id c25so2773958ljb.3
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 10:53:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Srx+JSQEvVah+8jZbb/etDm06U9ghyEFAowtj168rhg=;
        b=LY0O5aTz1rhMKv/wwQxUT9zYnCT7VyvFGQ/Fuc/vwLImRWaUdZL+5QGfRgcDu0/K4h
         64xYNArDAUNq+GAkXWYIilUa9BQkis/QMuO4bCKT/pTtrVqA/ptbxa0w6ai/AJlZifHK
         1QL0sanXd/OcYmNfZU+AxyOXQeUwlFc3pjN55kV/dQSRaOnu69RN46cWdiNmg8l6swrS
         zAOkXpxFmAnjIiOmbd6fal/18gc9Z5bWHj4ulr5c0cCUoKNdxJJa2e8aEla+M1rA7LDa
         3yLwmUuPe3QLEG56pzGV5301uhQ6X+JY16RCla8gt+GgQbaU7fqme5jCxWo9yYe3NWoj
         sjEw==
X-Gm-Message-State: APjAAAWVqCHPtwvDpDlqjDUUzHXniyyyjiZJ5YK/thw0LKEHFOSGVbfr
	gfCYzonkY6gGOCnFcIOr8Ih7I7IRI0Mhbe+xdsbrkDa7i5MahKSWtH2Y2JNny8L3a+XwMQRuQaf
	WDB9epPZL4gtiKPrh+CuMX/4Su/Dbd7JsyLHwyXsRIUpnwoTdmezht3qpOVTMWlvsqw==
X-Received: by 2002:a2e:89cc:: with SMTP id c12mr14525609ljk.90.1559584397276;
        Mon, 03 Jun 2019 10:53:17 -0700 (PDT)
X-Received: by 2002:a2e:89cc:: with SMTP id c12mr14525583ljk.90.1559584396527;
        Mon, 03 Jun 2019 10:53:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559584396; cv=none;
        d=google.com; s=arc-20160816;
        b=HvgxJa5+e64C3KfnP9oBm03IpCDhmSh6SCzJ7i17YmVnuNHi9j58CWqSA6AlAjBAbp
         OABzxl4lV2204y9/MqEyl/Bv7xjA5VOeuH5y92Ryb2AdnLvMUl1fl31ZZSM0BpAZeeMc
         pbNI3uELS1wnagU5CYcOE75Dyt9JqQEgrR5b/493Qs+YF6LLqjzs8QO4inVW0T8CEeUq
         2zfiabEKjnqS/+hLLZ/k3O3fcNg/2RVajGK03w4Q9jdbVTEn3pz/ZPe/LuYI+DPU3U9A
         03d0mBJDWT/wPbj5/mLlYyuS7WkKObyu8ptLnCnd/95lE6s4kDkv6DOezB6EHQQBG0xw
         BfVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=Srx+JSQEvVah+8jZbb/etDm06U9ghyEFAowtj168rhg=;
        b=OnO15IozE4JJFdRYsJFJLvNAmya+3NvA03KEAtQXIqyEtR5wQgBofMq85oGnOu2sk6
         CiB+Dvq3eQbnFf9rMt37XbziLSRk+Q6fjiTgA0nYzKEBWw/dG4rgk3yJW6KKTMuqwhZY
         3SteSTQJDpLfhhBv8hnJ53lyfPBvBqoTCaO38JAFMNthM0bjigsqQ6OHNsnRwX0vFoLl
         qc3nOU21gMqrPrnK9SqE8Qe37HsMmLXwwUDjRPsdedH4ZP0IhEJRqjpQybsqEr2xtTPm
         vXUd0GnkhYD9tBXj+FPz0Xi/uLGY6z9bG2cj63FNoCSFaAvP4sBydyvMGbGfeTQbMNRV
         SGHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="hBvj2a/S";
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r25sor4532404lfg.72.2019.06.03.10.53.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 10:53:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="hBvj2a/S";
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Srx+JSQEvVah+8jZbb/etDm06U9ghyEFAowtj168rhg=;
        b=hBvj2a/SxeY8uo2/eITryp250u7lguAtkLG3Rzw/28UO6KoV8ECca3G6kiHt9yAFR8
         4GYgW/r5DAJg5uGAXloHi0Kqx3rpg5+lP5dDjIFmwXxGsTiIlSYcvgfn9XfogyQ/Lw73
         BBjkwHmuinB+Jej8dicc57ngL+G5Xkokj4e7d4rLBGc8oFNaNuhR+xNXZXgXHj98Rv5e
         Hd8T2iOkvt6klZc5R/VZB65XH/tHhVZkSWsnW3xgRdaxOKnJ+aEww9sdKG1hp9VB371Z
         L6pePxzhDKwYKHZskQL5tNPsFmXYZvbYRNnBt4uRwKc7cyZbOOavOnwXzMsKlivIZcxI
         S75w==
X-Google-Smtp-Source: APXvYqwkNqnG7HCV7jYR28Yp6QjtylKEBiui88FHYvyLoqwJOwUAPczmn457xBJ7dqYkon33WuCwMg==
X-Received: by 2002:ac2:42c8:: with SMTP id n8mr6415lfl.28.1559584396076;
        Mon, 03 Jun 2019 10:53:16 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id v16sm3315552ljk.80.2019.06.03.10.53.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 10:53:15 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Mon, 3 Jun 2019 19:53:12 +0200
To: Roman Gushchin <guro@fb.com>
Cc: Uladzislau Rezki <urezki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 2/4] mm/vmap: preload a CPU with one object for split
 purpose
Message-ID: <20190603175312.72td46uahgchfgma@pc636>
References: <20190527093842.10701-1-urezki@gmail.com>
 <20190527093842.10701-3-urezki@gmail.com>
 <20190528224217.GG27847@tower.DHCP.thefacebook.com>
 <20190529142715.pxzrjthsthqudgh2@pc636>
 <20190529163435.GC3228@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190529163435.GC3228@tower.DHCP.thefacebook.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Roman!

On Wed, May 29, 2019 at 04:34:40PM +0000, Roman Gushchin wrote:
> On Wed, May 29, 2019 at 04:27:15PM +0200, Uladzislau Rezki wrote:
> > Hello, Roman!
> > 
> > > On Mon, May 27, 2019 at 11:38:40AM +0200, Uladzislau Rezki (Sony) wrote:
> > > > Refactor the NE_FIT_TYPE split case when it comes to an
> > > > allocation of one extra object. We need it in order to
> > > > build a remaining space.
> > > > 
> > > > Introduce ne_fit_preload()/ne_fit_preload_end() functions
> > > > for preloading one extra vmap_area object to ensure that
> > > > we have it available when fit type is NE_FIT_TYPE.
> > > > 
> > > > The preload is done per CPU in non-atomic context thus with
> > > > GFP_KERNEL allocation masks. More permissive parameters can
> > > > be beneficial for systems which are suffer from high memory
> > > > pressure or low memory condition.
> > > > 
> > > > Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> > > > ---
> > > >  mm/vmalloc.c | 79 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
> > > >  1 file changed, 76 insertions(+), 3 deletions(-)
> > > 
> > > Hi Uladzislau!
> > > 
> > > This patch generally looks good to me (see some nits below),
> > > but it would be really great to add some motivation, e.g. numbers.
> > > 
> > The main goal of this patch to get rid of using GFP_NOWAIT since it is
> > more restricted due to allocation from atomic context. IMHO, if we can
> > avoid of using it that is a right way to go.
> > 
> > From the other hand, as i mentioned before i have not seen any issues
> > with that on all my test systems during big rework. But it could be
> > beneficial for tiny systems where we do not have any swap and are
> > limited in memory size.
> 
> Ok, that makes sense to me. Is it possible to emulate such a tiny system
> on kvm and measure the benefits? Again, not a strong opinion here,
> but it will be easier to justify adding a good chunk of code.
> 
It seems it is not so straightforward as it looks like. I tried it before,
but usually the systems gets panic due to out of memory or just invokes
the OOM killer.

I will upload a new version of it, where i embed "preloading" logic directly
into alloc_vmap_area() function.

Thanks.

--
Vlad Rezki

