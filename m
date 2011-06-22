Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A7C4E6B024D
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 23:08:50 -0400 (EDT)
Message-ID: <4E015CB8.1010300@redhat.com>
Date: Wed, 22 Jun 2011 11:08:40 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/4] mm: completely disable THP by transparent_hugepage=0
References: <1308643849-3325-1-git-send-email-amwang@redhat.com> <alpine.DEB.2.00.1106211814250.5205@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1106211814250.5205@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Randy Dunlap <rdunlap@xenotime.net>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org

ao? 2011a1'06ae??22ae?JPY 09:16, David Rientjes a??e??:
> On Tue, 21 Jun 2011, Amerigo Wang wrote:
>
>> Introduce "transparent_hugepage=0" to totally disable THP.
>> "transparent_hugepage=never" means setting THP to be partially
>> disabled, we need a new way to totally disable it.
>>
>
> Why can't you just compile it off so you never even compile
> mm/huge_memory.c in the first place and save the space in the kernel image
> as well?  Having the interface available to enable the feature at runtime
> is worth the savings this patch provides, in my opinion.

https://lkml.org/lkml/2011/6/20/506

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
