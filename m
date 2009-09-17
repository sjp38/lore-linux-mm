Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0AFFE6B004F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 02:42:16 -0400 (EDT)
Received: by yxe40 with SMTP id 40so7505510yxe.28
        for <linux-mm@kvack.org>; Wed, 16 Sep 2009 23:42:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090914165435.GA21554@infradead.org>
References: <202cde0e0909132230y52b805a4i8792f2e287b01acb@mail.gmail.com>
	 <20090914165435.GA21554@infradead.org>
Date: Thu, 17 Sep 2009 18:42:20 +1200
Message-ID: <202cde0e0909162342xb2a8daeia90b33a172fc714b@mail.gmail.com>
Subject: Re: HugeTLB: Driver example
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>> There is an example of simple driver which provides huge pages mapping
>> for user level applications. The =C2=A0procedure for mapping of huge pag=
es
>> to userspace by the driver is:
>>
>> 1. Create a hugetlb file on vfs mount of hugetlbfs (h_file)
>
> Note that to get your support code included at all you'll need a real
> intree driver, not just an example. =C2=A0That is if VM people are happy =
with
> the general concept.
Hi,
The driver example listed here takes the same approach as already done
inside ipc/shm.c. So people can refer this file for development. The
patches just make existing functions more usable by drivers and this
example is an extract of ipc/shm.c in order to give pretty simple
how-to.
Seems I gave a not so good description for this patch set so it caused
a lot of misunderstanding, sorry about that.

Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
