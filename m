Date: Fri, 3 May 2002 14:46:34 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH]Fix: Init page count for all pages during higher order
 allocs
In-Reply-To: <20020503175438.A1816@in.ibm.com>
Message-ID: <Pine.LNX.4.21.0205031438310.1408-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Suparna Bhattacharya <suparna@in.ibm.com>
Cc: Andrew Morton <akpm@zip.com.au>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, marcelo@conectiva.com.br, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 3 May 2002, Suparna Bhattacharya wrote:
> 
> For example we have an option that tries to exclude non-kernel
> pages from the dump based on a simple heuristic of checking the
> PG_lru flag (actually exclude LRU pages and unreferenced pages). 

I hadn't thought of using PG_lru (last thought about it before
anonymous pages were put on the LRU in 2.4.14): good idea,
seems much more appealing than my extra flag for GFP_HIGHUSER.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
