Date: Thu, 6 Jul 2000 14:32:51 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: page_table_lock problem [was: Re: 2.4 / 2.5 VM plans]
Message-ID: <20000706143251.C4237@redhat.com>
References: <Pine.LNX.4.21.0006242357020.15823-100000@duckman.distro.conectiva> <20000629144408.R3473@redhat.com> <20000706155123.A11504@saw.sw.com.sg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000706155123.A11504@saw.sw.com.sg>; from saw@saw.sw.com.sg on Thu, Jul 06, 2000 at 03:51:23PM +0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrey Savochkin <saw@saw.sw.com.sg>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Jul 06, 2000 at 03:51:23PM +0800, Andrey Savochkin wrote:
> 
> I've looked at RSS updates in 2.4.0 kernels.
> You're right, they are not protected enough from
> concurrent updates from mm paths (mmap, page fault handler) and swapout
> path.  Moreover, I found that page_table_lock which is supposed to serialize
> page table updates from mm and swapout paths isn't taken in the later at all!
> Is it a bug or am I missing something?

Sorry, I don't have time to look closely at this right now --- I'm
swamped with travel and ext3 work, and I've just moved house...

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
