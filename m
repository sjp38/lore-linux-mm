Date: Tue, 22 Jan 2008 22:10:47 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] mmu notifiers #v3
In-Reply-To: <20080122203125.GC15848@v2.random>
Message-ID: <Pine.LNX.4.64.0801222207080.27378@blonde.site>
References: <20080113162418.GE8736@v2.random> <20080116124256.44033d48@bree.surriel.com>
 <478E4356.7030303@qumranet.com> <20080117162302.GI7170@v2.random>
 <478F9C9C.7070500@qumranet.com> <20080117193252.GC24131@v2.random>
 <20080121125204.GJ6970@v2.random> <1201030127.6341.39.camel@lappy>
 <20080122203125.GC15848@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Izik Eidus <izike@qumranet.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm-devel@lists.sourceforge.net, Avi Kivity <avi@qumranet.com>, clameter@sgi.com, daniel.blueman@quadrics.com, holt@sgi.com, steiner@sgi.com, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Jan 2008, Andrea Arcangeli wrote:
> 
> Then I will have to update KVM so that it will free the kvm structure
> after waiting a quiescent point to avoid kernel crashing memory
> corruption after applying your changes to the mmu notifier.

It may not be suitable (I've not looked into your needs), but consider
SLAB_DESTROY_BY_RCU: it might give you the easiest way to do that.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
