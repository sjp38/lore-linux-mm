Date: Tue, 5 Dec 2006 10:31:52 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: la la la la ... swappiness
In-Reply-To: <f353cb6c194d4.194d4f353cb6c@texas.rr.com>
Message-ID: <Pine.LNX.4.64.0612051031170.11860@schroedinger.engr.sgi.com>
References: <200612050641.kB56f7wY018196@ms-smtp-06.texas.rr.com>
 <Pine.LNX.4.64.0612050754020.3542@woody.osdl.org> <20061205085914.b8f7f48d.akpm@osdl.org>
 <f353cb6c194d4.194d4f353cb6c@texas.rr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aucoin <aucoin@houston.rr.com>
Cc: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, 'Nick Piggin' <nickpiggin@yahoo.com.au>, 'Tim Schmielau' <tim@physik3.uni-rostock.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 5 Dec 2006, aucoin@houston.rr.com wrote:

> From: Andrew Morton <akpm@osdl.org>
> > Yes, those pages should be on the LRU.  I suspect they never got 
> Oops, details, details.
> These are huge pages .... apologies for leaving that out.

We do not support swapping / reclaim for huge pages.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
