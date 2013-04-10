Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 3DE3E6B0036
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 17:26:29 -0400 (EDT)
Date: Wed, 10 Apr 2013 23:26:27 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] mm: Print the correct method to disable automatic numa
 migration
Message-ID: <20130410212627.GF16732@two.firstfloor.org>
References: <1365622514-26614-1-git-send-email-andi@firstfloor.org>
 <alpine.DEB.2.02.1304101410160.25932@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1304101410160.25932@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, mgorman@suse.de

> > BTW I think the "default y" is highly dubious for such a
> > experimential feature.
> > 
> 
> CONFIG_NUMA_BALANCING should be default n on everything, but probably for 
> unknown reasons: ARCH_WANT_NUMA_VARIABLE_LOCALITY isn't default n and 
> nothing on x86 actually disables it.

CONFIG_NUMA_BALANCING_DEFAULT_ENABLED is default y

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
