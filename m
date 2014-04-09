Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 052E86B0036
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 17:31:20 -0400 (EDT)
Received: by mail-ig0-f175.google.com with SMTP id ur14so6998130igb.2
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 14:31:20 -0700 (PDT)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id hl3si2542181icc.71.2014.04.09.14.31.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Apr 2014 14:31:20 -0700 (PDT)
Received: by mail-ie0-f178.google.com with SMTP id lx4so3103317iec.9
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 14:31:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5343F2EC.3050508@redhat.com>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
	<5343F2EC.3050508@redhat.com>
Date: Wed, 9 Apr 2014 23:31:20 +0200
Message-ID: <CANq1E4TmtR=gSgR25PGC_EN=xrEEg1+F=zkTUGXZ4SHvjFNbag@mail.gmail.com>
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

Hi

On Tue, Apr 8, 2014 at 3:00 PM, Florian Weimer <fweimer@redhat.com> wrote:
> How do you keep these promises on network and FUSE file systems?

I don't. This is shmem only.

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
