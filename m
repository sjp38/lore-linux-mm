Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 46CE86B0002
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 14:37:40 -0400 (EDT)
Message-ID: <516D9A74.8030109@linux.intel.com>
Date: Tue, 16 Apr 2013 11:37:40 -0700
From: Dave Hansen <dave.hansen@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] futex: bugfix for futex-key conflict when futex use hugepage
References: <OF000BBE68.EBB4E92E-ON48257B4F.0010C2E7-48257B4F.0013FB89@zte.com.cn>
In-Reply-To: <OF000BBE68.EBB4E92E-ON48257B4F.0010C2E7-48257B4F.0013FB89@zte.com.cn>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhang.yi20@zte.com.cn
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Darren Hart <dvhart@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>

Instead of bothering to store the index, why not just calculate it, like:

On 04/15/2013 08:37 PM, zhang.yi20@zte.com.cn wrote:
> +static inline int get_page_compound_index(struct page *page)
> +{
> +       if (PageHead(page))
> +               return 0;
> +       return compound_head(page) - page;
> +}

BTW, you've really got to get your mail client fixed.  Your patch is
still line-wrapped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
