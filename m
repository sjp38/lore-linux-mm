Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 132F26B0011
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 01:02:58 -0500 (EST)
Received: by mail-ee0-f50.google.com with SMTP id e51so1152942eek.9
        for <linux-mm@kvack.org>; Wed, 27 Feb 2013 22:02:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1361475708-25991-10-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1361475708-25991-10-git-send-email-n-horiguchi@ah.jp.nec.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 28 Feb 2013 01:02:37 -0500
Message-ID: <CAHGf_=qq=+F4HMEE6P_g_ou7dQ6odu=DaefDsURjq5Yhxz99-Q@mail.gmail.com>
Subject: Re: [PATCH 9/9] remove /proc/sys/vm/hugepages_treat_as_movable
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

> -        {
> -               .procname       = "hugepages_treat_as_movable",
> -               .data           = &hugepages_treat_as_movable,
> -               .maxlen         = sizeof(int),
> -               .mode           = 0644,
> -               .proc_handler   = hugetlb_treat_movable_handler,
> -       },

Sorry, no.

This is too aggressive remove. Imagine, a lot of shell script don't
have any error check.
I suggest to keep this file but change to nop (to output warning is better).
About 1-2 years after, we can remove this file safely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
