Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD0C6B0169
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 03:37:09 -0400 (EDT)
Received: by vwm42 with SMTP id 42so1653505vwm.14
        for <linux-mm@kvack.org>; Thu, 04 Aug 2011 00:37:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110804072651.GD21516@cmpxchg.org>
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
	<1312427390-20005-2-git-send-email-lliubbo@gmail.com>
	<1312427390-20005-3-git-send-email-lliubbo@gmail.com>
	<20110804072651.GD21516@cmpxchg.org>
Date: Thu, 4 Aug 2011 10:37:05 +0300
Message-ID: <CAOJsxLEkUxLd=_GyWAknAsxOVP5uA4Y2NsMFohJTP2RXsRqnCw@mail.gmail.com>
Subject: Re: [PATCH 3/4] sparse: using kzalloc to clean up code
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Bob Liu <lliubbo@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, namhyung@gmail.com, mhocko@suse.cz, lucas.demarchi@profusion.mobi, aarcange@redhat.com, tj@kernel.org, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com, dan.magenheimer@oracle.com

On Thu, Aug 4, 2011 at 10:26 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Thu, Aug 04, 2011 at 11:09:49AM +0800, Bob Liu wrote:
>> This patch using kzalloc to clean up sparse_index_alloc() and
>> __GFP_ZERO to clean up __kmalloc_section_memmap().
>>
>> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
