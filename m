Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jA7LXnuF015575
	for <linux-mm@kvack.org>; Mon, 7 Nov 2005 16:33:49 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id jA7LXnMf071994
	for <linux-mm@kvack.org>; Mon, 7 Nov 2005 16:33:49 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jA7LXmv3020135
	for <linux-mm@kvack.org>; Mon, 7 Nov 2005 16:33:49 -0500
Subject: RE: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1131398415.18176.50.camel@akash.sc.intel.com>
References: <20051107205532.CF888185988@thermo.lanl.gov>
	 <93700000.1131397118@flay>  <1131398415.18176.50.camel@akash.sc.intel.com>
Content-Type: text/plain
Date: Mon, 07 Nov 2005 15:33:03 -0600
Message-Id: <1131399183.25133.99.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rohit Seth <rohit.seth@intel.com>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, Andy Nelson <andy@thermo.lanl.gov>, ak@suse.de, akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, gmaxwell@gmail.com, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, mingo@elte.hu, nickpiggin@yahoo.com.au, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

On Mon, 2005-11-07 at 13:20 -0800, Rohit Seth wrote:
> On Mon, 2005-11-07 at 12:58 -0800, Martin J. Bligh wrote:
> > >> Isn't it true that most of the times we'll need to be worrying about
> > >> run-time allocation of memory (using malloc or such) as compared to
> > >> static.
> > > 
> > > Perhaps for C. Not neccessarily true for Fortran. I don't know
> > > anything about how memory allocations proceed there, but there
> > > are no `malloc' calls (at least with that spelling) in the language 
> > > itself, and I don't know what it does for either static or dynamic 
> > > allocations under the hood. It could be malloc like or whatever
> > > else. In the language itself, there are language features for
> > > allocating and deallocating memory and I've seen code that 
> > > uses them, but haven't played with it myself, since my codes 
> > > need pretty much all the various pieces memory all the time, 
> > > and so are simply statically defined.
> > 
> > Doesn't fortran shove everything in BSS to make some truly monsterous
> > segment?
> >  
> 
> hmmm....that would be strange.  So, if an app is using TB of data, then
> a TB space on disk ...then read in at the load time (or may be some
> optimization in the RTLD knows that this is BSS and does not need to get
> loaded but then a TB of disk space is a waster).

Nope, the bss is defined as the difference in file size (on disk) and
the memory size (as specified in the ELF program header for the data
segment).  So the kernel loads the pre-initialized data from disk and
extends the mapping to include room for the bss. 

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
