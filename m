Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id EE4446B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 15:04:36 -0400 (EDT)
Received: by wibg7 with SMTP id g7so83029870wib.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 12:04:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w20si182145wjr.194.2015.03.24.12.04.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 12:04:35 -0700 (PDT)
Date: Tue, 24 Mar 2015 20:02:29 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm: fix lockdep build in rcu-protected
	get_mm_exe_file()
Message-ID: <20150324190229.GC11834@redhat.com>
References: <20150320144715.24899.24547.stgit@buzz> <1427134273.2412.12.camel@stgolabs.net> <20150323191055.GA10212@redhat.com> <55119B3B.5020403@yandex-team.ru> <20150324181016.GA9678@redhat.com> <CALYGNiP15BLtxMmMnpEu94jZBtce7tCtJnavrguqFr1d2XxH_A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiP15BLtxMmMnpEu94jZBtce7tCtJnavrguqFr1d2XxH_A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Davidlohr Bueso <dave@stgolabs.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 03/24, Konstantin Khlebnikov wrote:
>
> On Tue, Mar 24, 2015 at 9:10 PM, Oleg Nesterov <oleg@redhat.com> wrote:
> >>>
> >>> "atomic_read(&mm->mm_users) <= 1" looks a bit more "safe". But again,
> >>> I won't insist.
> >>
> >> Not so safe: this will race with get_task_mm().
> >
> > How?
>
> I mean rcu/lockdep debug migh race with get_task_mm() and generate
> false-positive warning about non-protected rcu_dereference.

Still can't understand, I think it can't... and if it could, then this
warning would not be false positive.

Anut this doesn't matter because we seem to agree this check should go away.

> > Yeees, probably rcu_dereference_raw() would be even better. set_mm_exe_file()
> > must be called only if nobody but us can access this mm.
>
> Yep.

Great. Davidlohr will you agree?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
