Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] Optimize out pte_chain take three
Date: Sat, 13 Jul 2002 16:52:01 +0200
References: <20810000.1026311617@baldur.austin.ibm.com> <20020711015102.GV25360@holomorphy.com> <3D2DE264.17706BB4@zip.com.au>
In-Reply-To: <3D2DE264.17706BB4@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17TOFe-0003JT-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, William Lee Irwin III <wli@holomorphy.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thursday 11 July 2002 21:54, Andrew Morton wrote:
> The problem is the access pattern.  It shouldn't be random-uniform.
> But what should it be?  random-gaussian?

It should be kinda-fractal.  That is, random distributions of random
distributions.  In concrete terms, this could mean running one random
load for a while then randomly switching to a different random load.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
