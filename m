Subject: Re: [PATCH] mm: tracking dirty pages -v6
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1149770654.4408.71.camel@lappy>
References: <20060525135534.20941.91650.sendpatchset@lappy>
	 <Pine.LNX.4.64.0606062056540.1507@blonde.wat.veritas.com>
	 <1149770654.4408.71.camel@lappy>
Content-Type: text/plain
Date: Thu, 08 Jun 2006 15:02:02 +0200
Message-Id: <1149771723.20886.10.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

If this one still has some problems there is on more thing we could try
before going back to the old way of doing things.

I found this 'gem' in the drm code:

        vma->vm_page_prot =
            __pgprot(pte_val
                     (pte_wrprotect
                      (__pte(pgprot_val(vma->vm_page_prot)))));

which does exactly what is needed.

OTOH, my alternate version of the mprotect fix leaves dirty pages
writable, which saves a few faults.

Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
