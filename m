From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906141734.KAA27832@google.engr.sgi.com>
Subject: Re: Some issues + [PATCH] kanoj-mm8-2.2.9 Show statistics on alloc/free requests for each pagefree list
Date: Mon, 14 Jun 1999 10:34:49 -0700 (PDT)
In-Reply-To: <19990612122107.A2245@fred.muc.de> from "Andi Kleen" at Jun 12, 99 12:21:07 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

> 
> There is a important case ATM that needs bigger blocks allocated from 
> bottom half context: NFS packet defragmenting. For a 8K wsize it needs
> even 16K blocks (8K payload + the IP/UDP header forces it to the next
> buddy size). I guess your statistics would look very different on a nfsroot
> machine. Until lazy defragmenting is supported for UDP it is probably 
> better not to change it.
> 

This is the experiment I tried: using automount, I cd'ed into a nfs
mounted directiory, and copied kernel sources over to the local (client)
machine. The statistics before and after the copy on the client:

Before:

10*4kB (20993, 34343) 3*8kB (398, 319) 0*16kB (2, 0) 0*32kB (2, 0) 0*64kB (0, 0) 1*128kB (0, 0) 0*256kB (1, 0) 0*512kB (0, 0) 1*1024kB (0, 0) 25*2048kB (0, 0) = 52416kB)


After:

192*4kB (88737, 89889) 27*8kB (744, 405) 3*16kB (2, 0) 0*32kB (2, 0) 0*64kB (0,
0) 0*128kB (0, 0) 0*256kB (1, 0) 1*512kB (0, 0) 0*1024kB (0, 0) 0*2048kB (0, 0)
= 1544kB)

I am not sure about the wsize though ... maybe someone with access to
a nfsroot machine can try a quick experiment and publish the results?

Btw, if the nfs defrag code is coming from bottom half, it probably has
logic to handle allocation failures? Andi, could you please send me a
pointer to the relevant code? 

Thanks.

Kanoj

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
