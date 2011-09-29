Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD4E9000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 20:09:37 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p8T09Zc7000402
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 17:09:35 -0700
Received: from qyg14 (qyg14.prod.google.com [10.241.82.142])
	by hpaq11.eem.corp.google.com with ESMTP id p8T09XSJ027937
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 17:09:34 -0700
Received: by qyg14 with SMTP id 14so201378qyg.16
        for <linux-mm@kvack.org>; Wed, 28 Sep 2011 17:09:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110928161805.8acb33c5.kamezawa.hiroyu@jp.fujitsu.com>
References: <1317170947-17074-1-git-send-email-walken@google.com>
	<1317170947-17074-4-git-send-email-walken@google.com>
	<20110928161805.8acb33c5.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 28 Sep 2011 17:09:32 -0700
Message-ID: <CANN689GuZHzCa4Xr-YwPrpvy8Fcff4pQLrDQ+a+G_56mvBMwMQ@mail.gmail.com>
Subject: Re: [PATCH 3/9] kstaled: page_referenced_kstaled() and supporting infrastructure.
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

On Wed, Sep 28, 2011 at 12:18 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 2 questions.
>
> What happens at Transparent HugeTLB pages are splitted/collapsed ?

Nothing special - at the next scan, pages are counted again
considering their new size.

> Does this feature can ignore page migration i.e. flags should not be copied ?

We're not doing it currently. As I understand, the migrate code does
not copy the PTE young bits either, nor does it try to preserve page
order in the LRU lists. So it's not transparent to the LRU algorithms,
but it does not cause incorrect behavior either.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
