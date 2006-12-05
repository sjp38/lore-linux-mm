Date: Tue, 5 Dec 2006 10:44:19 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: la la la la ... swappiness
In-Reply-To: <Pine.LNX.4.64.0612051031170.11860@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0612051038250.3542@woody.osdl.org>
References: <200612050641.kB56f7wY018196@ms-smtp-06.texas.rr.com>
 <Pine.LNX.4.64.0612050754020.3542@woody.osdl.org> <20061205085914.b8f7f48d.akpm@osdl.org>
 <f353cb6c194d4.194d4f353cb6c@texas.rr.com> <Pine.LNX.4.64.0612051031170.11860@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Aucoin <aucoin@houston.rr.com>, Andrew Morton <akpm@osdl.org>, 'Nick Piggin' <nickpiggin@yahoo.com.au>, 'Tim Schmielau' <tim@physik3.uni-rostock.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Tue, 5 Dec 2006, Christoph Lameter wrote:
> 
> We do not support swapping / reclaim for huge pages.

Well, Louis doesn't actually _want_ swapping or reclaim on them. He just 
wants the system to run well with the remaining 400MB of memory in his 
machine.

Which it doesn't. It just OOM's for some reason.

We still haven't seen the oom debug output though, I think. It should talk 
about some of the state (it calls "show_mem()", which should call 
"show_free_areas()", which should tell a lot about why the heck it 
thought it was out of memory.

But maybe Louis posted it and I just missed it.

Anyway, if it's hugepages, then I don't see why Louis even _wants_ to turn 
down swappiness. The hugepages won't be swapped out regardless.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
