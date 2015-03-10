Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3F10E900020
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 12:14:13 -0400 (EDT)
Received: by qgdq107 with SMTP id q107so3062100qgd.7
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 09:14:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id el5si902913qcb.33.2015.03.10.09.14.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Mar 2015 09:14:12 -0700 (PDT)
Date: Tue, 10 Mar 2015 17:13:37 +0100 (CET)
From: =?ISO-8859-15?Q?Luk=E1=A8_Czerner?= <lczerner@redhat.com>
Subject: Re: [RFC] shmem: Add eventfd notification on utlilization level
In-Reply-To: <54FF0CD8.10709@gmail.com>
Message-ID: <alpine.LFD.2.00.1503101712150.2276@localhost.localdomain>
References: <1423666208-10681-1-git-send-email-k.kozlowski@samsung.com> <1423666208-10681-2-git-send-email-k.kozlowski@samsung.com> <CAH9JG2X5qO418qp3_ZAvwE7LPe6YC_FdKkOwHtpYxzqZkUvB_w@mail.gmail.com> <20150310130323.GA1515@infradead.org>
 <20150310142237.GA2095@quack.suse.cz> <54FF0CD8.10709@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Beata Michalska <b.k.m.devel@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Kyungmin Park <kmpark@infradead.org>, Krzysztof Kozlowski <k.kozlowski@samsung.com>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Tue, 10 Mar 2015, Beata Michalska wrote:

> Date: Tue, 10 Mar 2015 16:25:12 +0100
> From: Beata Michalska <b.k.m.devel@gmail.com>
> To: Jan Kara <jack@suse.cz>
> Cc: Christoph Hellwig <hch@infradead.org>,
>     Kyungmin Park <kmpark@infradead.org>,
>     Krzysztof Kozlowski <k.kozlowski@samsung.com>,
>     Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>,
>     Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
>     Alexander Viro <viro@zeniv.linux.org.uk>,
>     Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>,
>     Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
>     Marek Szyprowski <m.szyprowski@samsung.com>
> Subject: Re: [RFC] shmem: Add eventfd notification on utlilization level
> 
> On 03/10/2015 03:22 PM, Jan Kara wrote:
> > On Tue 10-03-15 06:03:23, Christoph Hellwig wrote:
> >> On Tue, Mar 10, 2015 at 10:51:41AM +0900, Kyungmin Park wrote:
> >>> Any updates?
> >> Please just add disk quota support to tmpfs so thast the standard quota
> >> netlink notifications can be used.
> >   If I understand the problem at hand, they are really interested in
> > notification when running out of free space. Using quota for that doesn't
> > seem ideal since that tracks used space per user, not free space on fs as a
> > whole.
> >
> > But if I remember right there were discussions about ENOSPC notification
> > from filesystem for thin provisioning usecases. It would be good to make
> > this consistent with those but I'm not sure if it went anywhere.
> >
> > 								Honza
> 
> The ideal case here, would be to get the notification, despite the type
> of the actual filesystem, whenever the amount of free space drops below
> a certain level. Quota doesn't seem to be the right approach here.
> 
> BR
> Beata Michalska

A while back I was prototyping a netlink notification interface for
file systems, but it went nowhere.

https://lkml.org/lkml/2011/8/18/170

So maybe it's time get back to the drawing board and finish the
idea, since it seems to be some interest in this now.

-Lukas

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
