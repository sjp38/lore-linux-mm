Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 011F08E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 15:59:02 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id p4so16420215iod.17
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 12:59:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h2sor6336706ith.32.2018.12.18.12.59.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Dec 2018 12:59:02 -0800 (PST)
MIME-Version: 1.0
References: <CABXGCsOyHuNpPNMnU0rbMwfGkFA2ooAbkCkyRqC0D-S3ygu-hA@mail.gmail.com>
 <20181217153623.GT30879@dhcp22.suse.cz>
In-Reply-To: <20181217153623.GT30879@dhcp22.suse.cz>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Wed, 19 Dec 2018 01:58:50 +0500
Message-ID: <CABXGCsNX2akjZqR6CY93=mvEMM7EJKuqHxuCCOQBzKoqk2mbjw@mail.gmail.com>
Subject: Re: [4.20.0-0.rc6] kernel BUG at include/linux/mm.h:990!
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

On Mon, 17 Dec 2018 at 20:36, Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 17-12-18 02:50:31, Mikhail Gavrilov wrote:
> > Hi guys.
> >
> > Today I discovered that `# inxi  --debug 22` causes kernel BUG at
> > include/linux/mm.h:990
>
> Does [1] fix your problem?
>
> [1] http://lkml.kernel.org/r/20181212172712.34019-2-zaslonko@linux.ibm.com
> --
> Michal Hocko
> SUSE Labs

Michal thanks,
I tested patch and I can confirm that it fixing described issue.

Any chance that it would be merged in 4.20?

--
Best Regards,
Mike Gavrilov.
