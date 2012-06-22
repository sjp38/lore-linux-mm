Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id CC6C66B0269
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 17:47:16 -0400 (EDT)
Date: Fri, 22 Jun 2012 14:47:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm v2 00/11] mm: scalable and unified
 arch_get_unmapped_area
Message-Id: <20120622144714.440f8529.akpm@linux-foundation.org>
In-Reply-To: <20452.32826.165122.958868@quad.stoffel.home>
References: <1340315835-28571-1-git-send-email-riel@surriel.com>
	<20452.32826.165122.958868@quad.stoffel.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stoffel <john@stoffel.org>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org

On Fri, 22 Jun 2012 10:24:58 -0400
"John Stoffel" <john@stoffel.org> wrote:

> >>>>> "Rik" == Rik van Riel <riel@surriel.com> writes:
> 
> Rik> A long time ago, we decided to limit the number of VMAs per
> Rik> process to 64k. As it turns out, there actually are programs
> Rik> using tens of thousands of VMAs.
> 
> 
> Rik> Performance
> 
> Rik> Testing performance with a benchmark that allocates tens
> Rik> of thousands of VMAs, unmaps them and mmaps them some more
> Rik> in a loop, shows promising results.
> 
> How are the numbers for applications which only map a few VMAs?  Is
> there any impact there?
> 

Johannes did a test for that: https://lkml.org/lkml/2012/6/22/219

Some regression with such a workload is unavoidable, I expect.  We have
to work out whether the pros outweigh the cons.  This involves handwaving.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
