Message-ID: <46117916.2040601@google.com>
Date: Mon, 02 Apr 2007 14:43:50 -0700
From: Martin Bligh <mbligh@google.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>  <20070401071029.23757.78021.sendpatchset@schroedinger.engr.sgi.com>  <200704011246.52238.ak@suse.de>  <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com>  <1175544797.22373.62.camel@localhost.localdomain>  <Pine.LNX.4.64.0704021324480.31842@schroedinger.engr.sgi.com> <1175548086.22373.99.camel@localhost.localdomain> <Pine.LNX.4.64.0704021422040.2272@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0704021422040.2272@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Dave Hansen <hansendc@us.ibm.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

> Note that these arguments on DISCONTIG are flame bait for many SGIers. 
> We usually see this as an attack on DISCONTIG/VMEMMAP which is the 
> existing best performing implementation for page_to_pfn and vice 
> versa. Please lets stop the polarization. We want one consistent scheme 
> to manage memory everywhere. I do not care what its called as long as it 
> covers all the bases and is not a glaring performance regresssion (like 
> SPARSEMEM so far).

The main conceptual difference (in my mind) was not having one
bastardized data structure (pg_data_t) that meant different
things in different situations (is it a node, or a section
of discontig mem?). Also we didn't support discontig mem within
a node (at least with the old discontigmem), which was partly
the result of that hybridization.

Beyond that, it's just naming really.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
