Date: Wed, 8 May 2002 11:43:59 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Why *not* rmap, anyway?
In-Reply-To: <E175SVl-0003na-00@starship>
Message-ID: <Pine.LNX.4.44L.0205081143091.32261-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Momchil Velikov <velco@fadata.bg>, William Lee Irwin III <wli@holomorphy.com>, Christian Smith <csmith@micromuse.com>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 May 2002, Daniel Phillips wrote:

> To make this concrete, what would copy_page_range look like, using this
> mechanism?

Or maybe copy_page_range should be behind this mechanism and
modify the data structures directly ?

Remember that the goal is not to abstract out all of the VM,
the goal is to make _most_ of the VM more readable and maintainable.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
