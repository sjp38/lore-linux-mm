Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C01406B014B
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 17:34:16 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o9TLDCB9024994
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 17:13:12 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9TLYCXs2195624
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 17:34:12 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9TLYBjS029440
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 19:34:12 -0200
Subject: Re: oom killer question
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20101029213004.GA2315@osiris.boeblingen.de.ibm.com>
References: <20101029121456.GA6896@osiris.boeblingen.de.ibm.com>
	 <1288376008.13539.8991.camel@nimitz>
	 <20101029213004.GA2315@osiris.boeblingen.de.ibm.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Fri, 29 Oct 2010 14:34:09 -0700
Message-ID: <1288388049.6872.263.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Hartmut Beinlich <HBEINLIC@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-10-29 at 23:30 +0200, Heiko Carstens wrote:
> 
> Looking only at slab_reclaimable I had the impression there _could_
> have been plenty of memory that could be reclaimed. Just wondering :) 

Yeah, something funky is probably going on.

But, the "reclaimable" ones aren't guaranteed to be reclaimable.  It
just means that we can usually reclaim most of them.  If you have a
refcount leak on an object or something like that, they're effectively
unreclaimable still.

So, either way, the next step is to see which slab it was that blew up.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
