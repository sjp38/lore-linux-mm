Date: Thu, 26 Jun 2008 02:53:15 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 0/5] [RFC] Conversion of reverse map locks to semaphores
Message-ID: <20080626005315.GB6938@duo.random>
References: <20080626003632.049547282@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080626003632.049547282@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, apw@shadowen.org, Hugh Dickins <hugh@veritas.com>, holt@sgi.com, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

Ah great, so you're maintaining those! Just a moment before seeing
this I post, I uploaded them too at this URL:

     http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.26-rc7/mmu-notifier-v18/

Since you're taking care of this yourself should I feel free to remove
those from my patchset right?

With a VM hat I don't think those lock changes should be
unconditional... especially for the anon-vma case where the common case
are small critical section. But then with a KVM hat those won't make
the slightest difference to my current interesting workload, so it's
truly not my concern if those goes in as-is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
