Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: how not to write a search algorithm
Date: Mon, 5 Aug 2002 01:02:05 +0200
References: <3D4CE74A.A827C9BC@zip.com.au> <E17bU7n-0000Yb-00@starship> <3D4DB2AF.48B07053@zip.com.au>
In-Reply-To: <3D4DB2AF.48B07053@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17bUNx-0000aJ-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 05 August 2002 01:03, Andrew Morton wrote:
> The list walk is killing us now.   I think we need:
> 
> struct pte_chain {
> 	struct pte_chain *next;
> 	pte_t *ptes[L1_CACHE_BYTES/4 - 4];
> };

Which list walk, the remove or the page_referenced?

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
