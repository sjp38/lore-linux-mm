Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id EC2496B0031
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 18:01:53 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rr4so2721994pbb.6
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 15:01:53 -0800 (PST)
Received: from psmtp.com ([74.125.245.147])
        by mx.google.com with SMTP id bq8si3212777pab.87.2013.11.15.15.01.51
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 15:01:52 -0800 (PST)
Received: by mail-yh0-f53.google.com with SMTP id b20so344964yha.12
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 15:01:50 -0800 (PST)
Date: Fri, 15 Nov 2013 15:01:46 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/migrate.c: take returned value ofisolate_huge_page()(Re:
 [PATCH 4/9] migrate: add hugepage migration code tomove_pages())
In-Reply-To: <1384527836-981jfadg-mutt-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.02.1311151501290.13382@chino.kir.corp.google.com>
References: <1376025702-14818-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1376025702-14818-5-git-send-email-n-horiguchi@ah.jp.nec.com> <20130928172602.GA6191@pd.tnic> <1380553263-lqp3ggll-mutt-n-horiguchi@ah.jp.nec.com> <20130930160450.GA20030@pd.tnic>
 <1380557324-v44mpchd-mutt-n-horiguchi@ah.jp.nec.com> <20131112115633.GA16700@pd.tnic> <1384444050-v86q6ypr-mutt-n-horiguchi@ah.jp.nec.com> <alpine.DEB.2.02.1311141509390.30112@chino.kir.corp.google.com> <1384527836-981jfadg-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, 15 Nov 2013, Naoya Horiguchi wrote:

> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Fri, 15 Nov 2013 09:00:15 -0500
> Subject: [PATCH] mm/migrate.c: take returned value of isolate_huge_page()
> 
> Introduces a cosmetic substitution of the returned value of isolate_huge_page()
> to suppress a build warning when !CONFIG_HUGETLBFS. No behavioral change.
> 
> Reported-by: Borislav Petkov <bp@alien8.de>
> Tested-by: Borislav Petkov <bp@alien8.de>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
