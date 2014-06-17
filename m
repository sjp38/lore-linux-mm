Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 935796B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 06:10:21 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id h18so3958847igc.10
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 03:10:21 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id y5si15403980igl.3.2014.06.17.03.10.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 03:10:20 -0700 (PDT)
Received: by mail-ig0-f175.google.com with SMTP id uq10so3973375igb.8
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 03:10:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53A012C8.7060109@redhat.com>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
	<CALCETrVoE+JO2rLsBUHAOJdvescEEjxikj8iQ339Nxfopfc7pw@mail.gmail.com>
	<CANq1E4SaWLD=hNEc-CDJbNnrGfXE_PkxZFBhpW4tbK7wor7xPA@mail.gmail.com>
	<CALCETrU8N9EbnJ3=oQ1WQCG9Vunn3nR9Ba=J48wJm0SuH0YB4A@mail.gmail.com>
	<CANq1E4QQUKHabheq18AzkVZk3WDtAeC-6W66tVNB+EKgYOx1Vg@mail.gmail.com>
	<53A01049.6020502@redhat.com>
	<CANq1E4T3KJZ++=KF2OZ_dd+NvPqg+=4Pw6O7Po3-ZxaaMHPukw@mail.gmail.com>
	<53A012C8.7060109@redhat.com>
Date: Tue, 17 Jun 2014 12:10:20 +0200
Message-ID: <CANq1E4QinvVA-O=dX4N819jVK3xSihJcpz9juFj+A3qv0MXODg@mail.gmail.com>
Subject: Re: [PATCH v3 0/7] File Sealing & memfd_create()
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Andy Lutomirski <luto@amacapital.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>

Hi

On Tue, Jun 17, 2014 at 12:04 PM, Florian Weimer <fweimer@redhat.com> wrote:
> On 06/17/2014 12:01 PM, David Herrmann wrote:
>
>>> I don't think this is what potential users expect because mlock requires
>>> capabilities which are not available to them.
>>>
>>> A couple of weeks ago, sealing was to be applied to anonymous shared
>>> memory.
>>> Has this changed?  Why should *reading* it trigger OOM?
>>
>> The file might have holes, therefore, you'd have to allocate backing
>> pages. This might hit a soft-limit and fail. To avoid this, use
>> fallocate() to allocate pages prior to mmap()
>
> This does not work because the consuming side does not know how the
> descriptor was set up if sealing does not imply that.

The consuming side has to very seals via F_GET_SEALS. After that, it
shall do a simple fallocate() on the whole file if it wants to go sure
that all pages are allocated. Why shouldn't that be possible? Please
elaborate.

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
