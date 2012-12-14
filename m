Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 019036B005A
	for <linux-mm@kvack.org>; Fri, 14 Dec 2012 10:38:08 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm: clean up soft_offline_page()
Date: Fri, 14 Dec 2012 10:37:36 -0500
Message-Id: <1355499456-3311-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <50CA97D0.4020401@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Jiang Liu <jiang.liu@huawei.com>, Borislav Petkov <bp@alien8.de>, Simon Jeons <simon.jeons@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Xishi,

On Fri, Dec 14, 2012 at 11:06:56AM +0800, Xishi Qiu wrote:
> On 2012/12/14 7:01, Naoya Horiguchi wrote:
...
> > +	ret = get_any_page(page, pfn, flags);
> > +	if (ret < 0)
> > +		return ret;
> > +	if (ret) { /* for in-use pages */
> > +		if (PageHuge(page))
> > +			soft_offline_huge_page(page, flags);
> 
> ret = soft_offline_huge_page(page, flags);
> 
> > +		else
> > +			__soft_offline_page(page, flags);
> 
> ret = __soft_offline_page(page, flags); right?

Ah, you're right, Thanks!

Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
