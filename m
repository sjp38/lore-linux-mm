Date: Fri, 20 Oct 2006 11:08:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] virtual memmap for sparsemem [2/2] for ia64.
Message-Id: <20061020110829.f492d370.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0610191842300.11820@schroedinger.engr.sgi.com>
References: <20061019172328.4bcb1551.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0610190940140.8072@schroedinger.engr.sgi.com>
	<20061020103534.35a92813.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0610191842300.11820@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Oct 2006 18:45:18 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> > Then, considering PAGE_SHIFT=14 case, 
> > 4-level-page-table mapsize:(1 << (4 * PAGE_SHIFT - 9) -> (1 << 47)
> > 3-level-page-table mapsize:(1 << (3 * PAGE_SHIFT - 6) -> (1 << 36)
> 
> You are missing one PAGE_SHIFT (the page that is referred to !)
> 
> 3 level is 47. 4 level is 58. 
> 
(>_<)!!!

Thank you
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
