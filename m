Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 581D46B0069
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 14:14:59 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id g186so266723305pgc.2
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 11:14:59 -0800 (PST)
Received: from out02.mta.xmission.com (out02.mta.xmission.com. [166.70.13.232])
        by mx.google.com with ESMTPS id t184si44565552pgd.119.2016.12.12.11.14.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 11:14:58 -0800 (PST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <CANaxB-y0rcGcVY1_CRzRp7to-C3k7tSM5GDwzyLvzj5_BKP5Mw@mail.gmail.com>
	<CANaxB-yqO6gmMJkpYiWp7fq-TJwPo6yHGaLvQgHPJ0ug+j5STQ@mail.gmail.com>
	<87eg1dk5cv.fsf@xmission.com>
	<CANaxB-xGO9-tNBasB2G_5qxavja6h0RB9npsh4Uu9=YbJtwgHQ@mail.gmail.com>
Date: Tue, 13 Dec 2016 08:11:38 +1300
In-Reply-To: <CANaxB-xGO9-tNBasB2G_5qxavja6h0RB9npsh4Uu9=YbJtwgHQ@mail.gmail.com>
	(Andrei Vagin's message of "Mon, 12 Dec 2016 10:55:04 -0800")
Message-ID: <87wpf5c68l.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: linux-next: kernel BUG at mm/vmalloc.c:463!
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrei Vagin <avagin@gmail.com>
Cc: linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>

Andrei Vagin <avagin@gmail.com> writes:

> On Sun, Dec 11, 2016 at 10:51 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>> Andrei Vagin <avagin@gmail.com> writes:
>>
>>> On Sun, Dec 11, 2016 at 6:55 PM, Andrei Vagin <avagin@gmail.com> wrote:
>>>> Hi,
>>>>
>>>> CRIU tests triggered a kernel bug:
>>>
>>> I''ve booted this kernel with slub_debug=FZ and now I see these
>>> messages:
>>
>> I think I have dropped the cause of this corruption from my linux-next
>> tree, and hopefully from linux-next.
>>
>> I believe this was: "inotify: Convert to using per-namespace limits"
>> If you could verify dropping/reverting that patch from linux-next causes
>> this failure to go away I would appreciate.
>>
>> I am quite puzzled why that patch causes heap corruption but it seems clear
>> it does.
>>
>> If you can trigger this problem without that patch I would really
>> appreciate knowing.
>
> It works without this patch. All tests passed on next-20161212. Thanks!

Thank you for verifying that.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
