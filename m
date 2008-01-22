Date: Tue, 22 Jan 2008 21:31:25 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] mmu notifiers #v3
Message-ID: <20080122203125.GC15848@v2.random>
References: <20080113162418.GE8736@v2.random> <20080116124256.44033d48@bree.surriel.com> <478E4356.7030303@qumranet.com> <20080117162302.GI7170@v2.random> <478F9C9C.7070500@qumranet.com> <20080117193252.GC24131@v2.random> <20080121125204.GJ6970@v2.random> <1201030127.6341.39.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1201030127.6341.39.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Izik Eidus <izike@qumranet.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm-devel@lists.sourceforge.net, Avi Kivity <avi@qumranet.com>, clameter@sgi.com, daniel.blueman@quadrics.com, holt@sgi.com, steiner@sgi.com, Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 22, 2008 at 08:28:47PM +0100, Peter Zijlstra wrote:
> I think we can get rid of this rwlock as I think this will seriously
> hurt larger machines.

Yep, I initially considered it, nevertheless given you solved part of
the complication I can add it now ;). The only technical reason for
not using RCU is if certain users of the notifiers are registering and
unregistering at high frequency through objects that may need to be
freed quickly.

I can tell the KVM usage of the mmu notifiers is sure fine to use RCU.
Then I will have to update KVM so that it will free the kvm structure
after waiting a quiescent point to avoid kernel crashing memory
corruption after applying your changes to the mmu notifier.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
