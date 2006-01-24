Date: Mon, 23 Jan 2006 18:51:21 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH/RFC] Shared page tables
Message-ID: <08A96D993E5CB2984F6F448A@[10.1.1.4]>
In-Reply-To: <200601240139.46751.ak@suse.de>
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]>
 <200601231758.08397.raybry@mpdtxmail.amd.com>
 <200601231816.38942.raybry@mpdtxmail.amd.com>
 <200601240139.46751.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>, Ray Bryant <raybry@mpdtxmail.amd.com>
Cc: Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--On Tuesday, January 24, 2006 01:39:46 +0100 Andi Kleen <ak@suse.de> wrote:

>> Oh, obviously that is not right as you have to share full pte pages.
>> So on  x86_64 I'm guessing one needs 2MB alignment in order to get the
>> sharing to kick in, since a pte page maps 512 pages of 4 KB each.
> 
> The new randomized mmaps will likely actively sabotate such alignment. I
> just added them for x86-64.

Given that my current patch requires memory regions to be mapped at the
same address, randomized mmaps won't really make it any worse.  It's
unlikely mmap done independently in separate processes will land on the
same address.  Most of the large OLTP applications use fixed address
mapping for their large shared regions.

This also should mean large text regions will be shared, which should be a
win for big programs.

I've been kicking around some ideas on how to allow sharing of mappings at
different addresses as long as the alignment is the same, but don't have
the details worked out.  I figure it's more important to get the basic part
working first :)

Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
