Date: Fri, 14 Jul 2000 10:35:35 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: writeback list
Message-ID: <20000714103535.H3113@redhat.com>
References: <Pine.LNX.4.21.0007131628120.23729-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0007131628120.23729-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Thu, Jul 13, 2000 at 04:30:35PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Jul 13, 2000 at 04:30:35PM -0300, Rik van Riel wrote:
> 
> we may have forgotten something in our new new vm design from
> last weekend. While we have the list head available to put
> pages in the writeback list, we don't have an entry in to put
> the timestamp of the write in struct_page...

It shouldn't matter.  Just assume something like the 30-second sync.
You can keep placeholders in the list for that, or even do something
like have multiple lists, one for the current 30-seconds being synced,
one for the next sync.  You can do the same for 5-second metadata
syncs too if you want; just use separate lists.  It perturbs the LRU a
bit, but then we also have page aging so that's not too bad.  (Are you
planning on using the age values in the inactive list, btw?)

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
