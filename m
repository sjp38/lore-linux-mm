Return-Path: <SRS0=oA8h=PB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C327DC04ABA
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 09:38:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B8EC21915
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 09:38:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B8EC21915
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=hofr.at
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AB4E8E0002; Mon, 24 Dec 2018 04:38:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15C128E0001; Mon, 24 Dec 2018 04:38:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 071DF8E0002; Mon, 24 Dec 2018 04:38:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id A83ED8E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 04:38:14 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id 129so4735430wmy.7
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 01:38:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=qfJI7aLj2IDOMGKgPMcNF43T8KcmM6MFL4qLDk5fFNU=;
        b=CoNNjyT/ODrPo8HKGfxsMn+ikqMvas5hxB6oLowYb0XkIrNBadDDa10dWg5/GDE9v6
         9ZwU+KEMhh+epVUHmISQ9z6V0/FKlvtDNrxqvsF/0Tbvs08iif87PpDbUrZbMH6JlZC5
         K7k91U9xp6EtCdjxMf92z9OFynl4AunfEPqZMwTLX4m7f/mGJB46fw2J0BAcY8YX90Rb
         BdDSjc0MTWnmbVU030W09JX+nSnbAZP+uSxnmWu6IMO6TSCJ47o4D82LNfNxxG2ObDtB
         8B8p28o7B/ryEsrj0rWYOx1UNg8DhGr85h7MyTH5o4KNcH2bPze9subRF7XijaxHzH5J
         x8/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hofrat@osadl.at designates 178.115.242.59 as permitted sender) smtp.mailfrom=hofrat@osadl.at
X-Gm-Message-State: AJcUukfKBwGDAv8Qz5zrGXxNJXAJ1y1YYubYGBvJW70I/f/UEuxWEyH9
	Mq6JQeQPV1v180xtcmcjEidsTHcSmRwrC/H7ozodXkB5hGYhXksPHm3LQRbdTX4gL3Io/HuSeJ+
	EqswLLOaOHEeIZNn/AB3WO7DqXwzcL4x9RPZpn1nRQT/y3vSn1Pcw2NV1Pqp6TEk=
X-Received: by 2002:adf:be0f:: with SMTP id n15mr11573231wrh.267.1545644294181;
        Mon, 24 Dec 2018 01:38:14 -0800 (PST)
X-Google-Smtp-Source: ALg8bN45c2+CiVl180j0GNVCyBbZ50gb2xvLmtgHoagXvLx63tyC1lk8xrWfmzuXcU04qiRxgLqN
X-Received: by 2002:adf:be0f:: with SMTP id n15mr11573170wrh.267.1545644292984;
        Mon, 24 Dec 2018 01:38:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545644292; cv=none;
        d=google.com; s=arc-20160816;
        b=Q/kozzRqgwlUkcgkmQ/T36M9pufXLp7AeLH+ej3LJXRHsuCLaTbSRTOGAxMvGvMSH/
         EGdb+RfMbgGuhQGuT1s/grKMLTFUG1su9wyfnd/vxhoCfEQh9RH77fw+jWFO0yZhYFlI
         tr3i8YbJ/DXhaZVbDtQTiPFxnmL9PFWCogWuzFXRjuXGq9Erx9zO34vAtQW2coTstnvw
         8VZk5SwNoNl6fDoQCh1F0e6SeuN/rUasPzwUyWrLoK04UQt6lZB+VjUO9dFddzhYv5xk
         zMl0uW9G0k/UBsgh8XdPfBFRYbCpK6lkz6ZKHfamX3SUy+tPACvfRzpf7YII5UzdQ6Ko
         TIBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=qfJI7aLj2IDOMGKgPMcNF43T8KcmM6MFL4qLDk5fFNU=;
        b=x+z4nIhSgBqjJIqvtwS2ZAJDJvC/2QJrPsDbkb5uDhaHcUDLVYYbjIPw0WXW5Kxquh
         rafpVYjc/5wR/ABSls5iqFm+taawHuEO6WQ0xtJIO6kRm+fTTD+cwBXA1JrqpGJl0nmM
         LM1Cb0cUtMyMXYI2jRDZ0pGu7Dmi/4Y44K4D9MolHyHzn0NTWcIdcwWFgS6HTODJ35sk
         hly4e28XmvuukqtjOZaatdm9c3w1zQMedmCat3GsecqvPL/3wbkG/mFvNBYXoBAniT3z
         D+UzwmZ6zXXU3/hJvoS7muilhmASDUeWZ2k8jFkMWtzx29IaAEo5hhDoU4FBtem8V2vY
         FJeg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hofrat@osadl.at designates 178.115.242.59 as permitted sender) smtp.mailfrom=hofrat@osadl.at
