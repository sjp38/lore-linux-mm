Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id A18C66B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 11:06:43 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so1792742pdj.0
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 08:06:43 -0700 (PDT)
Received: from na01-by2-obe.outbound.protection.outlook.com (mail-by2lp0244.outbound.protection.outlook.com. [207.46.163.244])
        by mx.google.com with ESMTPS id km1si2872961pbd.1.2014.07.23.08.06.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 23 Jul 2014 08:06:42 -0700 (PDT)
From: "Bridgman, John" <John.Bridgman@amd.com>
Subject: RE: [PATCH v2 00/25] AMDKFD kernel driver
Date: Wed, 23 Jul 2014 15:06:36 +0000
Message-ID: <D89D60253BB73A4E8C62F9FD18A939CA01066D77@storexdag02.amd.com>
References: <53CD5ED9.2040600@amd.com> <20140721190306.GB5278@gmail.com>
 <20140722072851.GH15237@phenom.ffwll.local> <53CE1E9C.8020105@amd.com>
 <CAKMK7uH+okhn4YGOzrXZ1LM3S2myxdu=_63LGMduwV-WZn06CA@mail.gmail.com>
 <53CE346B.1080601@amd.com> <20140722111515.GJ15237@phenom.ffwll.local>
 <53CF5B30.50209@amd.com>
 <CAKMK7uFtSStEewVivbXAT1VC4t2Y+suTaEmQA4=UptK1UBLSmg@mail.gmail.com>
 <D89D60253BB73A4E8C62F9FD18A939CA01066B1B@storexdag02.amd.com>
 <20140723144130.GV15237@phenom.ffwll.local>
In-Reply-To: <20140723144130.GV15237@phenom.ffwll.local>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, Jerome Glisse <j.glisse@gmail.com>, =?iso-8859-1?Q?Christian_K=F6nig?= <deathsimple@vodafone.de>, David Airlie <airlied@linux.ie>, Alex Deucher <alexdeucher@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joerg Roedel <joro@8bytes.org>, "Lewycky,
 Andrew" <Andrew.Lewycky@amd.com>, "Daenzer, Michel" <Michel.Daenzer@amd.com>, "Goz, Ben" <Ben.Goz@amd.com>, "Skidanov, Alexey" <Alexey.Skidanov@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>, "Sellek, Tom" <Tom.Sellek@amd.com>



