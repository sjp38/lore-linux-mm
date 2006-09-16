From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Date: Sat, 16 Sep 2006 06:42:29 +0200
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com> <20060915012810.81d9b0e3.akpm@osdl.org> <20060915203816.fd260a0b.pj@sgi.com>
In-Reply-To: <20060915203816.fd260a0b.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200609160642.30153.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Saturday 16 September 2006 05:38, Paul Jackson wrote:

> 3)  The custom zonelist option - which was part of my original cpuset
>     proposal, and which Andi K and I have gone back and forth on, with
>     each of us liking and disliking it, at different times.  See further
>     my latest writeup on this option:

I'm currently back in the camp of liking it. It should be the fastest
in the fast path as far as I know and the slow path code 
is probably not as bad as I originally thought (didn't you already
have it coded up at some point?)

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
