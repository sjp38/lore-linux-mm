Date: Wed, 3 Nov 1999 18:09:46 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: The 64GB memory thing
In-Reply-To: <99Nov3.154619gmt.66624@gateway.ukaea.org.uk>
Message-ID: <Pine.LNX.4.10.9911031802330.7408-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Conway <nconway.list@ukaea.org.uk>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Nov 1999, Neil Conway wrote:

> > the 64GB stuff got included recently. It's a significant rewrite of the
> > lowlevel x86 MM and generic MM layer, here is a short description about
> > it:
> > 
> > my 'HIGHMEM patch' went into the 2.3 kernel starting at pre4-2.3.23. This
> > ...
> 
> Wow, that's good news.  But hang on a second, ;-) wasn't there a feature
> freeze at 2.3.18?

most of the changes are in the cleanup category, but yes, it's a boundary
case. I had to and still have to work hard to make this as painless as
possible ...

> And presumably each process is still limited to a 32-bit address space,
> right?

yes, this is a fundamental limitation of x86 processors. Under Linux -in
all 3 high memory modes- user-space virtual memory is 3GB. Nevertheless on
a 8-way box you likely want to run either lots of processes, or a few (but
more than 8 ) processes/threads to use up all available CPU time. This
means with 8x 2GB RSS number crunching processes we already cover 16GB
RAM. So it's not at all unrealistic to have support for more than 4GB RAM!
The foundation for this is that under Linux all 64GB RAM can be mapped
into user processes transparently. I believe other x86 unices (not to talk
about NT) do not have this propertly, they handle 'high memory' as a
special kind of RAM which can be accessed through special system calls.

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
