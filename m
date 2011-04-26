Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B7DC6900001
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 02:07:20 -0400 (EDT)
Received: by wwi36 with SMTP id 36so232983wwi.26
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 23:07:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTik8k9A8N8CPk+eXo9c_syxJFRyFCA@mail.gmail.com>
References: <BANLkTin8mE=DLWma=U+CdJaQW03X2M2W1w@mail.gmail.com>
	<20110426055521.GA18473@localhost>
	<BANLkTik8k9A8N8CPk+eXo9c_syxJFRyFCA@mail.gmail.com>
Date: Tue, 26 Apr 2011 14:07:17 +0800
Message-ID: <BANLkTim0MNgqeh1KTfvpVFuAvebKyQV8Hg@mail.gmail.com>
Subject: Re: readahead and oom
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Apr 26, 2011 at 2:05 PM, Dave Young <hidave.darkstar@gmail.com> wro=
te:
> On Tue, Apr 26, 2011 at 1:55 PM, Wu Fengguang <fengguang.wu@intel.com> wr=
ote:
>> On Tue, Apr 26, 2011 at 01:49:25PM +0800, Dave Young wrote:
>>> Hi,
>>>
>>> When memory pressure is high, readahead could cause oom killing.
>>> IMHO we should stop readaheading under such circumstances=E3=80=82If it=
's true
>>> how to fix it?
>>
>> Good question. Before OOM there will be readahead thrashings, which
>> can be addressed by this patch:
>>
>> http://lkml.org/lkml/2010/2/2/229
>
> Hi, I'm not clear about the patch, could be regard as below cases?
> 1) readahead alloc fail due to low memory such as other large allocation

For example vm balloon allocate lots of memory, then readahead could
fail immediately and then oom

> 2) readahead thrashing caused by itself
>
>>
>> However there seems no much interest on that feature.. I can separate
>> that out and resubmit it standalone if necessary.
>>
>> Thanks,
>> Fengguang
>>
>
>
>
> --
> Regards
> dave
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
