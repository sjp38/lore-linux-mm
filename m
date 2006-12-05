Date: Tue, 5 Dec 2006 08:17:51 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: RE: la la la la ... swappiness
In-Reply-To: <200612050641.kB56f7wY018196@ms-smtp-06.texas.rr.com>
Message-ID: <Pine.LNX.4.64.0612050754020.3542@woody.osdl.org>
References: <200612050641.kB56f7wY018196@ms-smtp-06.texas.rr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aucoin <Aucoin@Houston.RR.com>
Cc: 'Nick Piggin' <nickpiggin@yahoo.com.au>, 'Tim Schmielau' <tim@physik3.uni-rostock.de>, 'Andrew Morton' <akpm@osdl.org>, clameter@sgi.com, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Tue, 5 Dec 2006, Aucoin wrote:
>
> > Louis, exactly how do you allocate that big 1.6GB shared area?
> 
> Ummm, shm_open, ftruncate, mmap ? Is it a trick question ? The process
> responsible for initially setting up the shared area doesn't stay resident.

Not a trick question, I just suddenly realized that I really should have 
expected the SHM pages to show up in the LRU lists (either inactive or 
active) and shown up as "cached" pages too. Afaik, the SHM routines all 
end up using the page cache and the LRU for the backing store.

But your 1.6GB thing doesn't show up anywhere.

(I'm sure it's intentional, and I've just forgotten some detail. We 
probably remove pages from the LRU lists when they are locked. Anyway, my 
original point was that since the pages _aren't_ on the LRU lists, the VM 
really should basically act as if they didn't exist at all, but there are 
probably things that still base their decisions on the _total_ amount of 
memory)

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
