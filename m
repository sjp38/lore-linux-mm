Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BB3C26B0071
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 09:38:29 -0500 (EST)
Received: by gxk7 with SMTP id 7so2951245gxk.14
        for <linux-mm@kvack.org>; Fri, 19 Nov 2010 06:38:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1290119265.26343.814.camel@calx>
References: <1290049259-20108-1-git-send-email-b32542@freescale.com>
	<1290114908.26343.721.camel@calx>
	<alpine.DEB.2.00.1011181333160.26680@chino.kir.corp.google.com>
	<1290119265.26343.814.camel@calx>
Date: Fri, 19 Nov 2010 22:38:27 +0800
Message-ID: <AANLkTikSw2X-n7mC0+Mxosn8w-AAuROkSV7V9G+8ZAVS@mail.gmail.com>
Subject: Re: [PATCH] slub: operate cache name memory same to slab and slob
From: Zeng Zhaoming <zengzm.kernel@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cl@linux-foundation.org, penberg@cs.helsinki.fi, tytso@mit.edu, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> - eliminate dynamically-allocated names (mostly useless when we start
> merging slabs!)

not permit dynamically allocated name. I think this one is better, but
as a rule, describe in header is not enough.
It is helpful to print out some warning when someone break the rule.

> kmem_cache_name() is also a highly suspect function in a
> post-merged-slabs kernel. As ext4 is the only user in the kernel, and it
> got it wrong, perhaps it's time to rip it out.

agree, kmem_cache_name() is ugly.

---
Best Regards
    Zeng Zhaoming

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
