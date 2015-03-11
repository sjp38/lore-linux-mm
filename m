Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9034A90002E
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 00:35:33 -0400 (EDT)
Received: by qcxm20 with SMTP id m20so7538451qcx.3
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 21:35:33 -0700 (PDT)
Received: from mail-qc0-x22c.google.com (mail-qc0-x22c.google.com. [2607:f8b0:400d:c01::22c])
        by mx.google.com with ESMTPS id w7si2438482qha.66.2015.03.10.21.35.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Mar 2015 21:35:33 -0700 (PDT)
Received: by qcwr17 with SMTP id r17so7607722qcw.2
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 21:35:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150310142237.GA2095@quack.suse.cz>
References: <1423666208-10681-1-git-send-email-k.kozlowski@samsung.com>
	<1423666208-10681-2-git-send-email-k.kozlowski@samsung.com>
	<CAH9JG2X5qO418qp3_ZAvwE7LPe6YC_FdKkOwHtpYxzqZkUvB_w@mail.gmail.com>
	<20150310130323.GA1515@infradead.org>
	<20150310142237.GA2095@quack.suse.cz>
Date: Wed, 11 Mar 2015 13:35:32 +0900
Message-ID: <CAH9JG2UOuWum=c2bCCgmc8E5xJ1Rhn8yYQ1AMyu8z8CavrAYkw@mail.gmail.com>
Subject: Re: [RFC] shmem: Add eventfd notification on utlilization level
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, Krzysztof Kozlowski <k.kozlowski@samsung.com>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Tue, Mar 10, 2015 at 11:22 PM, Jan Kara <jack@suse.cz> wrote:
> On Tue 10-03-15 06:03:23, Christoph Hellwig wrote:
>> On Tue, Mar 10, 2015 at 10:51:41AM +0900, Kyungmin Park wrote:
>> > Any updates?
>>
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

In mobile case, it provides two warning messages when it remains 5%
and 0.1% respectively.
to achieve it, some daemon call statfs periodically. right it's inefficient.

that's reason we need some notification method from filesystem.

tmpfs is different story. some malicious app fills tmpfs then system
goes slow. so it has to check it periodically.
to avoid it, this patch is developed and want to get feedback.

we considered quota but it's not desired one. other can't write tmpfs
even though it has 20% remaining.

Thank you,
Kyungmin Park

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
