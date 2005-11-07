Received: from thermo.lanl.gov (thermo.lanl.gov [128.165.59.202])
	by mailwasher-b.lanl.gov (8.12.11/8.12.11/(ccn-5)) with SMTP id jA7KtWcr028964
	for <linux-mm@kvack.org>; Mon, 7 Nov 2005 13:55:33 -0700
Subject: RE: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
In-Reply-To: <1131396662.18176.41.camel@akash.sc.intel.com>
Message-Id: <20051107205532.CF888185988@thermo.lanl.gov>
Date: Mon,  7 Nov 2005 13:55:32 -0700 (MST)
From: andy@thermo.lanl.gov (Andy Nelson)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: agl@us.ibm.com, rohit.seth@intel.com
Cc: ak@suse.de, akpm@osdl.org, andy@thermo.lanl.gov, arjan@infradead.org, arjanv@infradead.org, gmaxwell@gmail.com, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@mbligh.org, mel@csn.ul.ie, mingo@elte.hu, nickpiggin@yahoo.com.au, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

Hi,

>Isn't it true that most of the times we'll need to be worrying about
>run-time allocation of memory (using malloc or such) as compared to
>static.

Perhaps for C. Not neccessarily true for Fortran. I don't know
anything about how memory allocations proceed there, but there
are no `malloc' calls (at least with that spelling) in the language 
itself, and I don't know what it does for either static or dynamic 
allocations under the hood. It could be malloc like or whatever
else. In the language itself, there are language features for
allocating and deallocating memory and I've seen code that 
uses them, but haven't played with it myself, since my codes 
need pretty much all the various pieces memory all the time, 
and so are simply statically defined.

If you call something like malloc yourself, you risk portability 
problems in Fortran. Fortran 2003 supposedly addresses some of
this with some C interop features, but only got approved within 
the last year, and no compilers really exist for it yet, let
alone having code written.


Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
