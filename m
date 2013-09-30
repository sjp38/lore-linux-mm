Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 14F056B0036
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 12:05:02 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so6092401pab.17
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 09:05:01 -0700 (PDT)
Date: Mon, 30 Sep 2013 18:04:50 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 4/9] migrate: add hugepage migration code to move_pages()
Message-ID: <20130930160450.GA20030@pd.tnic>
References: <1376025702-14818-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1376025702-14818-5-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130928172602.GA6191@pd.tnic>
 <1380553263-lqp3ggll-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1380553263-lqp3ggll-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Mon, Sep 30, 2013 at 11:01:03AM -0400, Naoya Horiguchi wrote:
> Thanks for reporting. The patch should fix this.
> 
> Naoya Horiguchi
> ---
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Mon, 30 Sep 2013 10:22:26 -0400
> Subject: [PATCH] mm/migrate.c: take returned value of isolate_huge_page()
> 
> Introduces a cosmetic substitution of the returned value of isolate_huge_page()
> to suppress a build warning when !CONFIG_HUGETLBFS. No behavioral change.
> 
> Reported-by: Borislav Petkov <bp@alien8.de>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks for this. Unfortunately, I cannot trigger it anymore. :\ Maybe it
is because I pulled latest git and this was triggering only on a older
repo state, hmmm.

The patch looks obviously correct though so you could send it up or hold
on to it until someone else reports it.

Anyway, sorry for the trouble.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
