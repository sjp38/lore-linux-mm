Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F1CD96B0003
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 20:06:55 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i76-v6so237841pfk.14
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 17:06:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m14-v6sor4193162pfi.25.2018.10.01.17.06.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Oct 2018 17:06:54 -0700 (PDT)
Date: Tue, 2 Oct 2018 10:06:48 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC PATCH 01/11] nios2: update_mmu_cache clear the old entry
 from the TLB
Message-ID: <20181002100648.39389966@roar.ozlabs.ibm.com>
In-Reply-To: <1538407463.3190.1.camel@intel.com>
References: <20180923150830.6096-1-npiggin@gmail.com>
	<20180923150830.6096-2-npiggin@gmail.com>
	<20180929113712.6dcfeeb3@roar.ozlabs.ibm.com>
	<1538407463.3190.1.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ley Foon Tan <ley.foon.tan@intel.com>
Cc: Guenter Roeck <linux@roeck-us.net>, nios2-dev@lists.rocketboards.org, linux-mm@kvack.org

On Mon, 01 Oct 2018 23:24:23 +0800
Ley Foon Tan <ley.foon.tan@intel.com> wrote:

> On Sat, 2018-09-29 at 11:37 +1000, Nicholas Piggin wrote:
> > Hi,
> > 
> > Did you get a chance to look at these?
> > 
> > This first patch 1/11 solves the lockup problem that Guenter reported
> > with my changes to core mm code. So I plan to resubmit my patches
> > to Andrew's -mm tree with this patch to avoid nios2 breakage.
> > 
> > Thanks,
> > Nick  
> 
> Do you have git repo that contains these patches? If not, can you send
> them as attachment to my email?

I can do that, but it would be good to work with inline patches because
that's the usual method (rather than attached patches).

You should be able to just download or save your email and patch it,
export to mbox and `git am` it, etc. So they should be quite easy to
work with.

Thanks,
Nick
