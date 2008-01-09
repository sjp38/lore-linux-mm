Date: Wed, 9 Jan 2008 13:51:42 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG]  at mm/slab.c:3320
In-Reply-To: <20080109214707.GA26941@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0801091349430.12505@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0801021227580.20331@schroedinger.engr.sgi.com>
 <20080103155046.GA7092@skywalker> <20080107102301.db52ab64.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0801071008050.22642@schroedinger.engr.sgi.com>
 <20080108104016.4fa5a4f3.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0801072131350.28725@schroedinger.engr.sgi.com>
 <20080109065015.GG7602@us.ibm.com> <Pine.LNX.4.64.0801090949440.10163@schroedinger.engr.sgi.com>
 <20080109185859.GD11852@skywalker> <Pine.LNX.4.64.0801091122490.11317@schroedinger.engr.sgi.com>
 <20080109214707.GA26941@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, lee.schermerhorn@hp.com, bob.picco@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On Wed, 9 Jan 2008, Nishanth Aravamudan wrote:

> And given that the original mail has bug at mm/slab.c:3320, I assume we're
> still hitting the
> 
> BUG_ON(ac->avail > 0 || !l3);

No we are in a different function here.

> Hrm, shouldn't we remove the !l3 bit from the BUG_ON? But even so, unless for
> some reason the BUG_ON is being checked before the if (!l3), are we hitting
> (ac->avail > 0)?

Yes we should remove the !l3 bit. There cannot be any objects in 
SLABs per cpu queue if there is no node structure. per cpu queues can 
only be refilled from the local node, not from foreign nodes. And in this 
particular case there is no memory available from the local node. So 
ac->avail == 0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
