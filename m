Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D984A6B004D
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 11:32:20 -0400 (EDT)
Message-ID: <4A79A743.6020209@redhat.com>
Date: Wed, 05 Aug 2009 18:37:39 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
References: <20090805024058.GA8886@localhost> <4A793B92.9040204@redhat.com> <4A794008.6030204@redhat.com> <4A79984C.2010508@redhat.com>
In-Reply-To: <4A79984C.2010508@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KVM list <kvm@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 08/05/2009 05:33 PM, Rik van Riel wrote:
> Avi Kivity wrote:
>
>> The attached patch implements this.
>
> The attached page requires each page to go around twice
> before it is evicted, but they will still get evicted in
> the order in which they were made present.
>
> FIFO page replacement was shown to be a bad idea in the
> 1960's and it is still a terrible idea today.
>

Which is why we have accessed bits in page tables... but emulating the 
accessed bit via RWX (note no present bit in EPT) is better than 
ignoring it.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
