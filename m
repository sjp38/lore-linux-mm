Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 886B56B0002
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 13:17:05 -0500 (EST)
Date: Thu, 28 Feb 2013 13:16:52 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1362075412-779292mh-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <CAHGf_=qq=+F4HMEE6P_g_ou7dQ6odu=DaefDsURjq5Yhxz99-Q@mail.gmail.com>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1361475708-25991-10-git-send-email-n-horiguchi@ah.jp.nec.com>
 <CAHGf_=qq=+F4HMEE6P_g_ou7dQ6odu=DaefDsURjq5Yhxz99-Q@mail.gmail.com>
Subject: Re: [PATCH 9/9] remove /proc/sys/vm/hugepages_treat_as_movable
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Feb 28, 2013 at 01:02:37AM -0500, KOSAKI Motohiro wrote:
> > -        {
> > -               .procname       = "hugepages_treat_as_movable",
> > -               .data           = &hugepages_treat_as_movable,
> > -               .maxlen         = sizeof(int),
> > -               .mode           = 0644,
> > -               .proc_handler   = hugetlb_treat_movable_handler,
> > -       },
> 
> Sorry, no.
> 
> This is too aggressive remove. Imagine, a lot of shell script don't
> have any error check.

Sure, it could break usespace applications.

> I suggest to keep this file but change to nop (to output warning is better).
> About 1-2 years after, we can remove this file safely.

OK, so I'll leave it for a while with the comment saying that this
parameter is obsolete and shouldn't be used.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
