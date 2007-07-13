Date: Fri, 13 Jul 2007 14:29:55 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 5/5] [hugetlb] Try to grow pool for MAP_SHARED mappings
In-Reply-To: <1184360742.16671.55.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0707131427140.25414@schroedinger.engr.sgi.com>
References: <20070713151621.17750.58171.stgit@kernel>
 <20070713151717.17750.44865.stgit@kernel>  <20070713130508.6f5b9bbb.pj@sgi.com>
 <1184360742.16671.55.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, mel@skynet.ie, apw@shadowen.org, wli@holomorphy.com, kenchen@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jul 2007, Adam Litke wrote:

> To be honest, I just don't think a global hugetlb pool and cpusets are
> compatible, period.  I wonder if moving to the mempool interface and

Sorry no. We always had per node pools. There is no need to have per 
cpuset pools.

> Hmm, I see what you mean, but cpusets are already broken because we use
> the global resv_huge_pages counter.  I realize that's what the
> cpuset_mems_nr() thing was meant to address but it's not correct.

Well the global reserve counter causes a big reduction in performance 
since it requires the serialization of the hugetlb faults. Could we please 
get this straigthened out? This serialization somehow snuck in when I was 
not looking and it screws up multiple things.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
