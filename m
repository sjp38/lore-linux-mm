Message-ID: <3DEFA441.8070800@earthlink.net>
Date: Thu, 05 Dec 2002 12:08:49 -0700
From: Joseph A Knapka <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Re: Question on swapping
References: <3DEE1CA5.7C45C252@scs.ch>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Maletinsky <maletinsky@scs.ch>
Cc: linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Martin Maletinsky wrote:
> Hello,
> 
> I am looking at the swapping mechanism in Linux. I have read the relevant chapter 16 in 'Understanding the Linux Kernel' from Bovet&Cesati, and looked at the 2.2.18 kernel
> source code. I still have the follwing question:
> 
> Function try_to_swap_out() [p. 481 in 'Understanding the Linux Kernel']:
> If the page in question already belongs to the swap cache, the function performs no data transfer to the swap space on the disk (but only marks the page as swapped out).
> The corresponding comment in the try_to_swap_out() functions states 'Is the page already in the swap cache? If so, ..... - it is already up-to-date on disk.
> Understanding the Linux Kernel states on p. 482 'If the page belongs to the swap cache .... no memory transfer is performed'.
> Now my question is, couldn't the page have been modified since it was added to the swap cache (and written to disk), and thus differ from the data in the swap space? In
> this case shouldn't the page be written to disk (again)?

If the page is in the swap cache, it's *effectively* up to date on disk,
because the swap cache page is *the* authoritative image of the page.
If it's dirty it will get written out by page_launder() in short
order, because whomever dirtied it set the page_dirty bit in the
page struct. That issue is unimportant to the process doing the
swap_out, though - all it cares about is that the page is going
to be taken care of by the cache machinery.

Cheers,

-- Joe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
