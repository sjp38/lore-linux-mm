Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 57CBD6B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 06:16:08 -0500 (EST)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id oAIBG3CP008025
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 03:16:06 -0800
Received: from qyk38 (qyk38.prod.google.com [10.241.83.166])
	by kpbe16.cbf.corp.google.com with ESMTP id oAIBG2jU032627
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 03:16:02 -0800
Received: by qyk38 with SMTP id 38so7331810qyk.16
        for <linux-mm@kvack.org>; Thu, 18 Nov 2010 03:16:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1011161444200.16422@tigran.mtv.corp.google.com>
References: <20101109115540.BC3F.A69D9226@jp.fujitsu.com>
	<AANLkTinrtXrwgwUXNOaM_AGin2iEMqN2wWciMzJUPUyB@mail.gmail.com>
	<20101112142038.E002.A69D9226@jp.fujitsu.com>
	<alpine.LSU.2.00.1011151717130.10920@tigran.mtv.corp.google.com>
	<AANLkTin+16yDxGrRfbqw9OPnDDV8OgXr_nbZnXJEHK9w@mail.gmail.com>
	<alpine.LSU.2.00.1011161444200.16422@tigran.mtv.corp.google.com>
Date: Thu, 18 Nov 2010 03:16:02 -0800
Message-ID: <AANLkTi=qSv2JnrAD7YWv+odPfirxq9Z8+Z2_FNAQtK8D@mail.gmail.com>
Subject: Re: RFC: reviving mlock isolation dead code
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, Arjan van de Ven <arjan@infradead.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 16, 2010 at 3:28 PM, Hugh Dickins <hughd@google.com> wrote:
> Yes, in fact, is anything required beyond Peter's original simple patch?

I initially thought there would be a problem with breaking COW on anon
pages (think of fork() + mlock() ), but then I realized these won't
show up in VM_SHARED vmas, so Peter's patch seems fine.

> Added Ccs of those most likely to agree or disagree with us.

I forgot to add Arjan and Andrea in my proposal ('Avoid dirtying pages
during mlock'). Let's move the discussion there.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
