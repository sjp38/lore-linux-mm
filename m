Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0FC946B003B
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 14:22:25 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id r2so3363286igi.4
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 11:22:24 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id m11si47716500icl.74.2014.07.21.11.22.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 11:22:23 -0700 (PDT)
Received: by mail-ig0-f177.google.com with SMTP id hn18so3122048igb.4
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 11:22:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53CD4DD2.10906@amd.com>
References: <53C7D645.3070607@amd.com>
	<20140720174652.GE3068@gmail.com>
	<53CD0961.4070505@amd.com>
	<53CD17FD.3000908@vodafone.de>
	<20140721152511.GW15237@phenom.ffwll.local>
	<20140721155851.GB4519@gmail.com>
	<20140721170546.GB15237@phenom.ffwll.local>
	<53CD4DD2.10906@amd.com>
Date: Mon, 21 Jul 2014 20:22:23 +0200
Message-ID: <CAKMK7uFhvGtxj_d6X=4OBdVSm6cT1-Z-DiTE-FTWMnFjY2uqMQ@mail.gmail.com>
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
From: Daniel Vetter <daniel@ffwll.ch>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oded Gabbay <oded.gabbay@amd.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, =?UTF-8?Q?Christian_K=C3=B6nig?= <deathsimple@vodafone.de>, David Airlie <airlied@linux.ie>, Alex Deucher <alexdeucher@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, John Bridgman <John.Bridgman@amd.com>, Joerg Roedel <joro@8bytes.org>, Andrew Lewycky <Andrew.Lewycky@amd.com>, =?UTF-8?Q?Michel_D=C3=A4nzer?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, Evgeny Pinchuk <Evgeny.Pinchuk@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>

On Mon, Jul 21, 2014 at 7:28 PM, Oded Gabbay <oded.gabbay@amd.com> wrote:
>> I'm not sure whether we can do the same trick with the hw scheduler. But
>> then unpinning hw contexts will drain the pipeline anyway, so I guess we
>> can just stop feeding the hw scheduler until it runs dry. And then unpin
>> and evict.
> So, I'm afraid but we can't do this for AMD Kaveri because:

Well as long as you can drain the hw scheduler queue (and you can do
that, worst case you have to unmap all the doorbells and other stuff
to intercept further submission from userspace) you can evict stuff.
And if we don't want compute to be a denial of service on the display
side of the driver we need this ability. Now if you go through an
ioctl instead of the doorbell (I agree with Jerome here, the doorbell
should be supported by benchmarks on linux) this gets a bit easier,
but it's not a requirement really.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
