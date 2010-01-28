Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6AC3C6B0092
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 12:07:21 -0500 (EST)
Date: Thu, 28 Jan 2010 18:05:08 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 31] Transparent Hugepage support #8
Message-ID: <20100128170508.GH1217@random.random>
References: <patchbomb.1264689194@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <patchbomb.1264689194@v2.random>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <hch@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 28, 2010 at 03:33:14PM +0100, Andrea Arcangeli wrote:
> I suggest to try it (especially if you use i915_gem, as I need to know if
> anybody else can reproduce the khugepaged warning with pte_special set) and

If you test the #8 submit, please add i915.modeline=1 or better set
CONFIG_DRM_I915_KMS=y or I was just told that the problem goes away.

quilt:

	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.33-rc5/transparent_hugepage-8/

I also provide a monolith that will make life easier to apply it on
top of upstream, if somebody wants to help testing this.

	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.33-rc5/transparent_hugepage-8.bz2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
