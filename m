Date: Wed, 06 Aug 2003 16:12:46 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: Free list initialization
Message-ID: <739780000.1060211566@flay>
In-Reply-To: <2110.128.2.222.155.1060209130.squirrel@webmail.andrew.cmu.edu>
References: <2110.128.2.222.155.1060209130.squirrel@webmail.andrew.cmu.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anand Eswaran <aeswaran@andrew.cmu.edu>, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

>   Could anybody point me out to the part of the mm code where the  zone
> free-lists are initialized to the remaining system memory  just
> subsequent to setting up of the zone structures . ( so that  say when
> the very first time _alloc_pages executes, the system can use (
> __alloc_pages ()  ->   rmqueue()  free-list to allocate the required
> memory block.
> 
>   I dont seem to be able to find any such code in free_area_init_core().
> 
>   Im using a 2.4.18 kernel.

Suggest you start at free_all_bootmem. IIRC, basically we just call a 
free on every page we have, and the normal buddy free routines populate
the lists. Not very efficient, but who cares? ... it's boottime! ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
