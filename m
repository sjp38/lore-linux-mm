Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id B26F06B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 08:55:38 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id lx4so5149160iec.37
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 05:55:38 -0700 (PDT)
Received: from mail-ie0-x22f.google.com (mail-ie0-x22f.google.com [2607:f8b0:4001:c03::22f])
        by mx.google.com with ESMTPS id bs7si24970713icc.145.2014.04.22.05.55.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 05:55:38 -0700 (PDT)
Received: by mail-ie0-f175.google.com with SMTP id to1so5125322ieb.20
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 05:55:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53566428.9080005@redhat.com>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
	<5343F2EC.3050508@redhat.com>
	<CANq1E4TmtR=gSgR25PGC_EN=xrEEg1+F=zkTUGXZ4SHvjFNbag@mail.gmail.com>
	<535631EB.4060906@redhat.com>
	<CANq1E4TufnELwEDZAkzH94Zn3gb46qvxfDboN5y2mK=Q2gk9-Q@mail.gmail.com>
	<53566428.9080005@redhat.com>
Date: Tue, 22 Apr 2014 14:55:37 +0200
Message-ID: <CANq1E4QBTSrzk9M8N_YUmWdj44Y-vO5cXYh+ibXbJ++g=6vh5A@mail.gmail.com>
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

Hi

On Tue, Apr 22, 2014 at 2:44 PM, Florian Weimer <fweimer@redhat.com> wrote:
> I didn't find that very convincing.  But in v2, seals are monotonic, so
> checking them should be reliable enough.

Ok.

> What happens when you create a loop device on a write-sealed descriptor?

Any write-back to the loop-device will fail with EPERM as soon as the
fd gets write-sealed. See __do_lo_send_write() in
drivers/block/loop.c. It's up to the loop-device to forward the error
via bio_endio() to the caller for proper error-handling.

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
