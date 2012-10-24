Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id F0B6B6B0071
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 18:35:48 -0400 (EDT)
Message-ID: <50886D3F.9050403@jp.fujitsu.com>
Date: Wed, 24 Oct 2012 18:35:43 -0400
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] add some drop_caches documentation and info messsge
References: <20121012125708.GJ10110@dhcp22.suse.cz> <20121023164546.747e90f6.akpm@linux-foundation.org> <20121024062938.GA6119@dhcp22.suse.cz> <20121024125439.c17a510e.akpm@linux-foundation.org> <50884F63.8030606@linux.vnet.ibm.com> <20121024134836.a28d223a.akpm@linux-foundation.org> <20121024210600.GA17037@liondog.tnic> <20121024141303.0797d6a1.akpm@linux-foundation.org>
In-Reply-To: <20121024141303.0797d6a1.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: bp@alien8.de, dave@linux.vnet.ibm.com, mhocko@suse.cz, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, rjw@sisk.pl

>> I have drop_caches in my suspend-to-disk script so that the hibernation
>> image is kept at minimum and suspend times are as small as possible.
> 
> hm, that sounds smart.
> 
>> Would that be a valid use-case?
> 
> I'd say so, unless we change the kernel to do that internally.  We do
> have the hibernation-specific shrink_all_memory() in the vmscan code. 
> We didn't see fit to document _why_ that exists, but IIRC it's there to
> create enough free memory for hibernation to be able to successfully
> complete, but no more.

shrink_all_memory() drop minimum memory to be needed from hibernation.
that's trade off matter.

- drop all page cache
  pros.
   speed up hibernation time
  cons.
   after go back from hibernation, system works very slow a while until
   system will get enough file cache.

- drop minimum page cache
  pros.
   system works quickly when go back from hibernation.
  cons.
   relative large hibernation time


So, I'm not fun change hibernation default. hmmm... Does adding tracepint instead of printk
makes sense?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
