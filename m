Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0A4C09000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 12:57:02 -0400 (EDT)
Received: by fxh17 with SMTP id 17so9644605fxh.14
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 09:56:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CANN689G4Z21v6fcF1dt-10CpQp9V42_hGPcPP2d5FChfCon_9Q@mail.gmail.com>
References: <1316230753-8693-1-git-send-email-walken@google.com>
	<CAKTCnzkzdQgut96NZf3Mi2kpOWW7N3qeybets5AHy7Gp8Wj_HQ@mail.gmail.com>
	<CANN689G4Z21v6fcF1dt-10CpQp9V42_hGPcPP2d5FChfCon_9Q@mail.gmail.com>
Date: Tue, 27 Sep 2011 22:20:21 +0530
Message-ID: <CAKTCnzkmwiDcetuNY4yeOgfog39ojQBW9oZF8+THD+Uqshbdwg@mail.gmail.com>
Subject: Re: [PATCH 0/8] idle page tracking / working set estimation
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>

>>
>> Sorry, I have trouble parsing this sentence, could you elaborate on "when"?
>
> page_referenced() indicates if a page was accessed since the previous
> page_referenced() call.
>
> page_referenced_kstaled() indicates if a page was accessed since the
> previous page_referenced_kstaled() call.
>
> Both of the functions need to clear PTE young bits; however we don't
> want the two functions to interfere with each other. To achieve this,
> we add two page bits to indicate when a young PTE has been observed by
> one of the functions but not by the other.

OK and this gives different page aging schemes for the same page? Is
this to track state changes

PR1 sees: PTE x young as 0
PR2 sees: PTE x as 1, the rest to 0

so PR1 and PR2 will disagree? Should I be looking deeper in the
patches to understand

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
