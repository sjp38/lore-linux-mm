Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3D5106B003D
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 06:18:05 -0500 (EST)
Received: by ewy24 with SMTP id 24so25630276ewy.6
        for <linux-mm@kvack.org>; Fri, 08 Jan 2010 03:18:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100108130742.C138.A69D9226@jp.fujitsu.com>
References: <20100108105841.b9a030c4.minchan.kim@barrios-desktop>
	 <20100108115531.C132.A69D9226@jp.fujitsu.com>
	 <20100108130742.C138.A69D9226@jp.fujitsu.com>
Date: Fri, 8 Jan 2010 11:18:01 +0000
Message-ID: <87a5b0801001080318o29a5f560u1cce8a45849dee6d@mail.gmail.com>
Subject: Re: Commit f50de2d38 seems to be breaking my oom killer
From: Will Newton <will.newton@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 8, 2010 at 4:08 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> > And while I review all_zones_ok'usage in balance_pgdat,
>> > I feel it's not consistent and rather confused.
>> > How about this?
>>
>> Can you please read my patch?
>
> Grr. I'm sorry. such thread don't CCed LKML.
> cut-n-past here.
>
>
> ----------------------------------------
> Umm..
> This code looks a bit risky. Please imazine asymmetric numa. If the system has
> very small node, its nude have unreclaimable state at almost time.
>
> Thus, if all zones in the node are unreclaimable, It should be slept. To retry balance_pgdat()
> is meaningless. this is original intention, I think.
>
> So why can't we write following?

Hi Kosaki,

This patch fixes the problem for me too, thanks!

Tested-by: Will Newton <will.newton@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
