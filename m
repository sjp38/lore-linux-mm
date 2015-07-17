Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2649928033A
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 11:09:51 -0400 (EDT)
Received: by igvi1 with SMTP id i1so37223301igv.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 08:09:51 -0700 (PDT)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id l1si9456595iol.110.2015.07.17.08.09.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 17 Jul 2015 08:09:50 -0700 (PDT)
Date: Fri, 17 Jul 2015 10:09:49 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] mm/slub: disable merging after enabling debug in
 runtime
In-Reply-To: <CALYGNiM6iKzwSiKRu79N-pjnSQZR_P3t9q50vV3cHtvLQz=dCA@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1507171008080.17929@east.gentwo.org>
References: <20150714131704.21442.17939.stgit@buzz> <20150714131705.21442.99279.stgit@buzz> <alpine.DEB.2.11.1507141304430.28065@east.gentwo.org> <CALYGNiPKgfE+KNNgmW0ZGrFqU4NSsz_vm14Zu2gXFyjPWnE57g@mail.gmail.com> <alpine.DEB.2.11.1507141616440.12219@east.gentwo.org>
 <CALYGNiM6iKzwSiKRu79N-pjnSQZR_P3t9q50vV3cHtvLQz=dCA@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, 17 Jul 2015, Konstantin Khlebnikov wrote:

> > Hrm.... Bad. Maybe drop the checks for the debug options that can be
> > configured when merging slabs? They do not influence the object layout
> > per definition.
>
> I don't understand that. Debug options do changes in object layout.

Only some debug options change the object layout and those are alrady
forbidden for caches with objects.

> Since they add significant performance overhead and cannot be undone in runtime
> it's unlikely that anyone who uses them don't care about merging after that.

Those that do not affect the object layout can be undone.

> Also I don't see how merging could affect debugging in positive way
> (except debugging bugs in merging logic itself).

The problem here is that debugging is switched on for slabs that are
already merged right?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
