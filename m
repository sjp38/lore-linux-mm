Date: Tue, 28 Aug 2007 22:18:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Selective swap out of processes
In-Reply-To: <1188320070.11543.85.camel@bastion-laptop>
Message-ID: <Pine.LNX.4.64.0708282216060.18958@schroedinger.engr.sgi.com>
References: <1188320070.11543.85.camel@bastion-laptop>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1700579579-1187572556-1188364736=:18958"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Javier Cabezas =?ISO-8859-1?Q?Rodr=EDguez?= <jcabezas@ac.upc.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

---1700579579-1187572556-1188364736=:18958
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 28 Aug 2007, Javier Cabezas Rodr=EDguez wrote:

> Now I am implementing the memory freeing. The biggest problem here is
> that the regular swapping out algorithm of the kernel only frees memory
> when it is needed, so I don't know which is the behaviour of the
> standard routines in this situation.  I have looked at the standard
> swapping functions (shrink_zones, shrink_zone, ...) and I think they
> handle all the  process page types I enumerated previously. So, for each
> VMA of the process,  I build a page list with all the pages and pass it
> as a parameter to shrink_page_list (before that I remove them from the
> LRU active/inactive lists with del_page_from_lru).

You may want to look at the page migration logic and in particular the=20
implementation of memory unplug in Andrew's tree. Memory unplug moves
memory to another node. You could use the same logic but instead of=20
moving pages reclaim them. Movable pages are reclaimable and much of the=20
page migration logic is based on reclaim.

---1700579579-1187572556-1188364736=:18958--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
