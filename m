Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BCF956B01CA
	for <linux-mm@kvack.org>; Sat, 19 Jun 2010 13:49:59 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o5JHntZ1022605
	for <linux-mm@kvack.org>; Sat, 19 Jun 2010 10:49:55 -0700
Received: from gwj21 (gwj21.prod.google.com [10.200.10.21])
	by wpaz21.hot.corp.google.com with ESMTP id o5JHnsmq029846
	for <linux-mm@kvack.org>; Sat, 19 Jun 2010 10:49:54 -0700
Received: by gwj21 with SMTP id 21so1326gwj.4
        for <linux-mm@kvack.org>; Sat, 19 Jun 2010 10:49:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <878w6bphc2.fsf@basil.nowhere.org>
References: <1276907415-504-1-git-send-email-mrubin@google.com>
	<1276907415-504-4-git-send-email-mrubin@google.com> <878w6bphc2.fsf@basil.nowhere.org>
From: Michael Rubin <mrubin@google.com>
Date: Sat, 19 Jun 2010 10:49:34 -0700
Message-ID: <AANLkTimhsQdLV7UeMppz8mwzQPUfDQbvdNdOCiVnxdKM@mail.gmail.com>
Subject: Re: [PATCH 3/3] writeback: tracking subsystems causing writeback
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, akpm@linux-foundation.org, david@fromorbit.com, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

Thanks for looking at this.

On Sat, Jun 19, 2010 at 1:17 AM, Andi Kleen <andi@firstfloor.org> wrote:
> Michael Rubin <mrubin@google.com> writes:
>> =A0 =A0 # cat /sys/block/sda/bdi/writeback_stats
>> =A0 =A0 balance dirty pages =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
0
>> =A0 =A0 balance dirty pages waiting =A0 =A0 =A0 =A0 =A0 =A0 =A0 0
>> =A0 =A0 periodic writeback =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A092024
>> =A0 =A0 periodic writeback exited =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0
>> =A0 =A0 laptop periodic =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 0
>> =A0 =A0 laptop or bg threshold =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00
>> =A0 =A0 free more memory =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A00
>> =A0 =A0 try to free pages =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 27=
1
>> =A0 =A0 syc_sync =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A06
>> =A0 =A0 sync filesystem =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 0
>
> That exports a lot of kernel internals in /sys, presumably read by some
> applications. What happens with the applications if the kernel internals
> ever change? =A0Will the application break?
>
> It would be bad to not be able to change the kernel because of
> such an interface.

I agree. This would put the kernel in a box a bit. Some of them
(sys_sync, periodic writeback, free_more_memory) I feel are generic
enough concepts that with some rewording of the labels they could be
exposed with no issue. "Balance_dirty_pages" is an example where that
won't work.

Are there alternatives to this? Maybe tracepoints that are compiled to be o=
n?
A CONFIG_WRITEBACK_DEBUG that would expose this file?

Having this set of info readily available and collected makes
debugging a lot easier. But I admit I am not sure the best way to
expose them.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
