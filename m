Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] Optimize out pte_chain take three
Date: Sat, 13 Jul 2002 16:10:02 +0200
References: <Pine.LNX.4.44L.0207102145000.14432-100000@imladris.surriel.com>
In-Reply-To: <Pine.LNX.4.44L.0207102145000.14432-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17TNb5-0003JC-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Andrew Morton <akpm@zip.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thursday 11 July 2002 02:47, Rik van Riel wrote:
> On Wed, 10 Jul 2002, Andrew Morton wrote:
> 
> > A lot of it should be fairly simple.  We have tons of pagecache-intensive
> > workloads.  But we have gaps when it comes to the VM.  In the area of
> > page replacement.
> 
> Umm, page replacement is about identifying the working set
> and paging out those pages which are not in the working set.
> 
> None of the benchmark examples you give have anything like
> a working set.

What we need is a short C program that similates a working set.  I
believe we discussed such a thing briefly at Ottawa.

This is just random-fu.  The main challenge is making it short and
sweet.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
