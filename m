Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6B9526B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 07:56:16 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id p41-v6so6182972oth.5
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 04:56:16 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l74-v6sor8558261oih.1.2018.06.07.04.56.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Jun 2018 04:56:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <cd26794b-cb82-919c-053d-9bcb6e3d78d8@redhat.com>
References: <20180606122731.GB27707@jra-laptop.brq.redhat.com>
 <20180607110713.GJ32433@dhcp22.suse.cz> <cd26794b-cb82-919c-053d-9bcb6e3d78d8@redhat.com>
From: Jirka Hladky <jhladky@redhat.com>
Date: Thu, 7 Jun 2018 13:56:14 +0200
Message-ID: <CAE4VaGDtRGDPc7DL2qKMwgsVBrt=_pzXcFTk4DG4yjEHuRdiSg@mail.gmail.com>
Subject: Re: [4.17 regression] Performance drop on kernel-4.17 visible on
 Stream, Linpack and NAS parallel benchmarks
Content-Type: multipart/alternative; boundary="0000000000006f99b7056e0bf892"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SmFrdWIgUmHEjWVr?= <jracek@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, linux-acpi@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, "jhladky@redhat.com" <jhladky@redhat.com>

--0000000000006f99b7056e0bf892
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Adding myself to Cc.

On Thu, Jun 7, 2018 at 1:19 PM, Jakub Ra=C4=8Dek <jracek@redhat.com> wrote:

> Hi,
>
> On 06/07/2018 01:07 PM, Michal Hocko wrote:
>
>> [CCing Mel and MM mailing list]
>>
>> On Wed 06-06-18 14:27:32, Jakub Racek wrote:
>>
>>> Hi,
>>>
>>> There is a huge performance regression on the 2 and 4 NUMA node systems
>>> on
>>> stream benchmark with 4.17 kernel compared to 4.16 kernel. Stream,
>>> Linpack
>>> and NAS parallel benchmarks show upto 50% performance drop.
>>>
>>> When running for example 20 stream processes in parallel, we see the
>>> following behavior:
>>>
>>> * all processes are started at NODE #1
>>> * memory is also allocated on NODE #1
>>> * roughly half of the processes are moved to the NODE #0 very quickly. =
*
>>> however, memory is not moved to NODE #0 and stays allocated on NODE #1
>>>
>>> As the result, half of the processes are running on NODE#0 with memory
>>> being
>>> still allocated on NODE#1. This leads to non-local memory accesses
>>> on the high Remote-To-Local Memory Access Ratio on the numatop charts.
>>>
>>> So it seems that 4.17 is not doing a good job to move the memory to the
>>> right NUMA
>>> node after the process has been moved.
>>>
>>> ----8<----
>>>
>>> The above is an excerpt from performance testing on 4.16 and 4.17
>>> kernels.
>>>
>>> For now I'm merely making sure the problem is reported.
>>>
>>
>> Do you have numa balancing enabled?
>>
>>
> Yes. The relevant settings are:
>
> kernel.numa_balancing =3D 1
> kernel.numa_balancing_scan_delay_ms =3D 1000
> kernel.numa_balancing_scan_period_max_ms =3D 60000
> kernel.numa_balancing_scan_period_min_ms =3D 1000
> kernel.numa_balancing_scan_size_mb =3D 256
>
>
> --
> Best regards,
> Jakub Racek
> FMK
>

--0000000000006f99b7056e0bf892
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Adding myself to Cc.</div><div class=3D"gmail_extra"><br><=
div class=3D"gmail_quote">On Thu, Jun 7, 2018 at 1:19 PM, Jakub Ra=C4=8Dek =
<span dir=3D"ltr">&lt;<a href=3D"mailto:jracek@redhat.com" target=3D"_blank=
">jracek@redhat.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quo=
te" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"=
>Hi,<span class=3D""><br>
<br>
On 06/07/2018 01:07 PM, Michal Hocko wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
[CCing Mel and MM mailing list]<br>
<br>
On Wed 06-06-18 14:27:32, Jakub Racek wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
Hi,<br>
<br>
There is a huge performance regression on the 2 and 4 NUMA node systems on<=
br>
stream benchmark with 4.17 kernel compared to 4.16 kernel. Stream, Linpack<=
br>
and NAS parallel benchmarks show upto 50% performance drop.<br>
<br>
When running for example 20 stream processes in parallel, we see the follow=
ing behavior:<br>
<br>
* all processes are started at NODE #1<br>
* memory is also allocated on NODE #1<br>
* roughly half of the processes are moved to the NODE #0 very quickly. *<br=
>
however, memory is not moved to NODE #0 and stays allocated on NODE #1<br>
<br>
As the result, half of the processes are running on NODE#0 with memory bein=
g<br>
still allocated on NODE#1. This leads to non-local memory accesses<br>
on the high Remote-To-Local Memory Access Ratio on the numatop charts.<br>
<br>
So it seems that 4.17 is not doing a good job to move the memory to the rig=
ht NUMA<br>
node after the process has been moved.<br>
<br>
----8&lt;----<br>
<br>
The above is an excerpt from performance testing on 4.16 and 4.17 kernels.<=
br>
<br>
For now I&#39;m merely making sure the problem is reported.<br>
</blockquote>
<br>
Do you have numa balancing enabled?<br>
<br>
</blockquote>
<br></span>
Yes. The relevant settings are:<br>
<br>
kernel.numa_balancing =3D 1<br>
kernel.numa_balancing_scan_del<wbr>ay_ms =3D 1000<br>
kernel.numa_balancing_scan_per<wbr>iod_max_ms =3D 60000<br>
kernel.numa_balancing_scan_per<wbr>iod_min_ms =3D 1000<br>
kernel.numa_balancing_scan_siz<wbr>e_mb =3D 256<span class=3D"HOEnZb"><font=
 color=3D"#888888"><br>
<br>
<br>
-- <br>
Best regards,<br>
Jakub Racek<br>
FMK<br>
</font></span></blockquote></div><br></div>

--0000000000006f99b7056e0bf892--
