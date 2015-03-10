Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6CE796B007B
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 11:25:19 -0400 (EDT)
Received: by iecvj10 with SMTP id vj10so18939993iec.0
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 08:25:19 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id tu4si1208023pab.237.2015.03.10.08.25.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 10 Mar 2015 08:25:18 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NL0005R65OWEZB0@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 10 Mar 2015 15:29:20 +0000 (GMT)
Message-id: <54FF0CD8.10709@gmail.com>
Date: Tue, 10 Mar 2015 16:25:12 +0100
From: Beata Michalska <b.k.m.devel@gmail.com>
MIME-version: 1.0
Subject: Re: [RFC] shmem: Add eventfd notification on utlilization level
References: <1423666208-10681-1-git-send-email-k.kozlowski@samsung.com>
 <1423666208-10681-2-git-send-email-k.kozlowski@samsung.com>
 <CAH9JG2X5qO418qp3_ZAvwE7LPe6YC_FdKkOwHtpYxzqZkUvB_w@mail.gmail.com>
 <20150310130323.GA1515@infradead.org> <20150310142237.GA2095@quack.suse.cz>
In-reply-to: <20150310142237.GA2095@quack.suse.cz>
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, Kyungmin Park <kmpark@infradead.org>, Krzysztof Kozlowski <k.kozlowski@samsung.com>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On 03/10/2015 03:22 PM, Jan Kara wrote:
> On Tue 10-03-15 06:03:23, Christoph Hellwig wrote:
>> On Tue, Mar 10, 2015 at 10:51:41AM +0900, Kyungmin Park wrote:
>>> Any updates?
>> Please just add disk quota support to tmpfs so thast the standard quota
>> netlink notifications can be used.
>   If I understand the problem at hand, they are really interested in
> notification when running out of free space. Using quota for that doesn't
> seem ideal since that tracks used space per user, not free space on fs as a
> whole.
>
> But if I remember right there were discussions about ENOSPC notification
> from filesystem for thin provisioning usecases. It would be good to make
> this consistent with those but I'm not sure if it went anywhere.
>
> 								Honza

The ideal case here, would be to get the notification, despite the type
of the actual filesystem, whenever the amount of free space drops below
a certain level. Quota doesn't seem to be the right approach here.

BR
Beata Michalska

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
