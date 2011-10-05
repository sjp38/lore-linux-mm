Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1ACCF6B005A
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 15:19:34 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p95JJTpB029329
	for <linux-mm@kvack.org>; Wed, 5 Oct 2011 12:19:31 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by hpaq12.eem.corp.google.com with ESMTP id p95JIuMq009973
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 5 Oct 2011 12:19:27 -0700
Received: by pzk36 with SMTP id 36so5521423pzk.7
        for <linux-mm@kvack.org>; Wed, 05 Oct 2011 12:19:27 -0700 (PDT)
Date: Wed, 5 Oct 2011 12:19:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFCv3][PATCH 4/4] show page size in /proc/$pid/numa_maps
In-Reply-To: <1317804891.2473.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Message-ID: <alpine.DEB.2.00.1110051213280.23587@chino.kir.corp.google.com>
References: <20111001000856.DD623081@kernel> <20111001000900.BD9248B8@kernel> <alpine.DEB.2.00.1110042344250.16359@chino.kir.corp.google.com> <1317798564.3099.12.camel@edumazet-laptop> <alpine.DEB.2.00.1110050012490.18906@chino.kir.corp.google.com>
 <1317804891.2473.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, James.Bottomley@hansenpartnership.com, hpa@zytor.com

On Wed, 5 Oct 2011, Eric Dumazet wrote:

> > Why on earth do we want to convert a byte value into a string so a script 
> > can convert it the other way around?  Do you have a hard time parsing 
> > 4096, 2097152, and 1073741824 to be 4K, 2M, and 1G respectively?  
> 
> Yes I do. I dont have in my head all possible 2^X values, but K, M, G,
> T : thats ok (less neurons needed)
> 
> You focus on current x86_64 hardware.
> 
> Some arches have lot of different choices. (powerpc has 64K, 16M, 16GB
> pages)
> 
> In 10 years, you'll have pagesize=549755813888, or maybe
> pagesize=8589934592
> 
> I pretty much prefer pagesize=512GB and pagesize=8TB
> 
> This is consistent with usual conventions and practice.
> 

I'm indifferent whether it's displayed in bytes (so a script could do 
pagesize * anon, for example, and find the exact amount of anonymous 
memory for that vma without needing smaps) or in KB like /proc/pid/smaps, 
grep Hugepagesize /proc/meminfo, and ls /sys/kernel/mm/hugepages.

In other words, pagesize= in /proc/pid/numa_maps is the least of your 
worries if you're serious about this: you would have already struggled 
with smaps, meminfo, and the sysfs interface for reserving the hugepages 
in the first place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
