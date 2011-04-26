Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A7DAB900001
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 02:51:12 -0400 (EDT)
Received: by wyf19 with SMTP id 19so271768wyf.14
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 23:51:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110426061353.GA19717@localhost>
References: <BANLkTin8mE=DLWma=U+CdJaQW03X2M2W1w@mail.gmail.com>
	<20110426055521.GA18473@localhost>
	<BANLkTik8k9A8N8CPk+eXo9c_syxJFRyFCA@mail.gmail.com>
	<20110426061353.GA19717@localhost>
Date: Tue, 26 Apr 2011 14:23:08 +0800
Message-ID: <BANLkTi=JoSwpNk0xW4PSYBhuNa1Q1G9LMw@mail.gmail.com>
Subject: Re: readahead and oom
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Apr 26, 2011 at 2:13 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> On Tue, Apr 26, 2011 at 02:05:12PM +0800, Dave Young wrote:
>> On Tue, Apr 26, 2011 at 1:55 PM, Wu Fengguang <fengguang.wu@intel.com> w=
rote:
>> > On Tue, Apr 26, 2011 at 01:49:25PM +0800, Dave Young wrote:
>> >> Hi,
>> >>
>> >> When memory pressure is high, readahead could cause oom killing.
>> >> IMHO we should stop readaheading under such circumstances=E3=80=82If =
it's true
>> >> how to fix it?
>> >
>> > Good question. Before OOM there will be readahead thrashings, which
>> > can be addressed by this patch:
>> >
>> > http://lkml.org/lkml/2010/2/2/229
>>
>> Hi, I'm not clear about the patch, could be regard as below cases?
>> 1) readahead alloc fail due to low memory such as other large allocation
>> 2) readahead thrashing caused by itself
>
> When memory pressure goes up (not as much as allocation failures and OOM)=
,
> the readahead pages may be reclaimed before they are read() accessed
> by the user space. At the time read() asks for the page, it will have
> to be read from disk _again_. This is called readahead thrashing.
>
> What the patch does is to automatically detect readahead thrashing and
> shrink the readahead size adaptively, which will the reduce memory
> consumption by readahead buffers.

Thanks for the explanation.

But still there's the question, if the allocation storm occurs when
system startup, the allocation is so quick that the detection of
thrashing is too late to avoid readahead. Is this possible?

>
> Thanks,
> Fengguang
>
>> >
>> > However there seems no much interest on that feature.. I can separate
>> > that out and resubmit it standalone if necessary.

Would like to test your new patch

>> >
>> > Thanks,
>> > Fengguang
>> >
>>
>>
>>
>> --
>> Regards
>> dave
>



--=20
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
