From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14328.51304.207897.182095@dukat.scot.redhat.com>
Date: Mon, 4 Oct 1999 16:31:52 +0100 (BST)
Subject: Re: MMIO regions
In-Reply-To: <Pine.LNX.4.10.9910041028350.7066-100000@imperial.edgeglobal.com>
References: <Pine.LNX.4.10.9910041028350.7066-100000@imperial.edgeglobal.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 4 Oct 1999 10:38:13 -0400 (EDT), James Simmons
<jsimmons@edgeglobal.com> said:

>    I noticed something for SMP machines with all the dicussion about
> concurrent access to memory regions. What happens when you have two
> processes that have both mmapped the same MMIO region for some card.

The kernel doesn't impose any limits against this.  If you want to make
this impossible, then you need to add locking to the driver itself to
prevent multiple processes from conflicting.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
