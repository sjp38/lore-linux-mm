Date: Wed, 26 Mar 2008 12:25:21 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: What if a TLB flush needed to sleep?
In-Reply-To: <1FE6DD409037234FAB833C420AA843ECE9DF60@orsmsx424.amr.corp.intel.com>
Message-ID: <Pine.LNX.4.64.0803261222090.31000@schroedinger.engr.sgi.com>
References: <1FE6DD409037234FAB833C420AA843ECE9DF60@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Mar 2008, Luck, Tony wrote:

> 2) Is it feasible to rearrange the MM code so that we don't
> hold any locks while doing a TLB flush?  Or should I implement
> some sort of spin_only_semaphore?

The EMM notifier V2 patchset contains two patches that 
convert the immap_lock and the anon_vma lock to semaphores. After that
much of the TLB flushing is (tlb_finish_mmu, tlb_gather etc) is running 
without holding any spinlocks. There would need to be additional measures 
for flushing inherent in macros (like ptep_clear_flush). Currently the 
pte functions are called under pte lock.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
