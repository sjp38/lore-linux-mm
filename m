Message-ID: <48D17E75.80807@redhat.com>
Date: Wed, 17 Sep 2008 15:02:29 -0700
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Populating multiple ptes at fault time
References: <48D142B2.3040607@goop.org>
In-Reply-To: <48D142B2.3040607@goop.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Jeremy Fitzhardinge wrote:
> Minor faults are easier; if the page already exists in memory, we should
> just create mappings to it.  If neighbouring pages are also already
> present, then we can can cheaply create mappings for them too.
>
>   

One problem is the accessed bit.  If it's unset, the shadow code cannot 
make the pte present (since it has to trap in order to set the accessed 
bit); if it's set, we're lying to the vm.

This doesn't affect Xen, only kvm.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
