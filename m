Subject: Re: [PATCH/RFC 0/8] Mapped File Policy Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <200705260044.39065.ak@suse.de>
References: <20070524172821.13933.80093.sendpatchset@localhost>
	 <200705252303.16752.ak@suse.de> <1180127668.21879.18.camel@localhost>
	 <200705260044.39065.ak@suse.de>
Content-Type: text/plain
Date: Tue, 29 May 2007 10:17:50 -0400
Message-Id: <1180448271.5067.43.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nish.aravamudan@gmail.com
List-ID: <linux-mm.kvack.org>

On Sat, 2007-05-26 at 00:44 +0200, Andi Kleen wrote:
> > > I agree. A general page cache policy is probably a good idea and having
> > > it in a cpuset is reasonable too. I've been also toying with the idea to 
> > > change the global default to interleaved for unmapped files.
> > > 
> > > But in this case it's actually not needed to add something to the
> > > address space. It can be all process policy based.
> > 
> > Just so we're clear, I'm talking about "struct address_space", as in the
> > file's "mapping", not as in "struct mm_struct".
> 
> I'm talking about the same. Process/current cpuset policy doesn't need anything in 
> struct address_space

Yes, but for shared policy, that seems like the most natural place to
put it--along with the radix tree that contains the page offset to
memory page [struct] mapping.  Also note that process policy is
potentially transient--certainly so if you use it to place different
files in different locations.  And, it has the same problem that
Christoph noted with using vma policy on shared file mappings--you [can]
get different locations depending on which task faults the page in.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
