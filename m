Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] Optimize out pte_chain take three
Date: Sat, 13 Jul 2002 16:08:09 +0200
References: <20810000.1026311617@baldur.austin.ibm.com> <20020710222210.GU25360@holomorphy.com> <3D2CD3D3.B43E0E1F@zip.com.au>
In-Reply-To: <3D2CD3D3.B43E0E1F@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17TNZB-0003J7-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, William Lee Irwin III <wli@holomorphy.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thursday 11 July 2002 02:39, Andrew Morton wrote:
> example 1:  "run thirty processes which mmap a common 50000 page file and
> touch its pages in a random-but-always-the-same pattern at fifty pages
> per second.  Then run (dbench|tiobench|kernel build|slocate|foo).

Postmark looks like an excellend benchmark to add to the list, in fact
from the description, I'd put it at the front of the list.  It's
apparently much more stable than dbench, a property we desperately
need just now.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
