Date: Tue, 19 Sep 2006 07:10:18 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Get rid of zone_table V2
In-Reply-To: <20060918233337.ef539a2b.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0609190709190.4787@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com>
 <20060918132818.603196e2.akpm@osdl.org> <Pine.LNX.4.64.0609181544420.29365@schroedinger.engr.sgi.com>
 <20060918161528.9714c30c.akpm@osdl.org> <Pine.LNX.4.64.0609181642210.30206@schroedinger.engr.sgi.com>
 <20060918165808.c410d1d4.akpm@osdl.org> <Pine.LNX.4.64.0609181711210.30365@schroedinger.engr.sgi.com>
 <20060918173134.d3850903.akpm@osdl.org> <Pine.LNX.4.64.0609182309050.3152@schroedinger.engr.sgi.com>
 <20060918233337.ef539a2b.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 18 Sep 2006, Andrew Morton wrote:

> On Mon, 18 Sep 2006 23:12:31 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > Hmmm... Actually one can get much better code. If I remove the padding
> > from struct zone then struct zone shrinks from 0x480 to 0x400 in length 
> 
> That padding is there to prevent the rather unrelated lru_lock and
> list_lock from falling into the same cacheline, which is presumed to be a
> bad thing...

Yeah but we have added so much stuff in between that such a thing is 
highly unlikely. Even with padding we could increase the size of zone to 
the next power of two.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
