Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 175258E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 01:52:14 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id f31so12092225edf.17
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 22:52:14 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s37si71121edb.340.2018.12.18.22.52.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 22:52:12 -0800 (PST)
Date: Wed, 19 Dec 2018 07:52:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [4.20.0-0.rc6] kernel BUG at include/linux/mm.h:990!
Message-ID: <20181219065210.GB10480@dhcp22.suse.cz>
References: <CABXGCsOyHuNpPNMnU0rbMwfGkFA2ooAbkCkyRqC0D-S3ygu-hA@mail.gmail.com>
 <20181217153623.GT30879@dhcp22.suse.cz>
 <CABXGCsNX2akjZqR6CY93=mvEMM7EJKuqHxuCCOQBzKoqk2mbjw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABXGCsNX2akjZqR6CY93=mvEMM7EJKuqHxuCCOQBzKoqk2mbjw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

On Wed 19-12-18 01:58:50, Mikhail Gavrilov wrote:
> On Mon, 17 Dec 2018 at 20:36, Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Mon 17-12-18 02:50:31, Mikhail Gavrilov wrote:
> > > Hi guys.
> > >
> > > Today I discovered that `# inxi  --debug 22` causes kernel BUG at
> > > include/linux/mm.h:990
> >
> > Does [1] fix your problem?
> >
> > [1] http://lkml.kernel.org/r/20181212172712.34019-2-zaslonko@linux.ibm.com
> > --
> > Michal Hocko
> > SUSE Labs
> 
> Michal thanks,
> I tested patch and I can confirm that it fixing described issue.

Cool! Can we assume?
Tested-by: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
 
> Any chance that it would be merged in 4.20?

It is sitting in the mmotm tree. Andrew do you plan to push it to 4.20?
It seems there are more users suffering from this issue.
-- 
Michal Hocko
SUSE Labs
