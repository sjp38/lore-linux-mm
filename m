Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 22F928D003B
	for <linux-mm@kvack.org>; Thu,  7 Apr 2011 10:24:02 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p37ENxM1005314
	for <linux-mm@kvack.org>; Thu, 7 Apr 2011 07:23:59 -0700
Received: from gyg4 (gyg4.prod.google.com [10.243.50.132])
	by hpaq11.eem.corp.google.com with ESMTP id p37ENvo5022491
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 7 Apr 2011 07:23:57 -0700
Received: by gyg4 with SMTP id 4so1322028gyg.18
        for <linux-mm@kvack.org>; Thu, 07 Apr 2011 07:23:56 -0700 (PDT)
Date: Thu, 7 Apr 2011 07:24:02 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: fix possible cause of a page_mapped BUG
In-Reply-To: <BANLkTim-hyXpLj537asC__8exMo3o-WCLA@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1104070718120.28555@sister.anvils>
References: <alpine.LSU.2.00.1102232136020.2239@sister.anvils> <AANLkTi==MQV=_qq1HaCxGLRu8DdT6FYddqzBkzp1TQs7@mail.gmail.com> <AANLkTimv66fV1+JDqSAxRwddvy_kggCuhoJLMTpMTtJM@mail.gmail.com> <alpine.LSU.2.00.1103182158200.18771@sister.anvils>
 <BANLkTinoNMudwkcOOgU5d+imPUfZhDbWWQ@mail.gmail.com> <AANLkTimfArmB7judMW7Qd4ATtVaR=yTf_-0DBRAfCJ7w@mail.gmail.com> <BANLkTi=Limr3NUaG7RLoQLv5TuEDmm7Rqg@mail.gmail.com> <BANLkTi=UZcocVk_16MbbV432g9a3nDFauA@mail.gmail.com> <BANLkTi=KTdLRC_hRvxfpFoMSbz=vOjpObw@mail.gmail.com>
 <BANLkTindeX9-ECPjgd_V62ZbXCd7iEG9_w@mail.gmail.com> <BANLkTikcZK+AQvwe2ED=b0dLZ0hqg0B95w@mail.gmail.com> <BANLkTimV1f1YDTWZUU9uvAtCO_fp6EKH9Q@mail.gmail.com> <BANLkTi=tavhpytcSV+nKaXJzw19Bo3W9XQ@mail.gmail.com> <alpine.LSU.2.00.1104060837590.4909@sister.anvils>
 <BANLkTi=-Zb+vrQuY6J+dAMsmz+cQDD-KUw@mail.gmail.com> <BANLkTim0MZfa8vFgHB3W6NsoPHp2jfirrA@mail.gmail.com> <BANLkTim-hyXpLj537asC__8exMo3o-WCLA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Swiecki <robert@swiecki.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, Michel Lespinasse <walken@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>

On Thu, 7 Apr 2011, Robert Swiecki wrote:
> >
> > Testing with Linus' patch. Will let you know in a few hours.
> 
> Ok, nothing happened after ~20h. The bug, usually, was triggered within 5-10h.
> 
> I can add some printk in this condition, and let it run for a few days
> (I will not have access to my testing machine throughout that time),
> if you think this will confirm your hypothesis.

That's great, thanks Robert.  If the machine has nothing better to do,
then it would be nice to let it run a little longer (a few days if that's
what suits you), but it does look good so far.  Though I'm afraid you'll
now discover something else entirely ;)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
