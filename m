Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0405C282DA
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 16:17:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9ED66206B6
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 16:17:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9ED66206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C6666B0007; Mon, 15 Apr 2019 12:17:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 175B76B0008; Mon, 15 Apr 2019 12:17:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0652D6B000A; Mon, 15 Apr 2019 12:17:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id DB5926B0007
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 12:17:03 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id o34so16563142qte.5
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 09:17:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jIWyX6gemaKwK7U5Iih6Rno5jYZVIugOJ3QQ9v7pcBc=;
        b=FWPsaoxtzLriNc6l/hrAYj15mM/HIYl5hIkzxYHcyK4ysZgSSuKXbI5/e8V4Qv8O+e
         S5YannjJzE0eGLXXgiez4HW8TobQdyYK29Wtj5Ab+rgmf5pP1X2ypyRfWjb11vzXwtQ0
         COxmfcWNLNFECU1OY9EZqWftea3sKqAA3X8bPVjLuIfOlbFjzpBaWb0UI09BY6qHLjXV
         adfboVLY0l8gp32vHL26Zbmb+Vlzj3lqz28YgBZqS9dgw8/8VhC9cEynawc2IfuMh14v
         8hQbz7ze7aYgJe6MtAypcRmrF4Xvgy2Iwznf88lz9K10ogcfQT1xe0ykGqpf1byaw4LK
         ZR4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV254BvxuNjLa5jv0yZgQaU4+qkzSzGnDDloEr9s6tty/JXqI7r
	p9vT3OILVDK95iIamneYAyH559WPYWLta7kKfKvem29Wkjqh7rtLf5s2QGcFyDY1/YQ8VjHQndq
	/tKfATfDo/v5p7oOl8mxYyDsm7H06Pzca/CqKueQVLM6gfppcqf67ousrcesnoOmAjQ==
X-Received: by 2002:ac8:91b:: with SMTP id t27mr59929143qth.107.1555345023633;
        Mon, 15 Apr 2019 09:17:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydSqhsyN+6UoXPmp4b+sybNRfgyun+d0cciuDKYsb6gznzWwTGzeYlHl/CvhJnyOsIgJeX
X-Received: by 2002:ac8:91b:: with SMTP id t27mr59929083qth.107.1555345022936;
        Mon, 15 Apr 2019 09:17:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555345022; cv=none;
        d=google.com; s=arc-20160816;
        b=r+wMy7Jjyu2kuGJacFC+oLwJHEypAX+ZpTKWh3das/ROGwvL78BpGk3NLFt92yJy37
         +RqBGDv1ABY0BE9gewub/m7ARevWm9dn2CObZpyYpkPlVB23FJI2jglfHPMIkVHOeOzl
         KKOJz/NKmySXDaBVwkIqKmOVflxFzLPPk2w9LNEeh7JUQH8ok16NoaS+6S4Qtx4tZzF4
         rjGsTUuYhZ7xQYnhKqvBboOhmase+KsQFEbUDmjUbXe8xK5vvqgk163rOaVAKuQ+m3Rx
         Chxbhiv3Wbc7hcIZ26sDxFVD3bBcM1yuJcNzqSMtqgrVcpN7Cdr5b1WrDhGGjv2gJi7G
         XvBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=jIWyX6gemaKwK7U5Iih6Rno5jYZVIugOJ3QQ9v7pcBc=;
        b=IhgCrfR9hEkSIOP6onNLJBD2aCoPB5rYA9GMdX5QFRBa+Sdsa+kBkuCuMzhmrC7uXh
         AXTwKSnwxxrOghMo4l6xB/RJeRH79BU7MZJ0FLW3Zb8TeS3luxw9pcvqRSteP0tnpdzi
         gLGf4V+o/XbcA7807+5nPEOB37tNTyeZMqO8MvumNgOB6dUcCbfX9cVY4TiRlDQUIQZK
         q0lbttIV7ZcNrVeTz8ciUfz2aHtiskQkryzPBqYFDQXxVlgNfWV22wBgC5qSFt5ngu66
         JzRWafiJOoCIOv7tuCAk+jmuAFZzo9qIEGLXcpbHTU09VzMoYJdmQ1cjFp0Pb6MnLYZL
         FQNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s57si2714741qtj.86.2019.04.15.09.17.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 09:17:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9970C30B27AE;
	Mon, 15 Apr 2019 16:17:01 +0000 (UTC)
