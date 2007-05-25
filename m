From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH/RFC 0/8] Mapped File Policy Overview
Date: Sat, 26 May 2007 00:44:38 +0200
References: <20070524172821.13933.80093.sendpatchset@localhost> <200705252303.16752.ak@suse.de> <1180127668.21879.18.camel@localhost>
In-Reply-To: <1180127668.21879.18.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705260044.39065.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nish.aravamudan@gmail.com
List-ID: <linux-mm.kvack.org>

> > I agree. A general page cache policy is probably a good idea and having
> > it in a cpuset is reasonable too. I've been also toying with the idea to 
> > change the global default to interleaved for unmapped files.
> > 
> > But in this case it's actually not needed to add something to the
> > address space. It can be all process policy based.
> 
> Just so we're clear, I'm talking about "struct address_space", as in the
> file's "mapping", not as in "struct mm_struct".

I'm talking about the same. Process/current cpuset policy doesn't need anything in 
struct address_space

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
