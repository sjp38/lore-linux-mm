Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] Optimize out pte_chain take three
Date: Sat, 13 Jul 2002 15:22:28 +0200
References: <20810000.1026311617@baldur.austin.ibm.com> <20020710173254.GS25360@holomorphy.com> <3D2C9288.51BBE4EB@zip.com.au>
In-Reply-To: <3D2C9288.51BBE4EB@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17TMqy-0003IY-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, William Lee Irwin III <wli@holomorphy.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 10 July 2002 22:01, Andrew Morton wrote:
> Devil's advocate here.  Sorry.
> > (4)  enables defragmentation of physical memory
> 
> Vapourware

Prediction: it will continue to be vaporware until after rmap is merged.
Meanwhile, there's no denying that fragmentation is a burning issue.

> > (5)  enables cooperative offlining of memory for friendly guest instance
> >         behavior in UML and/or LPAR settings
> 
> Vapourware

See "enables" above.  Though I agree we want the thing at parity or
better on its own merits, I don't see the point of throwing tomatoes at
the "enables" points.  Recommendation: separate the list into "improves"
and "enables".

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
