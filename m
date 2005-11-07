Subject: RE: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
From: Rohit Seth <rohit.seth@intel.com>
In-Reply-To: <93700000.1131397118@flay>
References: <20051107205532.CF888185988@thermo.lanl.gov>
	 <93700000.1131397118@flay>
Content-Type: text/plain
Date: Mon, 07 Nov 2005 13:20:15 -0800
Message-Id: <1131398415.18176.50.camel@akash.sc.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Andy Nelson <andy@thermo.lanl.gov>, agl@us.ibm.com, ak@suse.de, akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, gmaxwell@gmail.com, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, mingo@elte.hu, nickpiggin@yahoo.com.au, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

On Mon, 2005-11-07 at 12:58 -0800, Martin J. Bligh wrote:
> >> Isn't it true that most of the times we'll need to be worrying about
> >> run-time allocation of memory (using malloc or such) as compared to
> >> static.
> > 
> > Perhaps for C. Not neccessarily true for Fortran. I don't know
> > anything about how memory allocations proceed there, but there
> > are no `malloc' calls (at least with that spelling) in the language 
> > itself, and I don't know what it does for either static or dynamic 
> > allocations under the hood. It could be malloc like or whatever
> > else. In the language itself, there are language features for
> > allocating and deallocating memory and I've seen code that 
> > uses them, but haven't played with it myself, since my codes 
> > need pretty much all the various pieces memory all the time, 
> > and so are simply statically defined.
> 
> Doesn't fortran shove everything in BSS to make some truly monsterous
> segment?
>  

hmmm....that would be strange.  So, if an app is using TB of data, then
a TB space on disk ...then read in at the load time (or may be some
optimization in the RTLD knows that this is BSS and does not need to get
loaded but then a TB of disk space is a waster).

-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