Received: from mail.osadl.at (178.115.242.59.static.drei.at. [178.115.242.59])
        by mx.google.com with ESMTP id s18si4657136wro.429.2018.12.24.01.38.12
        for <linux-mm@kvack.org>;
        Mon, 24 Dec 2018 01:38:12 -0800 (PST)
Received-SPF: pass (google.com: domain of hofrat@osadl.at designates 178.115.242.59 as permitted sender) client-ip=178.115.242.59;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hofrat@osadl.at designates 178.115.242.59 as permitted sender) smtp.mailfrom=hofrat@osadl.at
Received: by mail.osadl.at (Postfix, from userid 1001)
	id 5A81A5C0F46; Mon, 24 Dec 2018 10:38:04 +0100 (CET)
Date: Mon, 24 Dec 2018 10:38:04 +0100
From: Nicholas Mc Guire <der.herr@hofr.at>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>,
	Nicholas Mc Guire <hofrat@osadl.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Arun KS <arunks@codeaurora.org>, Joe Perches <joe@perches.com>,
	"Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH RFC] mm: vmalloc: do not allow kzalloc to fail
Message-ID: <20181224093804.GA16933@osadl.at>
References: <1545337437-673-1-git-send-email-hofrat@osadl.org>
 <alpine.DEB.2.21.1812211356040.219499@chino.kir.corp.google.com>
 <20181222080421.GB26155@osadl.at>
 <20181224081056.GD9063@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181224081056.GD9063@dhcp22.suse.cz>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181224093804.SyOhcnNmpf27WXNXHpDd92lWVF1HplA1o4DHdbO0FVY@z>

On Mon, Dec 24, 2018 at 09:10:56AM +0100, Michal Hocko wrote:
> On Sat 22-12-18 09:04:21, Nicholas Mc Guire wrote:
> > On Fri, Dec 21, 2018 at 01:58:39PM -0800, David Rientjes wrote:
> > > On Thu, 20 Dec 2018, Nicholas Mc Guire wrote:
> > > 
> > > > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > > > index 871e41c..1c118d7 100644
> > > > --- a/mm/vmalloc.c
> > > > +++ b/mm/vmalloc.c
> > > > @@ -1258,7 +1258,7 @@ void __init vmalloc_init(void)
> > > >  
> > > >  	/* Import existing vmlist entries. */
> > > >  	for (tmp = vmlist; tmp; tmp = tmp->next) {
> > > > -		va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
> > > > +		va = kzalloc(sizeof(*va), GFP_NOWAIT | __GFP_NOFAIL);
> > > >  		va->flags = VM_VM_AREA;
> > > >  		va->va_start = (unsigned long)tmp->addr;
> > > >  		va->va_end = va->va_start + tmp->size;
> > > 
> > > Hi Nicholas,
> > > 
> > > You're right that this looks wrong because there's no guarantee that va is 
> > > actually non-NULL.  __GFP_NOFAIL won't help in init, unfortunately, since 
> > > we're not giving the page allocator a chance to reclaim so this would 
> > > likely just end up looping forever instead of crashing with a NULL pointer 
> > > dereference, which would actually be the better result.
> > >
> > tried tracing the __GFP_NOFAIL path and had concluded that it would
> > end in out_of_memory() -> panic("System is deadlocked on memory\n");
> > which also should point cleanly to the cause - but I´m actually not
> > that sure if that trace was correct in all cases.
> 
> No, we do not trigger the memory reclaim path nor the oom killer when
> using GFP_NOWAIT. In fact the current implementation even ignores
> __GFP_NOFAIL AFAICS (so I was wrong about the endless loop but I suspect
> that we used to loop fpr __GFP_NOFAIL at some point in the past). The
> patch simply doesn't have any effect. But the primary objection is that
> the behavior might change in future and you certainly do not want to get
> stuck in the boot process without knowing what is going on. Crashing
> will tell you that quite obviously. Although I have hard time imagine
> how that could happen in a reasonably configured system.

I think most of the defensive structures are covering rare to almost
impossible cases - but those are precisely the hard ones to understand if
they do happen.

> 
> > > You could do
> > > 
> > > 	BUG_ON(!va);
> > > 
> > > to make it obvious why we crashed, however.  It makes it obvious that the 
> > > crash is intentional rather than some error in the kernel code.
> > 
> > makes sense - that atleast makes it imediately clear from the code
> > that there is no way out from here.
> 
> How does it differ from blowing up right there when dereferencing flags?
> It would be clear from the oops.

The question is how soon does it blow-up if it were imediate then three is
probably no real difference if there is some delay say due to the region
affected by the NULL pointer not being imediately in use - it may be very
hard to differenciate between an allocation failure and memory corruption
so having a directly associated trace should be significantly simpler to
understand - and you might actually not want a system to try booting if there
are problems at this level.

thx!
hofrat

