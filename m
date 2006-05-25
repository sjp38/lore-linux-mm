Subject: Re: [PATCH 1/3] mm: tracking shared dirty pages
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0605250921300.23726@schroedinger.engr.sgi.com>
References: <20060525135534.20941.91650.sendpatchset@lappy>
	 <20060525135555.20941.36612.sendpatchset@lappy>
	 <Pine.LNX.4.64.0605250921300.23726@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 25 May 2006 19:03:02 +0200
Message-Id: <1148576582.10561.83.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-05-25 at 09:27 -0700, Christoph Lameter wrote:
> On Thu, 25 May 2006, Peter Zijlstra wrote:
> 
> >  - rebased on top of David Howells' page_mkwrite() patch.
> 
> I am a bit confused about the need for Davids patch. set_page_dirty() is 
> already a notification that a page is to be dirtied. Why do we need it 
> twice? set_page_dirty could return an error code and the file system can 
> use the set_page_dirty() hook to get its notification. What we would need 
> to do is to make sure that set_page_dirty can sleep.

Ah, I see what you're saying here. Good point, David, Hugh?

The reason I did it was because of Hugh's trick to use MAP_SHARED
protection and building on top of it naturally solves the patch conflict
Andrew would have had to resolve otherwise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
