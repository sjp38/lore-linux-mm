Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7C46E6B0003
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 10:45:35 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id l32so1148781qtd.19
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 07:45:35 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g5si2941470qkc.463.2018.03.20.07.45.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 07:45:34 -0700 (PDT)
Date: Tue, 20 Mar 2018 10:45:31 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 3/4] mm/hmm: HMM should have a callback before MM is
 destroyed
Message-ID: <20180320144531.GA3716@redhat.com>
References: <20180315183700.3843-1-jglisse@redhat.com>
 <20180315183700.3843-4-jglisse@redhat.com>
 <20180315154829.89054bfd579d03097b0f6457@linux-foundation.org>
 <20180320113326.GJ23100@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180320113326.GJ23100@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

On Tue, Mar 20, 2018 at 12:33:26PM +0100, Michal Hocko wrote:
> On Thu 15-03-18 15:48:29, Andrew Morton wrote:
> > On Thu, 15 Mar 2018 14:36:59 -0400 jglisse@redhat.com wrote:
> > 
> > > From: Ralph Campbell <rcampbell@nvidia.com>
> > > 
> > > The hmm_mirror_register() function registers a callback for when
> > > the CPU pagetable is modified. Normally, the device driver will
> > > call hmm_mirror_unregister() when the process using the device is
> > > finished. However, if the process exits uncleanly, the struct_mm
> > > can be destroyed with no warning to the device driver.
> > 
> > The changelog doesn't tell us what the runtime effects of the bug are. 
> > This makes it hard for me to answer the "did Jerome consider doing
> > cc:stable" question.
> 
> There is no upstream user of this code IIRC, so does it make sense to
> mark anything for stable trees?

I am fine with dropping stable, distribution that care about out of tree
drivers can easily backport themself. I am hoping to have the nouveau
part upstream in 4.18/4.19 ...

Cheers,
Jerome
