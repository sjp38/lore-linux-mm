Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id CB55C6B017B
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 10:25:49 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <20452.32826.165122.958868@quad.stoffel.home>
Date: Fri, 22 Jun 2012 10:24:58 -0400
From: "John Stoffel" <john@stoffel.org>
Subject: Re: [PATCH -mm v2 00/11] mm: scalable and unified arch_get_unmapped_area
In-Reply-To: <1340315835-28571-1-git-send-email-riel@surriel.com>
References: <1340315835-28571-1-git-send-email-riel@surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org

>>>>> "Rik" == Rik van Riel <riel@surriel.com> writes:

Rik> A long time ago, we decided to limit the number of VMAs per
Rik> process to 64k. As it turns out, there actually are programs
Rik> using tens of thousands of VMAs.


Rik> Performance

Rik> Testing performance with a benchmark that allocates tens
Rik> of thousands of VMAs, unmaps them and mmaps them some more
Rik> in a loop, shows promising results.

How are the numbers for applications which only map a few VMAs?  Is
there any impact there?

John

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
