Date: Tue, 7 May 2002 12:25:47 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Why *not* rmap, anyway?
Message-ID: <20020507192547.GU15756@holomorphy.com>
References: <Pine.LNX.4.33.0205071625570.1579-100000@erol> <Pine.LNX.4.44L.0205071620270.7447-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L.0205071620270.7447-100000@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Christian Smith <csmith@micromuse.com>, Daniel Phillips <phillips@bonn-fries.net>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 May 2002, Christian Smith wrote:
>> I don't like using a data structure as an 'API'. An API ideally gives
>> you an interface to what you need to do, not how it's done. Sure, APIs
>> can become obsolete, but function calls are MUCH easier to provide
>> legacy support for than a large, complex data structure.

On Tue, May 07, 2002 at 04:23:34PM -0300, Rik van Riel wrote:
> OK, this I can agree with.
> I'd be interested in working with you towards a way of
> hiding some of the data structure manipulation behind
> a more abstract interface, kind of like what I've done
> with the -rmap stuff ... nothing outside of rmap.c
> knows about struct pte_chain and nothing should know.
> If you could help find ways in which we can abstract
> out manipulation of some more data structures I'd be
> really happy to help implement and clean up stuff.
> kind regards,

Procedural interfaces to pagetable manipulations are largely what
the BSD pmap and SVR4 HAT layers consisted of, no?

Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
