Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id JAA10167
	for <linux-mm@kvack.org>; Wed, 13 Nov 2002 09:12:15 -0800 (PST)
Message-ID: <3DD287EF.DCBFB5D0@digeo.com>
Date: Wed, 13 Nov 2002 09:12:15 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.47-mm2
References: <3DD21113.B4F3857@digeo.com> <20021113091116.GG23425@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> On Wed, Nov 13, 2002 at 12:45:07AM -0800, Andrew Morton wrote:
> > page-reservation.patch
> >   Page reservation API
> 
> Don't drop it yet, I've got a caller of this on the back burner.
> 

Well so have I.  Right now, if pte_chain_alloc() fails the
kernel oopses.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
