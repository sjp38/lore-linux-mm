Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 7FAF66B0129
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 18:18:04 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id bs12so414124qab.7
        for <linux-mm@kvack.org>; Fri, 05 Apr 2013 15:18:03 -0700 (PDT)
Message-ID: <515F4D9A.3060009@gmail.com>
Date: Fri, 05 Apr 2013 18:18:02 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 07/10] mbind: add hugepage migration code to mbind()
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1363983835-20184-8-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1363983835-20184-8-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, kosaki.motohiro@gmail.com

> @@ -1277,14 +1279,10 @@ static long do_mbind(unsigned long start, unsigned long len,
>  	if (!err) {
>  		int nr_failed = 0;
>  
> -		if (!list_empty(&pagelist)) {
> -			WARN_ON_ONCE(flags & MPOL_MF_LAZY);
> -			nr_failed = migrate_pages(&pagelist, new_vma_page,
> +		WARN_ON_ONCE(flags & MPOL_MF_LAZY);

???
MPOL_MF_LAZY always output warn? It seems really insane.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
