Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 6226A6B00A3
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 12:20:16 -0500 (EST)
Message-ID: <4F145BF3.8030802@ah.jp.nec.com>
Date: Mon, 16 Jan 2012 12:18:43 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] pagemap: avoid splitting thp when reading /proc/pid/pagemap
References: <1326396898-5579-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1326396898-5579-2-git-send-email-n-horiguchi@ah.jp.nec.com> <20120114170026.GF3236@redhat.com> <20120115120605.GI3236@redhat.com>
In-Reply-To: <20120115120605.GI3236@redhat.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Sun, Jan 15, 2012 at 01:06:05PM +0100, Andrea Arcangeli wrote:
> On Sat, Jan 14, 2012 at 06:00:26PM +0100, Andrea Arcangeli wrote:
> > Why don't you pass the pmd and then do "if (pmd_present(pmd))
> > page_to_pfn(pmd_page(pmd)) ? What's the argument for the cast. I'm
> 
> Of course I meant pmd_pfn above... in short as a replacement of the
> pte_pfn in your patch.
> 
> About the _stable function, I was now thinking maybe _lock suffix is
> more appropriate than _stable, because that function effectively has
> the objective of taking the page_table_lock in the most efficient way,
> and not much else other than taking the lock. Adding a comment that
> it's only safe to call with the mmap_sem held in the inline version in
> the .h file (the one that then would call the __ version in the .c
> file).

OK, I will use _lock suffix and add the comment in the next post.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
