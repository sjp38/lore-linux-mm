Date: Wed, 22 Mar 2000 17:10:45 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: MADV_DONTNEED
Message-ID: <20000322171045.D2850@redhat.com>
References: <20000321022937.B4271@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003221125170.16476-100000@funky.monkey.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.BSO.4.10.10003221125170.16476-100000@funky.monkey.org>; from cel@monkey.org on Wed, Mar 22, 2000 at 12:04:58PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: Jamie Lokier <jamie.lokier@cern.ch>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Mar 22, 2000 at 12:04:58PM -0500, Chuck Lever wrote:
> 
> so we agree that both behaviors might be useful to expose to an
> application.  the only question is what to name them.
> 
> function 1 (could be MADV_DISCARD; currently MADV_DONTNEED):
>   discard pages.  if they are referenced again, the process causes page
>   faults to read original data (zero page for anonymous maps).
> 
> function 2 (could be MADV_FREE; currently msync(MS_INVALIDATE)):
>   release pages, syncing dirty data.  if they are referenced again, the
>   process causes page faults to read in latest data.
> 
> function 3 (could be MADV_ZERO):
>   discard pages.  if they are referenced again, the process sees C-O-W 
>   zeroed pages.
> 
> function 4 (for comparison; currently munmap):
>   release pages, syncing dirty data.  if they are referenced again, the
>   process causes invalid memory access faults.
> 
> i'm interested to hear what big database folks have to say about this.

The requests I've seen from database vendors are specifically for
function 1 above.  I'd expect that they could live with function 3 
too, though --- perhaps the main reason they asked for 1 is that 
this is what they are used to working with on some other systems 
(I don't know offhand of anybody who implements 3: it seems an odd
thing to want to do for shared pages, and is equivalent to 1 for 
private mappings.)

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
