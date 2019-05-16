Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88421C04AB4
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 13:42:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 451FD20833
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 13:42:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 451FD20833
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=angband.pl
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D56806B0007; Thu, 16 May 2019 09:42:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D06F46B0008; Thu, 16 May 2019 09:42:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF73B6B000A; Thu, 16 May 2019 09:42:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 74B706B0007
	for <linux-mm@kvack.org>; Thu, 16 May 2019 09:42:53 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id m3so1330343wro.18
        for <linux-mm@kvack.org>; Thu, 16 May 2019 06:42:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=rvxBTpS/3RnZR8WyRjpmLce+hbjZH8mmLJbE7UJc17I=;
        b=o8fxbsBZcoqL5Y8yWLLqJx2kWga1qx7uIPhiFG6FU3ecgF5eCNhu0pW7HWnAOGfkI/
         JmB5ypPuaBBqQ750V+gF6x12HwDsIbe7SccPVaUZdkiTNETJS3Z4Lk+HEEz65eYklUbN
         NntmWDbWG8Cs+b5PrmiDDSatSmyfWqzGNovvCHJUYX6s92/ADn7pcan33waWXKTYcIkX
         x7CFAegnAHaI1E9tCSpYlIs4Eh9M8V2ByNjr4xtVOUzWYcl4uf00jo0aUUYFUp+vwcQp
         neqXNnyiCI5hHlsU2Q/xgdaFrBKrcKVFFWUXpRVwAdl5Z0vsfuF/PaFO3g8giAiwgWTC
         Zjsw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kilobyte@angband.pl designates 2001:41d0:602:dbe::8 as permitted sender) smtp.mailfrom=kilobyte@angband.pl
X-Gm-Message-State: APjAAAW6YuQLAMnaqnwqcDIfEb9CcdY3uEvOVGkPvZz5XXhe8QvFZprq
	zLOtd1PmC/p8N1yC/w2vIsHEYt53DqQ9ELT1f6q9ayGDvDBxF6AEcx0BEavLiEO4ry3WjemDy8B
	bctJHmVs0GEYlEnAhOK5/GglgoofrxjuhaQTSb/NUiv/ZzVarEizrYWBbPxgtomE17w==
X-Received: by 2002:adf:cd09:: with SMTP id w9mr14856009wrm.242.1558014173010;
        Thu, 16 May 2019 06:42:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwa4lAXBhMFebumzBjwapEpnrZ+GEex1fAu/XUDEQSrTx6kUjARfFhyZqPUtEGFBTTsH/EG
X-Received: by 2002:adf:cd09:: with SMTP id w9mr14855961wrm.242.1558014172251;
        Thu, 16 May 2019 06:42:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558014172; cv=none;
        d=google.com; s=arc-20160816;
        b=TlDnpiMmNBgjkYNbhKyRRNuIVwS1tGexIw3zAENIbApTL+EhhbpbPJd9hFFGmHe+Xu
         ijLdILl18dINWS1whr3VKuSzYG7fJuija+AbvrhMMWwupezVIHAtaIOyVOadwCwSLo/p
         L+pyFOHmgBNDPNg1bKgKKyZw+eXp7jRG4VzDdJpq3tkZywKZ64HvbUOjQBP6mBDFQ5PR
         V4iwlltCXtRxCGmEmqxbzgbyhot+8PrvI4TeJV1141+gda8CPonN1j46O5Rr8WIyHhOE
         lpUTaHZjqdVklFalY9cCr/9achHG76hJsWi+liY38kyR/udiPQU83uEBBtB7iVbzAk7r
         wk/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=rvxBTpS/3RnZR8WyRjpmLce+hbjZH8mmLJbE7UJc17I=;
        b=nX9E5tM2sZauJ8Cc0ORnygqpnUFkTZ0bnOhHlCIgH6OPnMtfn/50e8EElBsgyK5XIc
         nH/N5YL7QwTKoRNay7+onEBkN+kJauShGOak8y5Tc4CF52jGNW3efkCCtPiGvR6gQofT
         RzEKISVAKXFZyyPpAZFfQJaLtATC7FWlfc5hnnTvub21cRVA11z1l3R4UTSqSoRqGSr/
         1jbekgvpuoDx+/zDcvntULnWV9l9UpacMyfUjy1mrv7gZebN9ZaRfkbftEVRh8rHS6YP
         sIFnfStZVf5FKRlCuJuBf+TaB54KAXDsB+EaSMnw21Qbt4jGlfn9MHJnAgSdEJ7sDujF
         78/w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kilobyte@angband.pl designates 2001:41d0:602:dbe::8 as permitted sender) smtp.mailfrom=kilobyte@angband.pl
