Date: Wed, 23 Jan 2008 09:48:23 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [kvm-devel] [PATCH] export notifier #1
Message-ID: <20080123154823.GG3058@sgi.com>
References: <20080121125204.GJ6970@v2.random> <4795F9D2.1050503@qumranet.com> <20080122144332.GE7331@v2.random> <20080122200858.GB15848@v2.random> <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com> <4797384B.7080200@redhat.com> <20080123131939.GJ26420@sgi.com> <47974B54.30407@redhat.com> <20080123141814.GE3058@sgi.com> <479750CA.4070101@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <479750CA.4070101@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerd Hoffmann <kraxel@redhat.com>
Cc: Robin Holt <holt@sgi.com>, Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 23, 2008 at 03:35:54PM +0100, Gerd Hoffmann wrote:
> Robin Holt wrote:
> > We have a seg structure which is similar to some structure you probably
> > have which describes the grant.  One of the things hanging off that
> > seg structure is essentially a page table containing PFNs with their
> > respective flags (XPMEM specific and not the same as the pfn flags in
> > the processor page tables).
> 
> i.e. page tables used by hardware != cpu, right?

Actually page tables used exclusively by software during the cross
partition coordination.  Those entries are inserted on the remote side
by normal faults with VM_PFNMAP vmas created by the importing side.

> In the Xen guest case the normal processor page tables are modified, but
> in a special way to make the Xen hypervisor also release the grant.

In our guest case, we can not access the kernel struct page area on the
remote host.  We therefore handle all the ref/deref of the page as part
of messaging the PFN across the partition boundaries.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
