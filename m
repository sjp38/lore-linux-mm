Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Reply-To: benh@kernel.crashing.org
In-Reply-To: <20080507224406.GI8276@duo.random>
References: <6b384bb988786aa78ef0.1210170958@duo.random>
	 <alpine.LFD.1.10.0805071349200.3024@woody.linux-foundation.org>
	 <20080507212650.GA8276@duo.random>
	 <alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org>
	 <20080507222205.GC8276@duo.random>
	 <20080507153103.237ea5b6.akpm@linux-foundation.org>
	 <20080507224406.GI8276@duo.random>
Content-Type: text/plain
Date: Thu, 08 May 2008 09:28:38 +1000
Message-Id: <1210202918.1421.20.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, clameter@sgi.com, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, 2008-05-08 at 00:44 +0200, Andrea Arcangeli wrote:
> 
> Please note, we can't allow a thread to be in the middle of
> zap_page_range while mmu_notifier_register runs.

You said yourself that mmu_notifier_register can be as slow as you
want ... what about you use stop_machine for it ? I'm not even joking
here :-)

> vmtruncate takes 1 single lock, the i_mmap_lock of the inode. Not more
> than one lock and we've to still take the global-system-wide lock
> _before_ this single i_mmap_lock and no other lock at all.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
