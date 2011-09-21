Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B83A09000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:51:39 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p8L2pVjs027564
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 19:51:31 -0700
Received: from qwm42 (qwm42.prod.google.com [10.241.196.42])
	by hpaq3.eem.corp.google.com with ESMTP id p8L2oB2C022945
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 19:51:30 -0700
Received: by qwm42 with SMTP id 42so1562577qwm.1
        for <linux-mm@kvack.org>; Tue, 20 Sep 2011 19:51:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E78E3DF.1070501@redhat.com>
References: <1316230753-8693-1-git-send-email-walken@google.com>
	<1316230753-8693-2-git-send-email-walken@google.com>
	<4E78E3DF.1070501@redhat.com>
Date: Tue, 20 Sep 2011 19:51:29 -0700
Message-ID: <CANN689EkOMyUuMCZFBHMUtq85uU-233c-4i3_cT=ZqfYVW1JjQ@mail.gmail.com>
Subject: Re: [PATCH 1/8] page_referenced: replace vm_flags parameter with
 struct pr_info
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>

On Tue, Sep 20, 2011 at 12:05 PM, Rik van Riel <riel@redhat.com> wrote:
> I have to agree with Joe's suggested name change.
>
> Other than that, this patch looks good (will ack the next version).

Very sweet ! I'll make sure to send that out soon. I think it's
easiest if I wait for you to review the current patches first, though
? (I'll send an incremental diff along with the next patch series)

Thanks a lot for having a look.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
