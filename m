Date: Mon, 28 Jan 2008 11:04:43 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 0/4] [RFC] MMU Notifiers V1
In-Reply-To: <20080128172521.GC7233@v2.random>
Message-ID: <Pine.LNX.4.64.0801281103030.14003@schroedinger.engr.sgi.com>
References: <20080125055606.102986685@sgi.com> <20080125114229.GA7454@v2.random>
 <479DFE7F.9030305@qumranet.com> <20080128172521.GC7233@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Izik Eidus <izike@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jan 2008, Andrea Arcangeli wrote:

> So I'd like to know what can we do to help to merge the 4 patches from
> Christoph in mainline, I'd appreciate comments on them so we can help
> to address any outstanding issue!

There are still some pending issues (RCU troubles). I will post V2 today.
 
> It's very important to have this code in 2.6.25 final. KVM requires
> mmu notifiers for reliable swapping, madvise/ballooning, ksm etc... so
> it's high priority to get something merged to provide this
> functionality regardless of its coding style ;).

We also need this urgently.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
