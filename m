Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 1C66F9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 06:14:19 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p8RAEF3g009251
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 03:14:15 -0700
Received: from qyk27 (qyk27.prod.google.com [10.241.83.155])
	by wpaz21.hot.corp.google.com with ESMTP id p8RADrZ1019324
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 03:14:14 -0700
Received: by qyk27 with SMTP id 27so8214320qyk.14
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 03:14:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKTCnzkzdQgut96NZf3Mi2kpOWW7N3qeybets5AHy7Gp8Wj_HQ@mail.gmail.com>
References: <1316230753-8693-1-git-send-email-walken@google.com>
	<CAKTCnzkzdQgut96NZf3Mi2kpOWW7N3qeybets5AHy7Gp8Wj_HQ@mail.gmail.com>
Date: Tue, 27 Sep 2011 03:14:09 -0700
Message-ID: <CANN689G4Z21v6fcF1dt-10CpQp9V42_hGPcPP2d5FChfCon_9Q@mail.gmail.com>
Subject: Re: [PATCH 0/8] idle page tracking / working set estimation
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>

On Tue, Sep 27, 2011 at 3:03 AM, Balbir Singh <bsingharora@gmail.com> wrote:
> On Sat, Sep 17, 2011 at 9:09 AM, Michel Lespinasse <walken@google.com> wrote:
>> Patch 3 introduces page_referenced_kstaled(), which is similar to
>> page_referenced() but is used for idle page tracking rather than
>> for memory reclaimation. Since both functions clear the pte_young bits
>> and we don't want them to interfere with each other, two new page flags
>> are introduced that track when young pte references have been cleared by
>> each of the page_referenced variants.
>
> Sorry, I have trouble parsing this sentence, could you elaborate on "when"?

page_referenced() indicates if a page was accessed since the previous
page_referenced() call.

page_referenced_kstaled() indicates if a page was accessed since the
previous page_referenced_kstaled() call.

Both of the functions need to clear PTE young bits; however we don't
want the two functions to interfere with each other. To achieve this,
we add two page bits to indicate when a young PTE has been observed by
one of the functions but not by the other.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
