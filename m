Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id BE864280250
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 17:18:39 -0400 (EDT)
Received: by igbij6 with SMTP id ij6so56603459igb.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 14:18:39 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id ek2si2378648icb.29.2015.07.14.14.18.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 14 Jul 2015 14:18:39 -0700 (PDT)
Date: Tue, 14 Jul 2015 16:18:38 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] mm/slub: disable merging after enabling debug in
 runtime
In-Reply-To: <CALYGNiPKgfE+KNNgmW0ZGrFqU4NSsz_vm14Zu2gXFyjPWnE57g@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1507141616440.12219@east.gentwo.org>
References: <20150714131704.21442.17939.stgit@buzz> <20150714131705.21442.99279.stgit@buzz> <alpine.DEB.2.11.1507141304430.28065@east.gentwo.org> <CALYGNiPKgfE+KNNgmW0ZGrFqU4NSsz_vm14Zu2gXFyjPWnE57g@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>


On Tue, 14 Jul 2015, Konstantin Khlebnikov wrote:
> > What breaks?
>
> The same commands from first patch:
>
> # echo 1 | tee /sys/kernel/slab/*/sanity_checks
> # modprobe configfs
>
> loading configfs now fails (without crashing kernel though) because of
> "sysfs: cannot create duplicate filename '/kernel/slab/:t-0000096'"

Hrm.... Bad. Maybe drop the checks for the debug options that can be
configured when merging slabs? They do not influence the object layout
per definition.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
