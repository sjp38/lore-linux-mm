Date: Tue, 8 Nov 2005 13:12:58 +1100
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-ID: <20051108021258.GB10769@localhost.localdomain>
References: <1131396662.18176.41.camel@akash.sc.intel.com> <20051107205532.CF888185988@thermo.lanl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051107205532.CF888185988@thermo.lanl.gov>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Nelson <andy@thermo.lanl.gov>
Cc: agl@us.ibm.com, rohit.seth@intel.com, ak@suse.de, akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, gmaxwell@gmail.com, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@mbligh.org, mel@csn.ul.ie, mingo@elte.hu, nickpiggin@yahoo.com.au, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 07, 2005 at 01:55:32PM -0700, Andy Nelson wrote:
> 
> Hi,
> 
> >Isn't it true that most of the times we'll need to be worrying about
> >run-time allocation of memory (using malloc or such) as compared to
> >static.
> 
> Perhaps for C. Not neccessarily true for Fortran. I don't know
> anything about how memory allocations proceed there, but there
> are no `malloc' calls (at least with that spelling) in the language 
> itself, and I don't know what it does for either static or dynamic 
> allocations under the hood. It could be malloc like or whatever
> else. In the language itself, there are language features for
> allocating and deallocating memory and I've seen code that 
> uses them, but haven't played with it myself, since my codes 
> need pretty much all the various pieces memory all the time, 
> and so are simply statically defined.
> 
> If you call something like malloc yourself, you risk portability 
> problems in Fortran. Fortran 2003 supposedly addresses some of
> this with some C interop features, but only got approved within 
> the last year, and no compilers really exist for it yet, let
> alone having code written.

I believe F90 has a couple of different ways of dynamically allocating
memory.  I'd expect in most implementations the FORTRAN runtime would
translate that into a malloc() call.  However, as I gather, many HPC
apps are written by people who are scientists first and programmers
second, and who still think in F77 where there is no dynamic memory
allocation.  Hence, gigantic arrays in the BSS are common FORTRAN
practice.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
