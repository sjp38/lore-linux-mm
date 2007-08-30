Date: Thu, 30 Aug 2007 11:36:36 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: speeding up swapoff
In-Reply-To: <m1d4x52zri.fsf@ebiederm.dsl.xmission.com>
Message-ID: <Pine.LNX.4.64.0708301132470.26365@blonde.wat.veritas.com>
References: <1188394172.22156.67.camel@localhost>
 <Pine.LNX.4.64.0708291558480.27467@blonde.wat.veritas.com>
 <m1d4x52zri.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Daniel Drake <ddrake@brontes3d.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 30 Aug 2007, Eric W. Biederman wrote:
> 
> There is one other possibility.  Typically the swap code is using
> compatibility disk I/O functions instead of the best the kernel
> can offer.  I haven't looked recently but it might be worth just
> making certain that there isn't some low-level optimization or
> cleanup possible on that path.  Although I may just be thinking
> of swapfiles.

Andrew rewrote swapfile support in 2.5, making it use FIBMAP at
swapon time: so that in 2.6 swapfiles are as deadlock-free and
as efficient (unless the swapfile happens to be badly fragmented)
as raw disk partitions.

There's certainly scope for a study of I/O patterns in swapping,
it's hard to imagine that improvements couldn't be made (but also
easy to imagine endless disputes over different kinds of workload).
But most people would appreciate an improvement in active swapping,
and not care very much about the swapoff.

Regarding Daniel's use of swapoff: it's a very heavy sledgehammer
for cracking that nut, I strongly agree with those who have pointed
him to mlock and mlockall instead.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
