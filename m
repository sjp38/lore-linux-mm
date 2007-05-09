Date: Wed, 9 May 2007 12:26:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memory hotremove patch take 2 [10/10] (retry swap-in
 page)
Message-Id: <20070509122605.e178e516.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070509120947.B91A.Y-GOTO@jp.fujitsu.com>
References: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
	<20070509120947.B91A.Y-GOTO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@osdl.org, clameter@sgi.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Wed, 09 May 2007 12:12:32 +0900
Yasunori Goto <y-goto@jp.fujitsu.com> wrote:

> There is a race condition between swap-in and unmap_and_move().
> When swap-in occur, page_mapped might be not set yet.
> So, unmap_and_move() gives up at once, and tries later.
> 
> 
Note: this will not happen in sys_migratepage(), it holds mm->sem and
gathers migration target page from page table.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
