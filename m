Date: Wed, 9 Jan 2008 11:23:59 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG]  at mm/slab.c:3320
In-Reply-To: <20080109185859.GD11852@skywalker>
Message-ID: <Pine.LNX.4.64.0801091122490.11317@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0712271130200.30555@schroedinger.engr.sgi.com>
 <20071228051959.GA6385@skywalker> <Pine.LNX.4.64.0801021227580.20331@schroedinger.engr.sgi.com>
 <20080103155046.GA7092@skywalker> <20080107102301.db52ab64.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0801071008050.22642@schroedinger.engr.sgi.com>
 <20080108104016.4fa5a4f3.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0801072131350.28725@schroedinger.engr.sgi.com>
 <20080109065015.GG7602@us.ibm.com> <Pine.LNX.4.64.0801090949440.10163@schroedinger.engr.sgi.com>
 <20080109185859.GD11852@skywalker>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, lee.schermerhorn@hp.com, bob.picco@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On Thu, 10 Jan 2008, Aneesh Kumar K.V wrote:

> kernel BUG at mm/slab.c:3323!

That is 

        l3 = cachep->nodelists[nodeid];
        BUG_ON(!l3);

retry:
        check_irq_off();
        ^^^^ this statment?

or the BUG_ON(!l3)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