Received: from tartarus.angband.pl (tartarus.angband.pl. [2001:41d0:602:dbe::8])
        by mx.google.com with ESMTPS id p26si3704046wmh.48.2019.05.16.06.42.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 May 2019 06:42:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of kilobyte@angband.pl designates 2001:41d0:602:dbe::8 as permitted sender) client-ip=2001:41d0:602:dbe::8;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kilobyte@angband.pl designates 2001:41d0:602:dbe::8 as permitted sender) smtp.mailfrom=kilobyte@angband.pl
Received: from kilobyte by tartarus.angband.pl with local (Exim 4.92)
	(envelope-from <kilobyte@angband.pl>)
	id 1hRGeK-0007a8-24; Thu, 16 May 2019 15:42:20 +0200
Date: Thu, 16 May 2019 15:42:20 +0200
From: Adam Borowski <kilobyte@angband.pl>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com,
	keith.busch@intel.com, kirill.shutemov@linux.intel.com,
	pasha.tatashin@oracle.com, alexander.h.duyck@linux.intel.com,
	ira.weiny@intel.com, andreyknvl@google.com, arunks@codeaurora.org,
	vbabka@suse.cz, cl@linux.com, riel@surriel.com,
	keescook@chromium.org, hannes@cmpxchg.org, npiggin@gmail.com,
	mathieu.desnoyers@efficios.com, shakeelb@google.com, guro@fb.com,
	aarcange@redhat.com, hughd@google.com, jglisse@redhat.com,
	mgorman@techsingularity.net, daniel.m.jordan@oracle.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH RFC 0/5] mm: process_vm_mmap() -- syscall for duplication
 a process mapping
Message-ID: <20190516134220.GB24860@angband.pl>
References: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
 <20190515193841.GA29728@angband.pl>
 <7136aa47-3ce5-243d-6c92-5893b7b1379d@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7136aa47-3ce5-243d-6c92-5893b7b1379d@virtuozzo.com>
X-Junkbait: aaron@angband.pl, zzyx@angband.pl
User-Agent: Mutt/1.10.1 (2018-07-13)
X-SA-Exim-Connect-IP: <locally generated>
X-SA-Exim-Mail-From: kilobyte@angband.pl
X-SA-Exim-Scanned: No (on tartarus.angband.pl); SAEximRunCond expanded to false
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 16, 2019 at 04:10:07PM +0300, Kirill Tkhai wrote:
> On 15.05.2019 22:38, Adam Borowski wrote:
> > On Wed, May 15, 2019 at 06:11:15PM +0300, Kirill Tkhai wrote:
> >> This patchset adds a new syscall, which makes possible
> >> to clone a mapping from a process to another process.
> >> The syscall supplements the functionality provided
> >> by process_vm_writev() and process_vm_readv() syscalls,
> >> and it may be useful in many situation.
> >>
> >> For example, it allows to make a zero copy of data,
> >> when process_vm_writev() was previously used:
> > 
> > I wonder, why not optimize the existing interfaces to do zero copy if
> > properly aligned?  No need for a new syscall, and old code would immediately
> > benefit.
> 
> Because, this is just not possible. You can't zero copy anonymous pages
> of a process to pages of a remote process, when they are different pages.

fork() manages that, and so does KSM.  Like KSM, you want to make a page
shared -- you just skip the comparison step as you want to overwrite the old
contents.

And there's no need to touch the page, as fork() manages that fine no matter
if the page is resident, anonymous in swap, or file-backed, all without
reading from swap.

> >> There are several problems with process_vm_writev() in this example:
> >>
> >> 1)it causes pagefault on remote process memory, and it forces
> >>   allocation of a new page (if was not preallocated);
> >>
> >> 2)amount of memory for this example is doubled in a moment --
> >>   n pages in current and n pages in remote tasks are occupied
> >>   at the same time;
> >>
> >> 3)received data has no a chance to be properly swapped for
> >>   a long time.
> > 
> > That'll handle all of your above problems, except for making pages
> > subject to CoW if written to.  But if making pages writeably shared is
> > desired, the old functions have a "flags" argument that doesn't yet have a
> > single bit defined.


Meow!
-- 
⢀⣴⠾⠻⢶⣦⠀ Latin:   meow 4 characters, 4 columns,  4 bytes
⣾⠁⢠⠒⠀⣿⡁ Greek:   μεου 4 characters, 4 columns,  8 bytes
⢿⡄⠘⠷⠚⠋  Runes:   ᛗᛖᛟᚹ 4 characters, 4 columns, 12 bytes
⠈⠳⣄⠀⠀⠀⠀ Chinese: 喵   1 character,  2 columns,  3 bytes <-- best!

