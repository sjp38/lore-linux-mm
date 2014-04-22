Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 744E16B0038
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 07:55:04 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id c1so2866160igq.7
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 04:55:04 -0700 (PDT)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id bs7si24875559icc.145.2014.04.22.04.55.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 04:55:03 -0700 (PDT)
Received: by mail-ie0-f182.google.com with SMTP id y20so5142441ier.27
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 04:55:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <535631EB.4060906@redhat.com>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
	<5343F2EC.3050508@redhat.com>
	<CANq1E4TmtR=gSgR25PGC_EN=xrEEg1+F=zkTUGXZ4SHvjFNbag@mail.gmail.com>
	<535631EB.4060906@redhat.com>
Date: Tue, 22 Apr 2014 13:55:03 +0200
Message-ID: <CANq1E4TufnELwEDZAkzH94Zn3gb46qvxfDboN5y2mK=Q2gk9-Q@mail.gmail.com>
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

Hi

On Tue, Apr 22, 2014 at 11:10 AM, Florian Weimer <fweimer@redhat.com> wrote:
> Ah.  What do you recommend for recipient to recognize such descriptors?
> Would they just try to seal them and reject them if this fails?

This highly depends on your use-case. Please see the initial email in
this thread. It describes 2 example use-cases. In both cases, the
recipients read the current set of seals and verify that a given set
of seals is set.

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
