Date: Thu, 4 May 2000 22:13:24 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 7-4 VM killing (A solution)
In-Reply-To: <39121A22.BA0BA852@sgi.com>
Message-ID: <Pine.LNX.4.10.10005042212480.1156-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: riel@nl.linux.org, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>


On Thu, 4 May 2000, Rajagopal Ananthanarayanan wrote:
> 
> Ok, I may have a solution after having asked, mostly to myself,
> why doesn't shrink_mmap() find pages to free?
> 
> The answer apparenlty is because in 7-4 shrink_mmap(),
> unreferenced pages get filed as "young" if the zone has
> enough pages in it (free_pages > pages_high).

Good catch.

That's obviously a bug, and your fix looks like the obvious fix. Thanks,

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
