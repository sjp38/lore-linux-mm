Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id AE0416B005C
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 23:41:52 -0400 (EDT)
Date: Mon, 26 Aug 2013 23:41:36 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1377574896-5k1diwl4-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <521c1f3f.813d320a.6ba7.5a17SMTPIN_ADDED_BROKEN@mx.google.com>
References: <1377571171-9958-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377571171-9958-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377574096-y8hxgzdw-mutt-n-horiguchi@ah.jp.nec.com>
 <521c1f3f.813d320a.6ba7.5a17SMTPIN_ADDED_BROKEN@mx.google.com>
Subject: Re: [PATCH v2 3/3] mm/hwpoison: fix return value of madvise_hwpoison
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 27, 2013 at 11:38:27AM +0800, Wanpeng Li wrote:
> Hi Naoya,
> On Mon, Aug 26, 2013 at 11:28:16PM -0400, Naoya Horiguchi wrote:
> >On Tue, Aug 27, 2013 at 10:39:31AM +0800, Wanpeng Li wrote:
> >> The return value outside for loop is always zero which means madvise_hwpoison 
> >> return success, however, this is not truth for soft_offline_page w/ failure
> >> return value.
> >
> >I don't understand what you want to do for what reason. Could you clarify
> >those?
> 
> int ret is defined in two place in madvise_hwpoison. One is out of for
> loop and its value is always zero(zero means success for madvise), the 
> other one is in for loop. The soft_offline_page function maybe return 
> -EBUSY and break, however, the ret out of for loop is return which means 
> madvise_hwpoison success. 

Oh, I see. Thanks.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>


> Regards,
> Wanpeng Li 
> 
> >
> >> 
> >> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> >> ---
> >>  mm/madvise.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >> 
> >> diff --git a/mm/madvise.c b/mm/madvise.c
> >> index a20764c..19b71e4 100644
> >> --- a/mm/madvise.c
> >> +++ b/mm/madvise.c
> >> @@ -359,7 +359,7 @@ static int madvise_hwpoison(int bhv, unsigned long start, unsigned long end)
> >>  				page_to_pfn(p), start);
> >>  			ret = soft_offline_page(p, MF_COUNT_INCREASED);
> >>  			if (ret)
> >> -				break;
> >> +				return ret;
> >>  			continue;
> >>  		}
> >>  		pr_info("Injecting memory failure for page %#lx at %#lx\n",
> >
> >This seems to introduce no behavioral change.
> >
> >Thanks,
> >Naoya Horiguchi
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