>-----Original Message-----
>From: Daniel Vetter [mailto:daniel.vetter@ffwll.ch] On Behalf Of Daniel
>Vetter
>Sent: Wednesday, July 23, 2014 10:42 AM
>To: Bridgman, John
>Cc: Daniel Vetter; Gabbay, Oded; Jerome Glisse; Christian K=F6nig; David A=
irlie;
>Alex Deucher; Andrew Morton; Joerg Roedel; Lewycky, Andrew; Daenzer,
>Michel; Goz, Ben; Skidanov, Alexey; linux-kernel@vger.kernel.org; dri-
>devel@lists.freedesktop.org; linux-mm; Sellek, Tom
>Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
>
>On Wed, Jul 23, 2014 at 01:33:24PM +0000, Bridgman, John wrote:
>>
>>
>> >-----Original Message-----
>> >From: Daniel Vetter [mailto:daniel.vetter@ffwll.ch]
>> >Sent: Wednesday, July 23, 2014 3:06 AM
>> >To: Gabbay, Oded
>> >Cc: Jerome Glisse; Christian K=F6nig; David Airlie; Alex Deucher;
>> >Andrew Morton; Bridgman, John; Joerg Roedel; Lewycky, Andrew;
>> >Daenzer, Michel; Goz, Ben; Skidanov, Alexey;
>> >linux-kernel@vger.kernel.org; dri- devel@lists.freedesktop.org;
>> >linux-mm; Sellek, Tom
>> >Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
>> >
>> >On Wed, Jul 23, 2014 at 8:50 AM, Oded Gabbay <oded.gabbay@amd.com>
>> >wrote:
>> >> On 22/07/14 14:15, Daniel Vetter wrote:
>> >>>
>> >>> On Tue, Jul 22, 2014 at 12:52:43PM +0300, Oded Gabbay wrote:
>> >>>>
>> >>>> On 22/07/14 12:21, Daniel Vetter wrote:
>> >>>>>
>> >>>>> On Tue, Jul 22, 2014 at 10:19 AM, Oded Gabbay
>> ><oded.gabbay@amd.com>
>> >>>>> wrote:
>> >>>>>>>
>> >>>>>>> Exactly, just prevent userspace from submitting more. And if
>> >>>>>>> you have misbehaving userspace that submits too much, reset
>> >>>>>>> the gpu and tell it that you're sorry but won't schedule any mor=
e
>work.
>> >>>>>>
>> >>>>>>
>> >>>>>> I'm not sure how you intend to know if a userspace misbehaves or
>not.
>> >>>>>> Can
>> >>>>>> you elaborate ?
>> >>>>>
>> >>>>>
>> >>>>> Well that's mostly policy, currently in i915 we only have a
>> >>>>> check for hangs, and if userspace hangs a bit too often then we st=
op
>it.
>> >>>>> I guess you can do that with the queue unmapping you've describe
>> >>>>> in reply to Jerome's mail.
>> >>>>> -Daniel
>> >>>>>
>> >>>> What do you mean by hang ? Like the tdr mechanism in Windows
>> >>>> (checks if a gpu job takes more than 2 seconds, I think, and if
>> >>>> so, terminates the job).
>> >>>
>> >>>
>> >>> Essentially yes. But we also have some hw features to kill jobs
>> >>> quicker, e.g. for media workloads.
>> >>> -Daniel
>> >>>
>> >>
>> >> Yeah, so this is what I'm talking about when I say that you and
>> >> Jerome come from a graphics POV and amdkfd come from a compute
>POV,
>> >> no
>> >offense intended.
>> >>
>> >> For compute jobs, we simply can't use this logic to terminate jobs.
>> >> Graphics are mostly Real-Time while compute jobs can take from a
>> >> few ms to a few hours!!! And I'm not talking about an entire
>> >> application runtime but on a single submission of jobs by the
>> >> userspace app. We have tests with jobs that take between 20-30
>> >> minutes to complete. In theory, we can even imagine a compute job
>> >> which takes 1 or 2 days (on
>> >larger APUs).
>> >>
>> >> Now, I understand the question of how do we prevent the compute job
>> >> from monopolizing the GPU, and internally here we have some ideas
>> >> that we will probably share in the next few days, but my point is
>> >> that I don't think we can terminate a compute job because it is
>> >> running for more
>> >than x seconds.
>> >> It is like you would terminate a CPU process which runs more than x
>> >seconds.
>> >>
>> >> I think this is a *very* important discussion (detecting a
>> >> misbehaved compute process) and I would like to continue it, but I
>> >> don't think moving the job submission from userspace control to
>> >> kernel control will solve this core problem.
>> >
>> >Well graphics gets away with cooperative scheduling since usually
>> >people want to see stuff within a few frames, so we can legitimately
>> >kill jobs after a fairly short timeout. Imo if you want to allow
>> >userspace to submit compute jobs that are atomic and take a few
>> >minutes to hours with no break-up in between and no hw means to
>> >preempt then that design is screwed up. We really can't tell the core
>> >vm that "sorry we will hold onto these gobloads of memory you really
>> >need now for another few hours". Pinning memory like that essentially
>without a time limit is restricted to root.
>>
>> Hi Daniel;
>>
>> I don't really understand the reference to "gobloads of memory".
>> Unlike radeon graphics, the userspace data for HSA applications is
>> maintained in pageable system memory and accessed via the IOMMUv2
>> (ATC/PRI). The
>> IOMMUv2 driver and mm subsystem takes care of faulting in memory pages
>> as needed, nothing is long-term pinned.
>
>Yeah I've lost that part of the equation a bit since I've always thought t=
hat
>proper faulting support without preemption is not really possible. I guess
>those platforms completely stall on a fault until the ptes are all set up?

Correct. The GPU thread accessing the faulted page definitely stalls but pr=
ocessing can continue on other GPU threads.=20

I don't remember offhand how much of the GPU=3D>ATC=3D>IOMMUv2=3D>system RA=
M path gets stalled (ie whether other HSA apps get blocked) but AFAIK graph=
ics processing (assuming it is not using ATC path to system memory) is not =
affected. I will double-check that though, haven't asked internally for a c=
ouple of years but I do remember concluding something along the lines of "O=
K, that'll do" ;)
=20
>-Daniel
>--
>Daniel Vetter
>Software Engineer, Intel Corporation
>+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
