Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] Optimize out pte_chain take three
Date: Sat, 13 Jul 2002 15:42:48 +0200
References: <Pine.LNX.4.44L.0207101737400.14432-100000@imladris.surriel.com>
In-Reply-To: <Pine.LNX.4.44L.0207101737400.14432-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17TNAe-0003Ij-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Andrew Morton <akpm@zip.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 10 July 2002 22:38, Rik van Riel wrote:
> On Wed, 10 Jul 2002, Andrew Morton wrote:
> 
> > How do the BSD and proprietary kernel developers evaluate
> > their VMs?
> 
> Proper statistics inside their VM, combined with some
> basic workload testing.
> 
> Most importantly, they don't seem to hang themselves
> on benchmarks. Benchmarks can be won by finetuning
> whatever you have but measuring a new basis (still
> without tuning) by benchmarking it just doesn't work.

As I recall, Matt likes to talk about load counts on heavily loaded
mail servers.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
