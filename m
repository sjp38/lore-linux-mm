Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id AECA16B0007
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 23:53:04 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 43-v6so4597247ple.19
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 20:53:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m14-v6sor51897pfi.25.2018.10.02.20.53.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Oct 2018 20:53:03 -0700 (PDT)
Date: Wed, 3 Oct 2018 13:52:57 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC PATCH 01/11] nios2: update_mmu_cache clear the old entry
 from the TLB
Message-ID: <20181003135257.0b631c30@roar.ozlabs.ibm.com>
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

Here's a tree with these patches plus 3 of the core mm code changes
which caused nios2 to hang

https://github.com/npiggin/linux/commits/nios2

Thanks,
Nick
