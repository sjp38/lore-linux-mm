Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 025786B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 08:44:30 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id dc16so932401qab.35
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 05:44:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x7si16788202qaj.94.2014.04.22.05.44.29
        for <linux-mm@kvack.org>;
        Tue, 22 Apr 2014 05:44:30 -0700 (PDT)
Message-ID: <53566428.9080005@redhat.com>
Date: Tue, 22 Apr 2014 14:44:24 +0200
From: Florian Weimer <fweimer@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>	<5343F2EC.3050508@redhat.com>	<CANq1E4TmtR=gSgR25PGC_EN=xrEEg1+F=zkTUGXZ4SHvjFNbag@mail.gmail.com>	<535631EB.4060906@redhat.com> <CANq1E4TufnELwEDZAkzH94Zn3gb46qvxfDboN5y2mK=Q2gk9-Q@mail.gmail.com>
In-Reply-To: <CANq1E4TufnELwEDZAkzH94Zn3gb46qvxfDboN5y2mK=Q2gk9-Q@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On 04/22/2014 01:55 PM, David Herrmann wrote:
> Hi
>
> On Tue, Apr 22, 2014 at 11:10 AM, Florian Weimer <fweimer@redhat.com> wrote:
>> Ah.  What do you recommend for recipient to recognize such descriptors?
>> Would they just try to seal them and reject them if this fails?
>
> This highly depends on your use-case. Please see the initial email in
> this thread. It describes 2 example use-cases. In both cases, the
> recipients read the current set of seals and verify that a given set
> of seals is set.

I didn't find that very convincing.  But in v2, seals are monotonic, so 
checking them should be reliable enough.

What happens when you create a loop device on a write-sealed descriptor?

-- 
Florian Weimer / Red Hat Product Security Team

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
