Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 8B63B6B0032
	for <linux-mm@kvack.org>; Thu, 12 Sep 2013 11:21:15 -0400 (EDT)
Date: Thu, 12 Sep 2013 17:21:13 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] mm/hwpoison: move set_migratetype_isolate() outside
 get_any_page()
Message-ID: <20130912152113.GH18242@two.firstfloor.org>
References: <1378998704-d94o0a30-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1378998704-d94o0a30-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 12, 2013 at 11:11:44AM -0400, Naoya Horiguchi wrote:
> Chen Gong pointed out that set/unset_migratetype_isolate() was done in
> different functions in mm/memory-failure.c, which makes the code less
> readable/maintenable. So this patch makes it done in soft_offline_page().
> 
> With this patch, we get to hold lock_memory_hotplug() longer but it's not
> a problem because races between memory hotplug and soft offline are very rare.
> 
> This patch is against next-20130910.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Reviewed-by: Chen, Gong <gong.chen@linux.intel.com>

Acked-by: Andi Kleen <ak@linux.intel.com>

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
