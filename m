Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B60E6B0038
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 14:52:40 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id g186so347117736pgc.2
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 11:52:40 -0800 (PST)
Received: from out03.mta.xmission.com (out03.mta.xmission.com. [166.70.13.233])
        by mx.google.com with ESMTPS id z3si49105883pfd.61.2016.12.13.11.52.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 11:52:39 -0800 (PST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <CANaxB-y0rcGcVY1_CRzRp7to-C3k7tSM5GDwzyLvzj5_BKP5Mw@mail.gmail.com>
	<CANaxB-yqO6gmMJkpYiWp7fq-TJwPo6yHGaLvQgHPJ0ug+j5STQ@mail.gmail.com>
	<87eg1dk5cv.fsf@xmission.com>
	<CANaxB-xGO9-tNBasB2G_5qxavja6h0RB9npsh4Uu9=YbJtwgHQ@mail.gmail.com>
	<87wpf5c68l.fsf@xmission.com>
Date: Wed, 14 Dec 2016 08:49:32 +1300
In-Reply-To: <87wpf5c68l.fsf@xmission.com> (Eric W. Biederman's message of
	"Tue, 13 Dec 2016 08:11:38 +1300")
Message-ID: <877f73hann.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: linux-next: kernel BUG at mm/vmalloc.c:463!
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrei Vagin <avagin@gmail.com>
Cc: linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, Nikolay Borisov <n.borisov.lkml@gmail.com>

ebiederm@xmission.com (Eric W. Biederman) writes:

> Andrei Vagin <avagin@gmail.com> writes:
>
>> On Sun, Dec 11, 2016 at 10:51 PM, Eric W. Biederman
>> <ebiederm@xmission.com> wrote:
>>> Andrei Vagin <avagin@gmail.com> writes:
>>>
>>>> On Sun, Dec 11, 2016 at 6:55 PM, Andrei Vagin <avagin@gmail.com> wrote:
>>>>> Hi,
>>>>>
>>>>> CRIU tests triggered a kernel bug:
>>>>
>>>> I''ve booted this kernel with slub_debug=FZ and now I see these
>>>> messages:

Andrei, are the CRIU tests that failed part of the normal regression
tests for CRIU that Nikolay Borisov can run so he can reproduce this
failure and figure out what is wrong with his code?

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
