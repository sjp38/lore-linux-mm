Date: Tue, 12 Jun 2007 12:13:05 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
In-Reply-To: <1181675248.5592.112.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706121211460.561@schroedinger.engr.sgi.com>
References: <20070611225213.GB14458@us.ibm.com>
 <Pine.LNX.4.64.0706111559490.21107@schroedinger.engr.sgi.com>
 <20070611234155.GG14458@us.ibm.com>  <Pine.LNX.4.64.0706111642450.24042@schroedinger.engr.sgi.com>
  <20070612000705.GH14458@us.ibm.com>  <Pine.LNX.4.64.0706111740280.24389@schroedinger.engr.sgi.com>
  <20070612020257.GF3798@us.ibm.com>  <Pine.LNX.4.64.0706111919450.25134@schroedinger.engr.sgi.com>
  <20070612023209.GJ3798@us.ibm.com>  <Pine.LNX.4.64.0706111953220.25390@schroedinger.engr.sgi.com>
  <20070612032055.GQ3798@us.ibm.com> <1181660782.5592.50.camel@localhost>
 <Pine.LNX.4.64.0706121140020.30754@schroedinger.engr.sgi.com>
 <1181675248.5592.112.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jun 2007, Lee Schermerhorn wrote:

> I think that using a local "cursor", as you propose, will work,
> tho'--even for spreading huge page allocations for the reserved lists.
> We may tend to favor low order nodes if one incrementally increases
> nr_hugepages via the sysctl.  But, I don't think that's too regular an
> occurrence.  I'm not sure Nish can use the mempolicy huge page
> interleaving allocator, tho'  That allocates FROM the per node reserved
> lists, and alloc_fresh_huge_page[_node]() is used to fill those lists.  

Yeah one would need to put some thought into it to have the logic in one 
place so that future maintenance will be easier.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
