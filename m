Message-ID: <3D711012.7BFA8119@zip.com.au>
Date: Sat, 31 Aug 2002 11:50:58 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: 2.5.32-mm4
References: <3D710A93.729F3026@zip.com.au>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> 
> ...
> rmap-speedup.patch
>   rmap pte_chain space and CPU reductions
> 

hm.  This accidentally turns on DEBUG_RMAP.  Anyone who is doing
performance testing should turn it off again, in mm/rmap.c
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
