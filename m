Date: Wed, 4 Oct 2006 20:00:46 -0700 (PDT)
From: David Rientjes <rientjes@cs.washington.edu>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
In-Reply-To: <20061004195313.892838e4.pj@sgi.com>
Message-ID: <Pine.LNX.4.64N.0610041954470.642@attu2.cs.washington.edu>
References: <20060925091452.14277.9236.sendpatchset@v0> <20061001231811.26f91c47.pj@sgi.com>
 <Pine.LNX.4.64N.0610012330110.10476@attu4.cs.washington.edu>
 <20061001234858.fe91109e.pj@sgi.com> <Pine.LNX.4.64N.0610020001240.7510@attu3.cs.washington.edu>
 <20061002014121.28b759da.pj@sgi.com> <20061003111517.a5cc30ea.pj@sgi.com>
 <Pine.LNX.4.64N.0610031231270.4919@attu3.cs.washington.edu>
 <20061004084552.a07025d7.pj@sgi.com> <Pine.LNX.4.64N.0610041456480.19080@attu2.cs.washington.edu>
 <20061004192714.20412e08.pj@sgi.com> <Pine.LNX.4.64N.0610041931170.32103@attu2.cs.washington.edu>
 <20061004195313.892838e4.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 4 Oct 2006, Paul Jackson wrote:

> So ... I ask again ... why avoid this speed up on systems not emulating
> nodes?
> 

Aren't we back in the case where zonelist ordering should be good enough 
so that there's no performance enhancement with the speed up on systems 
not emulating nodes?  I'm just curious why there's a lot of naysaying 
going on about ordering the zonelists which has worked well in the past 
and now that mentality has suddenly changed with no data to support it.

[ And going about proving that it's beneficial even for something like a
  dual-core 64-bit setup with UMA is easy and can be done at any time
  (as long as you have a 64-bit machine, which I don't anymore).  So
  let's see the data. ]

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