Received: from treble (ovpn-120-105.rdu2.redhat.com [10.10.120.105])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 8B65A19C77;
	Mon, 15 Apr 2019 16:16:59 +0000 (UTC)
Date: Mon, 15 Apr 2019 11:16:57 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	X86 ML <x86@kernel.org>,
	Sean Christopherson <sean.j.christopherson@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pekka Enberg <penberg@kernel.org>, Linux-MM <linux-mm@kvack.org>
Subject: Re: [patch V4 01/32] mm/slab: Fix broken stack trace storage
Message-ID: <20190415161657.2zwboghblj5ducux@treble>
References: <20190414155936.679808307@linutronix.de>
 <20190414160143.591255977@linutronix.de>
 <CALCETrUhVc_u3HL-x7wMnk9ukEbwQPvc9N5Na-Q55se0VwcCpw@mail.gmail.com>
 <alpine.DEB.2.21.1904141832400.4917@nanos.tec.linutronix.de>
 <alpine.DEB.2.21.1904151101100.1729@nanos.tec.linutronix.de>
 <20190415132339.wiqyzygqklliyml7@treble>
 <alpine.DEB.2.21.1904151804460.1895@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1904151804460.1895@nanos.tec.linutronix.de>
User-Agent: NeoMutt/20180716
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Mon, 15 Apr 2019 16:17:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 15, 2019 at 06:07:44PM +0200, Thomas Gleixner wrote:
> On Mon, 15 Apr 2019, Josh Poimboeuf wrote:
> > On Mon, Apr 15, 2019 at 11:02:58AM +0200, Thomas Gleixner wrote:
> > >  	addr = (unsigned long *)&((char *)addr)[obj_offset(cachep)];
> > >  
> > > -	if (size < 5 * sizeof(unsigned long))
> > > +	if (size < 5)
> > >  		return;
> > >  
> > >  	*addr++ = 0x12345678;
> > >  	*addr++ = caller;
> > >  	*addr++ = smp_processor_id();
> > > -	size -= 3 * sizeof(unsigned long);
> > > +	size -= 3;
> > > +#ifdef CONFIG_STACKTRACE
> > >  	{
> > > -		unsigned long *sptr = &caller;
> > > -		unsigned long svalue;
> > > -
> > > -		while (!kstack_end(sptr)) {
> > > -			svalue = *sptr++;
> > > -			if (kernel_text_address(svalue)) {
> > > -				*addr++ = svalue;
> > > -				size -= sizeof(unsigned long);
> > > -				if (size <= sizeof(unsigned long))
> > > -					break;
> > > -			}
> > > -		}
> > > +		struct stack_trace trace = {
> > > +			/* Leave one for the end marker below */
> > > +			.max_entries	= size - 1,
> > > +			.entries	= addr,
> > > +			.skip		= 3,
> > > +		};
> > >  
> > > +		save_stack_trace(&trace);
> > > +		addr += trace.nr_entries;
> > >  	}
> > > -	*addr++ = 0x87654321;
> > > +#endif
> > > +	*addr = 0x87654321;
> > 
> > Looks like stack_trace.nr_entries isn't initialized?  (though this code
> > gets eventually replaced by a later patch)
> 
> struct initializer initialized the non mentioned fields to 0, if I'm not
> totally mistaken.

Hm, it seems you are correct.  And I thought I knew C.

> > Who actually reads this stack trace?  I couldn't find a consumer.
> 
> It's stored directly in the memory pointed to by @addr and that's the freed
> cache memory. If that is used later (UAF) then the stack trace can be
> printed to see where it was freed.

Right... but who reads it?

-- 
Josh

