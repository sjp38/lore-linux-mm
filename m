Date: Wed, 10 Jul 2002 17:38:42 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Optimize out pte_chain take three
In-Reply-To: <3D2C9900.EF65CE2E@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207101737400.14432-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Jul 2002, Andrew Morton wrote:

> How do the BSD and proprietary kernel developers evaluate
> their VMs?

Proper statistics inside their VM, combined with some
basic workload testing.

Most importantly, they don't seem to hang themselves
on benchmarks. Benchmarks can be won by finetuning
whatever you have but measuring a new basis (still
without tuning) by benchmarking it just doesn't work.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
