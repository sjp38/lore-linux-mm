Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id A889D6B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 06:04:41 -0400 (EDT)
Received: by mail-qc0-f178.google.com with SMTP id i8so5107958qcq.37
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 03:04:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v10si16594602qat.93.2014.04.22.03.04.40
        for <linux-mm@kvack.org>;
        Tue, 22 Apr 2014 03:04:41 -0700 (PDT)
Message-ID: <535631EB.4060906@redhat.com>
Date: Tue, 22 Apr 2014 11:10:03 +0200
From: Florian Weimer <fweimer@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>	<5343F2EC.3050508@redhat.com> <CANq1E4TmtR=gSgR25PGC_EN=xrEEg1+F=zkTUGXZ4SHvjFNbag@mail.gmail.com>
In-Reply-To: <CANq1E4TmtR=gSgR25PGC_EN=xrEEg1+F=zkTUGXZ4SHvjFNbag@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On 04/09/2014 11:31 PM, David Herrmann wrote:

> On Tue, Apr 8, 2014 at 3:00 PM, Florian Weimer <fweimer@redhat.com> wrote:
>> How do you keep these promises on network and FUSE file systems?
>
> I don't. This is shmem only.

Ah.  What do you recommend for recipient to recognize such descriptors? 
  Would they just try to seal them and reject them if this fails?

-- 
Florian Weimer / Red Hat Product Security Team

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
