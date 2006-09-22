Date: Fri, 22 Sep 2006 09:36:53 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
In-Reply-To: <20060922092631.ae24a777.pj@sgi.com>
Message-ID: <Pine.LNX.4.64.0609220935510.7083@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org> <20060914234926.9b58fd77.pj@sgi.com>
 <20060915002325.bffe27d1.akpm@osdl.org> <20060915004402.88d462ff.pj@sgi.com>
 <20060915010622.0e3539d2.akpm@osdl.org> <Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com>
 <Pine.LNX.4.63.0609161734220.16748@chino.corp.google.com>
 <20060917041707.28171868.pj@sgi.com> <Pine.LNX.4.64.0609170540020.14516@schroedinger.engr.sgi.com>
 <20060917060358.ac16babf.pj@sgi.com> <Pine.LNX.4.63.0609171329540.25459@chino.corp.google.com>
 <20060917152723.5bb69b82.pj@sgi.com> <Pine.LNX.4.63.0609171643340.26323@chino.corp.google.com>
 <20060917192010.cc360ece.pj@sgi.com> <20060918093434.e66b8887.pj@sgi.com>
 <Pine.LNX.4.63.0609191222310.7790@chino.corp.google.com>
 <Pine.LNX.4.63.0609211510130.17417@chino.corp.google.com>
 <20060922092631.ae24a777.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: David Rientjes <rientjes@google.com>, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 22 Sep 2006, Paul Jackson wrote:

> The topology.h header has:
> > #define LOCAL_DISTANCE               10
> 
> though -no-one- uses it, why I don't know ...

It is a SLIT table reference value. This is the distance to memory that is 
local to the processor and it is the lowest possible value.

> This simple forcing of distances to 10 is probably good enough for your
> setup, but if this gets serious, we'll need to handle multiple arch's,
> and hybrid systems with both fake and real numa.  That will take a bit
> of work to get the SLIT table, node_distance and zonelist sorting
> correct.

Distance 10 is okay if the memory is on the node where the processor sits.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
