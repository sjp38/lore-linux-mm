Date: Mon, 8 Sep 2003 14:26:50 -0400 (EDT)
From: "Raghu R. Arur" <rra2002@aria.ncl.cs.columbia.edu>
Subject: Re: Differences between VM structs
In-Reply-To: <20030908182138.GH29479@holomorphy.com>
Message-ID: <Pine.GSO.4.51.0309081425350.25054@aria.ncl.cs.columbia.edu>
References: <3F5CADD3.2070404@movaris.com> <20030908182138.GH29479@holomorphy.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Kirk True <ktrue@movaris.com>, Linux Memory Manager List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Mon, Sep 08, 2003 at 09:26:59AM -0700, Kirk True wrote:
> >     5. Anonymous memory is memory that is *not* backed by a file, such
> >        as the stack or heap space, right? And mmap is called when
> >        mapping files into memory, right? The why does mmap deal with
> >        anonymous memory (sorry, I'm totally confused here)?
>
> mmap() needed very few extensions to handle the anonymous case.


 What are these extensions in mmap() that need to handle anonymous pages??
 Thanks a lot,
 Raghu
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
