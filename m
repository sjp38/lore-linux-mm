Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id A3FB86B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 14:30:56 -0500 (EST)
Received: by mail-we0-f175.google.com with SMTP id q59so2648448wes.34
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 11:30:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id em8si2813635wjd.147.2014.02.07.11.30.54
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 11:30:55 -0800 (PST)
Message-ID: <52F53425.7060308@redhat.com>
Date: Fri, 07 Feb 2014 14:29:41 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch] drop_caches: add some documentation and info message
References: <1391794851-11412-1-git-send-email-hannes@cmpxchg.org> <52F51E19.9000406@redhat.com> <20140207181332.GG6963@cmpxchg.org>
In-Reply-To: <20140207181332.GG6963@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@sr71.net>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/07/2014 01:13 PM, Johannes Weiner wrote:

>> Would it be better to print this after the operation
>> has completed?
>
> It would make more sense grammatically :-) Either way is fine with me,
> updated below to inform after the fact.

Well, in principle the operation could take an arbitrarily
long time, so there are some minor concerns besides
grammatical correctness, too :)

Thanks for updating the patch.

> ---
> From: Dave Hansen <dave@linux.vnet.ibm.com>
> Date: Fri, 12 Oct 2012 14:30:54 +0200
> Subject: [patch] drop_caches: add some documentation and info message

> Dropping caches is a very drastic and disruptive operation that is
> good for debugging and running tests, but if it creates bug reports
> from production use, kernel developers should be aware of its use.
>
> Add a bit more documentation about it, and add a little KERN_NOTICE.
>
> [akpm@linux-foundation.org: checkpatch fixes]
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
