Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id DE3F86B0037
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 04:11:20 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so11621062pac.3
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 01:11:20 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1lp0140.outbound.protection.outlook.com. [207.46.163.140])
        by mx.google.com with ESMTPS id bv5si8453607pdb.201.2014.07.22.01.11.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 Jul 2014 01:11:19 -0700 (PDT)
Message-ID: <53CE1C92.2070200@amd.com>
Date: Tue, 22 Jul 2014 11:10:58 +0300
From: Oded Gabbay <oded.gabbay@amd.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
References: <20140720174652.GE3068@gmail.com> <53CD0961.4070505@amd.com>
 <53CD17FD.3000908@vodafone.de> <53CD1FB6.1000602@amd.com>
 <20140721155437.GA4519@gmail.com> <53CD5122.5040804@amd.com>
 <20140721181433.GA5196@gmail.com> <53CD5DBC.7010301@amd.com>
 <20140721185940.GA5278@gmail.com> <53CD68BF.4020308@amd.com>
 <20140722072337.GG15237@phenom.ffwll.local>
In-Reply-To: <20140722072337.GG15237@phenom.ffwll.local>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>, Andrew Lewycky <Andrew.Lewycky@amd.com>, =?ISO-8859-1?Q?Michel_D=E4nzer?= <michel.daenzer@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>, Alexey
 Skidanov <Alexey.Skidanov@amd.com>, Andrew Morton <akpm@linux-foundation.org>, "Bridgman, John" <John.Bridgman@amd.com>, Dave
 Airlie <airlied@redhat.com>, =?ISO-8859-1?Q?Christian_K=F6nig?= <christian.koenig@amd.com>, Joerg Roedel <joro@8bytes.org>, Daniel Vetter <daniel@ffwll.ch>, "Sellek, Tom" <Tom.Sellek@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>

On 22/07/14 10:23, Daniel Vetter wrote:
> On Mon, Jul 21, 2014 at 10:23:43PM +0300, Oded Gabbay wrote:
>> But Jerome, the core problem still remains in effect, even with your
>> suggestion. If an application, either via userspace queue or via ioctl,
>> submits a long-running kernel, than the CPU in general can't stop the
>> GPU from running it. And if that kernel does while(1); than that's it,
>> game's over, and no matter how you submitted the work. So I don't really
>> see the big advantage in your proposal. Only in CZ we can stop this wave
>> (by CP H/W scheduling only). What are you saying is basically I won't
>> allow people to use compute on Linux KV system because it _may_ get the
>> system stuck.
>>
>> So even if I really wanted to, and I may agree with you theoretically on
>> that, I can't fulfill your desire to make the "kernel being able to
>> preempt at any time and be able to decrease or increase user queue
>> priority so overall kernel is in charge of resources management and it
>> can handle rogue client in proper fashion". Not in KV, and I guess not
>> in CZ as well.
>
> At least on intel the execlist stuff which is used for preemption can be
> used by both the cpu and the firmware scheduler. So we can actually
> preempt when doing cpu scheduling.
>
> It sounds like current amd hw doesn't have any preemption at all. And
> without preemption I don't think we should ever consider to allow
> userspace to directly submit stuff to the hw and overload. Imo the kernel
> _must_ sit in between and reject clients that don't behave. Of course you
> can only ever react (worst case with a gpu reset, there's code floating
> around for that on intel-gfx), but at least you can do something.
>
> If userspace has a direct submit path to the hw then this gets really
> tricky, if not impossible.
> -Daniel
>

Hi Daniel,
See the email I just sent to Jerome regarding preemption. Bottom line, in KV, we 
can preempt running queues, except from the case of a stuck gpu kernel. In CZ, 
this was solved.

So, in this regard, I don't think there is any difference between userspace 
queues and ioctl.

	Oded

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
