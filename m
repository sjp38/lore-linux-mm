Date: Mon, 1 Dec 2003 20:56:20 +0100
From: Pavel Machek <pavel@suse.cz>
Subject: Re: memory hotremove prototype, take 3
Message-ID: <20031201195620.GD255@elf.ucw.cz>
References: <20031201034155.11B387007A@sv1.valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031201034155.11B387007A@sv1.valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> this is a new version of my memory hotplug prototype patch, against
> linux-2.6.0-test11.
> 
> Freeing 100% of a specified memory zone is non-trivial and necessary
> for memory hot removal.  This patch splits memory into 1GB zones, and
> implements complete zone memory freeing using kswapd or "remapping".
> 
> A bit more detailed explanation and some test scripts are at:
> 	http://people.valinux.co.jp/~iwamoto/mh.html

I scanned it...

hotunplug seems cool... How do you deal with kernel data structures in
memory "to be removed"? Or you simply don't allow kmalloc() to
allocate there?

During hotunplug, you copy pages to new locaion. Would it simplify
code if you forced them to be swapped out, instead? [Yep, it would be
slower...]
								Pavel
-- 
When do you have a heart between your knees?
[Johanka's followup: and *two* hearts?]
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
