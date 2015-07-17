Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id C1017280319
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 05:37:42 -0400 (EDT)
Received: by lbbyj8 with SMTP id yj8so58179542lbb.0
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 02:37:42 -0700 (PDT)
Received: from mail-la0-x235.google.com (mail-la0-x235.google.com. [2a00:1450:4010:c03::235])
        by mx.google.com with ESMTPS id kw7si9400312lac.136.2015.07.17.02.37.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 02:37:41 -0700 (PDT)
Received: by lagx9 with SMTP id x9so57967080lag.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 02:37:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1507141616440.12219@east.gentwo.org>
References: <20150714131704.21442.17939.stgit@buzz>
	<20150714131705.21442.99279.stgit@buzz>
	<alpine.DEB.2.11.1507141304430.28065@east.gentwo.org>
	<CALYGNiPKgfE+KNNgmW0ZGrFqU4NSsz_vm14Zu2gXFyjPWnE57g@mail.gmail.com>
	<alpine.DEB.2.11.1507141616440.12219@east.gentwo.org>
Date: Fri, 17 Jul 2015 12:37:40 +0300
Message-ID: <CALYGNiM6iKzwSiKRu79N-pjnSQZR_P3t9q50vV3cHtvLQz=dCA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/slub: disable merging after enabling debug in runtime
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Jul 15, 2015 at 12:18 AM, Christoph Lameter <cl@linux.com> wrote:
>
> On Tue, 14 Jul 2015, Konstantin Khlebnikov wrote:
>> > What breaks?
>>
>> The same commands from first patch:
>>
>> # echo 1 | tee /sys/kernel/slab/*/sanity_checks
>> # modprobe configfs
>>
>> loading configfs now fails (without crashing kernel though) because of
>> "sysfs: cannot create duplicate filename '/kernel/slab/:t-0000096'"
>
> Hrm.... Bad. Maybe drop the checks for the debug options that can be
> configured when merging slabs? They do not influence the object layout
> per definition.

I don't understand that. Debug options do changes in object layout.

Since they add significant performance overhead and cannot be undone in runtime
it's unlikely that anyone who uses them don't care about merging after that.
Also I don't see how merging could affect debugging in positive way
(except debugging bugs in merging logic itself).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
