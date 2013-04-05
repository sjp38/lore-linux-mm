Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 684106B011E
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 16:41:51 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id bv4so388405qab.1
        for <linux-mm@kvack.org>; Fri, 05 Apr 2013 13:41:50 -0700 (PDT)
Message-ID: <515F370C.1030500@gmail.com>
Date: Fri, 05 Apr 2013 16:41:48 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/10] migrate: make core migration code aware of hugepage
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1363983835-20184-3-git-send-email-n-horiguchi@ah.jp.nec.com> <20130325105701.GS2154@dhcp22.suse.cz> <1364272415-zvaphow7-mutt-n-horiguchi@ah.jp.nec.com> <20130326084952.GK2295@dhcp22.suse.cz>
In-Reply-To: <20130326084952.GK2295@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, kosaki.motohiro@gmail.com

>>> There doesn't seem to be any caller for this function. Please move it to
>>> the patch which uses it.
>>
>> I would do like that if there's only one user of this function, but I thought
>> that it's better to separate this part as changes of common code
>> because this function is commonly used by multiple users which are added by
>> multiple patches later in this series.
> 
> Sure there is no hard rule for this. I just find it much easier to
> review if there is a caller of introduced functionality. In this
> particular case I found out only later that many migrate_pages callers
> were changed to use mograte_movable_pages and made the
> putback_movable_pages cleanup inconsistent between the two.
> 
> It would help to mention what is the planned future usage of the
> introduced function if you prefer to introduce it without users.

I strong agree with Michal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
