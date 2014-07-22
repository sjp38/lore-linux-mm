Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0A9D46B0044
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 05:53:03 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so11744588pab.33
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 02:53:03 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1blp0190.outbound.protection.outlook.com. [207.46.163.190])
        by mx.google.com with ESMTPS id qc2si8593210pdb.178.2014.07.22.02.53.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 Jul 2014 02:53:01 -0700 (PDT)
Message-ID: <53CE346B.1080601@amd.com>
Date: Tue, 22 Jul 2014 12:52:43 +0300
From: Oded Gabbay <oded.gabbay@amd.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
References: <20140720174652.GE3068@gmail.com>	<53CD0961.4070505@amd.com>
	<53CD17FD.3000908@vodafone.de>	<20140721152511.GW15237@phenom.ffwll.local>
	<20140721155851.GB4519@gmail.com>	<20140721170546.GB15237@phenom.ffwll.local>
	<53CD4DD2.10906@amd.com>
	<CAKMK7uFhvGtxj_d6X=4OBdVSm6cT1-Z-DiTE-FTWMnFjY2uqMQ@mail.gmail.com>
	<53CD5ED9.2040600@amd.com>	<20140721190306.GB5278@gmail.com>
	<20140722072851.GH15237@phenom.ffwll.local>	<53CE1E9C.8020105@amd.com>
 <CAKMK7uH+okhn4YGOzrXZ1LM3S2myxdu=_63LGMduwV-WZn06CA@mail.gmail.com>
In-Reply-To: <CAKMK7uH+okhn4YGOzrXZ1LM3S2myxdu=_63LGMduwV-WZn06CA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Jerome Glisse <j.glisse@gmail.com>, =?UTF-8?B?Q2hyaXN0aWFuIEvDtm5pZw==?= <deathsimple@vodafone.de>, David Airlie <airlied@linux.ie>, Alex Deucher <alexdeucher@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, John
 Bridgman <John.Bridgman@amd.com>, Joerg Roedel <joro@8bytes.org>, Andrew
 Lewycky <Andrew.Lewycky@amd.com>, =?UTF-8?B?TWljaGVsIETDpG56ZXI=?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>, "Sellek,
 Tom" <Tom.Sellek@amd.com>

On 22/07/14 12:21, Daniel Vetter wrote:
> On Tue, Jul 22, 2014 at 10:19 AM, Oded Gabbay <oded.gabbay@amd.com> wrote:
>>> Exactly, just prevent userspace from submitting more. And if you have
>>> misbehaving userspace that submits too much, reset the gpu and tell it
>>> that you're sorry but won't schedule any more work.
>>
>> I'm not sure how you intend to know if a userspace misbehaves or not. Can
>> you elaborate ?
>
> Well that's mostly policy, currently in i915 we only have a check for
> hangs, and if userspace hangs a bit too often then we stop it. I guess
> you can do that with the queue unmapping you've describe in reply to
> Jerome's mail.
> -Daniel
>
What do you mean by hang ? Like the tdr mechanism in Windows (checks if a gpu 
job takes more than 2 seconds, I think, and if so, terminates the job).

	Oded

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
