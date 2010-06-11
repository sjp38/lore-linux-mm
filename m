Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DB4056B0071
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 20:34:26 -0400 (EDT)
Received: by iwn1 with SMTP id 1so128803iwn.14
        for <linux-mm@kvack.org>; Thu, 10 Jun 2010 17:34:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1006101326440.20197@chino.kir.corp.google.com>
References: <AANLkTik6xP9vVEyW4QG-4RfZu-iEuHcl2pBV_-mfHP4y@mail.gmail.com>
	<alpine.DEB.2.00.1006101326440.20197@chino.kir.corp.google.com>
Date: Fri, 11 Jun 2010 08:34:21 +0800
Message-ID: <AANLkTinTm1kc1n_GS-nk6t46j1_ia8a8i0H7bHWlmVba@mail.gmail.com>
Subject: Re: oom killer and long-waiting processes
From: Ryan Wang <openspace.wang@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: rientjes@google.com, mulyadi.santosa@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

2010/6/11 David Rientjes <rientjes@google.com>:
> On Thu, 10 Jun 2010, Ryan Wang wrote:
>
>> Hi all,
>>
>> =A0 =A0 =A0 =A0 I have one question about oom killer:
>> If many processes dealing with network communications,
>> but due to bad network traffic, the processes have to wait
>> for a very long time. And meanwhile they may consume
>> some memeory separately for computation. The number
>> of such processes may be large.
>>
>> =A0 =A0 =A0 =A0 I wonder whether oom killer will kill these processes
>> when the system is under high pressure?
>>
>
> The kernel can deal with "high pressure" quite well, but in some cases
> such as when all of your RAM or your memory controller is filled with
> anonymous memory and cannot be reclaimed, the oom killer may be called to
> kill "something". =A0It prefers to kill something that will free a large
> amount of memory to avoid having to subsequently kill additional tasks
> when it kills something small first.
>
> If there are tasks that you'd either like to protect from the oom killer
> or always prefer in oom conditions, you can influence its decision-making
> from userspace by tuning /proc/<pid>/oom_adj of the task in question.
> Users typically set an oom_adj value of "-17" to completely disable oom
> killing of pid (the kernel will even panic if it can't find anything
> killable as a result of this!), a value of "-16" to prefer that pid gets
> killed last, and a value of "15" to always prefer pid gets killed first.
>
> Lowering a /proc/<pid>/oom_adj value for a pid from its current value (it
> inherits its value from the parent, which is usually 0) is only allowed b=
y
> root, more specifically, it may only be done by the CAP_SYS_RESOURCE
> capability.
>
> You can refer to Documentation/filesystems/proc.txt for information on
> oom_adj.
>

Thanks all!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
