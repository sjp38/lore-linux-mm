Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B7DE8900001
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 02:11:24 -0400 (EDT)
Received: by wyf19 with SMTP id 19so253189wyf.14
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 23:11:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110426055521.GA18473@localhost>
References: <BANLkTin8mE=DLWma=U+CdJaQW03X2M2W1w@mail.gmail.com>
	<20110426055521.GA18473@localhost>
Date: Tue, 26 Apr 2011 14:05:12 +0800
Message-ID: <BANLkTik8k9A8N8CPk+eXo9c_syxJFRyFCA@mail.gmail.com>
Subject: Re: readahead and oom
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Apr 26, 2011 at 1:55 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> On Tue, Apr 26, 2011 at 01:49:25PM +0800, Dave Young wrote:
>> Hi,
>>
>> When memory pressure is high, readahead could cause oom killing.
>> IMHO we should stop readaheading under such circumstances=E3=80=82If it'=
s true
>> how to fix it?
>
> Good question. Before OOM there will be readahead thrashings, which
> can be addressed by this patch:
>
> http://lkml.org/lkml/2010/2/2/229

Hi, I'm not clear about the patch, could be regard as below cases?
1) readahead alloc fail due to low memory such as other large allocation
2) readahead thrashing caused by itself

>
> However there seems no much interest on that feature.. I can separate
> that out and resubmit it standalone if necessary.
>
> Thanks,
> Fengguang
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
