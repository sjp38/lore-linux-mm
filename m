Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 2860E6B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 17:29:11 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rq13so482719pbb.34
        for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:29:10 -0700 (PDT)
Date: Wed, 10 Apr 2013 14:29:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Print the correct method to disable automatic numa
 migration
In-Reply-To: <20130410212627.GF16732@two.firstfloor.org>
Message-ID: <alpine.DEB.2.02.1304101427510.25932@chino.kir.corp.google.com>
References: <1365622514-26614-1-git-send-email-andi@firstfloor.org> <alpine.DEB.2.02.1304101410160.25932@chino.kir.corp.google.com> <20130410212627.GF16732@two.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, mgorman@suse.de

On Wed, 10 Apr 2013, Andi Kleen wrote:

> > > BTW I think the "default y" is highly dubious for such a
> > > experimential feature.
> > > 
> > 
> > CONFIG_NUMA_BALANCING should be default n on everything, but probably for 
> > unknown reasons: ARCH_WANT_NUMA_VARIABLE_LOCALITY isn't default n and 
> > nothing on x86 actually disables it.
> 
> CONFIG_NUMA_BALANCING_DEFAULT_ENABLED is default y
> 

Yeah, but CONFIG_NUMA_BALANCING isn't, so if you manually have to enable 
it then why do we care about CONFIG_NUMA_BALANCING_DEFAULT_ENABLED?  It 
seems appropriate if you have to go out of your way to enable 
NUMA_BALANCING that you'll want the feature enabled by default when you 
boot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
