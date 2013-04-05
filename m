Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id B0D7E6B0124
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 17:13:17 -0400 (EDT)
Received: by mail-qe0-f50.google.com with SMTP id k5so2262346qej.23
        for <linux-mm@kvack.org>; Fri, 05 Apr 2013 14:13:16 -0700 (PDT)
Message-ID: <515F3E6C.8050009@gmail.com>
Date: Fri, 05 Apr 2013 17:13:16 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04/10] migrate: clean up migrate_huge_page()
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1363983835-20184-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1363983835-20184-5-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, kosaki.motohiro@gmail.com

(3/22/13 4:23 PM), Naoya Horiguchi wrote:
> Due to the previous patch, soft_offline_huge_page() switches to use
> migrate_pages(), and migrate_huge_page() is not used any more.
> So let's remove it.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
