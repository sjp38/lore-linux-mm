Date: Tue, 7 May 2002 15:41:35 +0530
From: Suparna Bhattacharya <suparna@in.ibm.com>
Subject: Re: [PATCH]Fix: Init page count for all pages during higher order allocs
Message-ID: <20020507154135.A1722@in.ibm.com>
Reply-To: suparna@in.ibm.com
References: <20020503175438.A1816@in.ibm.com> <Pine.LNX.4.21.0205031438310.1408-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0205031438310.1408-100000@localhost.localdomain>; from hugh@veritas.com on Fri, May 03, 2002 at 02:46:34PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@zip.com.au>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, marcelo@conectiva.com.br, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 03, 2002 at 02:46:34PM +0100, Hugh Dickins wrote:
> On Fri, 3 May 2002, Suparna Bhattacharya wrote:
> > 
> > For example we have an option that tries to exclude non-kernel
> > pages from the dump based on a simple heuristic of checking the
> > PG_lru flag (actually exclude LRU pages and unreferenced pages). 
> 
> I hadn't thought of using PG_lru (last thought about it before
> anonymous pages were put on the LRU in 2.4.14): good idea,

Owe that one to Andrew Morton mostly for suggesting a PG_lru 
check in the context of a way to identify Anon pages.

Regards
Suparna
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
