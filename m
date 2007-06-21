Date: Thu, 21 Jun 2007 05:28:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 7/7] Compact memory directly by a process when a
 high-order allocation fails
Message-Id: <20070621052813.ac93e12e.akpm@linux-foundation.org>
In-Reply-To: <20070618093042.7790.30669.sendpatchset@skynet.skynet.ie>
References: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>
	<20070618093042.7790.30669.sendpatchset@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

> On Mon, 18 Jun 2007 10:30:42 +0100 (IST) Mel Gorman <mel@csn.ul.ie> wrote:
> +
> +			/*
> +			 * It's a race if compaction frees a suitable page but
> +			 * someone else allocates it
> +			 */
> +			count_vm_event(COMPACTRACE);
> +		}

Could perhaps cause arbitrarily long starvation.  A fix would be to free
the synchronously-compacted higher-order page into somewhere which is
private to this task (a new field in task_struct would be one such place).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
