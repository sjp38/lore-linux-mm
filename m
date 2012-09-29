Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id D28906B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 20:11:32 -0400 (EDT)
Received: by ied10 with SMTP id 10so10799430ied.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2012 17:11:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1209261929270.8567@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1209191818490.7879@chino.kir.corp.google.com>
	<alpine.LSU.2.00.1209192021270.28543@eggly.anvils>
	<alpine.DEB.2.00.1209261821380.7745@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1209261929270.8567@chino.kir.corp.google.com>
Date: Fri, 28 Sep 2012 17:11:31 -0700
Message-ID: <CANN689Hx2vcQn-DEPAvvJMMQmUrJWOAWnPzeL7maC1SL0okG7A@mail.gmail.com>
Subject: Re: [patch] mm, thp: fix mlock statistics
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Wed, Sep 26, 2012 at 7:29 PM, David Rientjes <rientjes@google.com> wrote:
> NR_MLOCK is only accounted in single page units: there's no logic to
> handle transparent hugepages.  This patch checks the appropriate number
> of pages to adjust the statistics by so that the correct amount of memory
> is reflected.
>
> Reported-by: Hugh Dickens <hughd@google.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

Looks good, thanks!

Reviewed-by: Michel Lespinasse <walken@google.com>

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
