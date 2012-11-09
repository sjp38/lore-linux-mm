Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 24ED76B002B
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 19:38:20 -0500 (EST)
Date: Thu, 8 Nov 2012 16:38:18 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] Add a test program for variable page sizes in
 mmap/shmget v2
Message-ID: <20121109003818.GC2726@tassilo.jf.intel.com>
References: <1352408486-4318-1-git-send-email-andi@firstfloor.org>
 <20121108132946.c2b9e8b7.akpm@linux-foundation.org>
 <20121108220150.GA2726@tassilo.jf.intel.com>
 <20121108140938.357228e0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121108140938.357228e0.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Dave Young <dyoung@redhat.com>

> > My test system didn't hang FWIW.
> 
> It wasn't thuge-gen which hung.  It happened really early in
> run_vmtests, perhaps setting nr_hugepages.

I mean it didn't hang for the full script.

Ah this causes compaction so if you have a lot of fragmented memory
it may run for a lot time with very long latencies, but inhibiting
page faults of other processes.

It probably would have recovered.

it's a general problem that others are complaining about too.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
