Date: Wed, 13 Nov 2002 13:22:52 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.47-mm2
Message-ID: <20021113212252.GW22031@holomorphy.com>
References: <3DD21113.B4F3857@digeo.com> <20021113091116.GG23425@holomorphy.com> <3DD287EF.DCBFB5D0@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3DD287EF.DCBFB5D0@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 13, 2002 at 12:45:07AM -0800, Andrew Morton wrote:
>>> page-reservation.patch
>>>   Page reservation API

William Lee Irwin III wrote:
>> Don't drop it yet, I've got a caller of this on the back burner.

On Wed, Nov 13, 2002 at 09:12:15AM -0800, Andrew Morton wrote:
> Well so have I.  Right now, if pte_chain_alloc() fails the
> kernel oopses.

That's the one. I keep choking on mm/slab.c though. =(


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
