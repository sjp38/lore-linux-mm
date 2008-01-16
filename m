Message-ID: <478E4356.7030303@qumranet.com>
Date: Wed, 16 Jan 2008 19:48:06 +0200
From: Izik Eidus <izike@qumranet.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mmu notifiers #v2
References: <20080113162418.GE8736@v2.random> <20080116124256.44033d48@bree.surriel.com>
In-Reply-To: <20080116124256.44033d48@bree.surriel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm-devel@lists.sourceforge.net, Avi Kivity <avi@qumranet.com>, clameter@sgi.com, daniel.blueman@quadrics.com, holt@sgi.com, steiner@sgi.com, Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> On Sun, 13 Jan 2008 17:24:18 +0100
> Andrea Arcangeli <andrea@qumranet.com> wrote:
>
>   
>> In my basic initial patch I only track the tlb flushes which should be
>> the minimum required to have a nice linux-VM controlled swapping
>> behavior of the KVM gphysical memory. 
>>     
>
> I have a vaguely related question on KVM swapping.
>
> Do page accesses inside KVM guests get propagated to the host
> OS, so Linux can choose a reasonable page for eviction, or is
> the pageout of KVM guest pages essentially random?
>
>   
right now when kvm remove pte from the shadow cache, it mark as access 
the page that this pte pointed to.
it was a good solution untill the mmut notifiers beacuse the pages were 
pinned and couldnt be swapped to disk
so now it will have to do something more sophisticated or at least mark 
as access every page pointed by pte
that get insrted to the shadow cache....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
