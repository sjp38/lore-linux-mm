Date: Tue, 22 Jan 2008 12:20:20 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG] at mm/slab.c:3320
In-Reply-To: <20080120005806.GA25669@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0801221217320.27950@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0801072131350.28725@schroedinger.engr.sgi.com>
 <20080109065015.GG7602@us.ibm.com> <Pine.LNX.4.64.0801090949440.10163@schroedinger.engr.sgi.com>
 <20080109185859.GD11852@skywalker> <Pine.LNX.4.64.0801091122490.11317@schroedinger.engr.sgi.com>
 <20080109214707.GA26941@us.ibm.com> <Pine.LNX.4.64.0801091349430.12505@schroedinger.engr.sgi.com>
 <20080109221315.GB26941@us.ibm.com> <Pine.LNX.4.64.0801091601080.14723@schroedinger.engr.sgi.com>
 <84144f020801170431l2d6d0d63i1fb7ebc5145539f4@mail.gmail.com>
 <20080120005806.GA25669@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Nishanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, lee.schermerhorn@hp.com, bob.picco@hp.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, 20 Jan 2008, Mel Gorman wrote:

> I tried this patch and it didn't work out. Oops occured all in relation to
> l3. I did see the obvious flaw and getting this close to 2.6.24 and the
> other boot-problem on PPC64, I don't think we have the luxury of messing
> around and maybe this should be tried again later? The minimum revert is
> the following patch. I have verified it boots the machine in question.

Ack. It seems that my patch in upstream cannot work since alien caches can 
be used on memoryless nodes (they are actually the only thing used on slab 
free since all frees are remote). The alien caches are hanging off the per 
node structures. So we must create mostly useless per node structures (l3) 
in SLAB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
