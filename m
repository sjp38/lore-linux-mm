From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14199.62915.809286.123824@dukat.scot.redhat.com>
Date: Mon, 28 Jun 1999 23:22:59 +0100 (BST)
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
In-Reply-To: <199906282138.OAA36935@google.engr.sgi.com>
References: <Pine.BSO.4.10.9906281715420.24888-100000@funky.monkey.org>
	<199906282138.OAA36935@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Chuck Lever <cel@monkey.org>, andrea@suse.de, torvalds@transmeta.com, sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 28 Jun 1999 14:38:43 -0700 (PDT), kanoj@google.engr.sgi.com
(Kanoj Sarcar) said:

> The page is not really free for reallocation, unless kswapd can
> push out the contents to disk, right? Which means, kswapd should
> have as minimal sleep/memallocation points as possible ...

The kswapd process is marked with the PF_MEMALLOC process flag, so any
recursive memory allocations it attempts get satisfied without IO being
invoked.  kswapd does not sleep during memory allocation.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
