Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 503096B030C
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 11:58:12 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id j192-v6so5491067oih.11
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 08:58:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 37sor12845842otr.41.2018.10.30.08.58.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Oct 2018 08:58:11 -0700 (PDT)
MIME-Version: 1.0
References: <20181029141210.GJ32673@dhcp22.suse.cz> <84f09883c16608ddd2ba88103f43ec6a1c649e97.camel@linux.intel.com>
 <20181029163528.GL32673@dhcp22.suse.cz> <18dfc5a0db11650ff31433311da32c95e19944d9.camel@linux.intel.com>
 <20181029172415.GM32673@dhcp22.suse.cz> <8e7a4311a240b241822945c0bb4095c9ffe5a14d.camel@linux.intel.com>
 <20181029181827.GO32673@dhcp22.suse.cz> <3281f3044fa231bbc1b02d5c5efca3502a0d05a8.camel@linux.intel.com>
 <20181030062915.GT32673@dhcp22.suse.cz> <CAPcyv4itSde5oiW2j5uK8PCqdpXkHKz=kS8NBk2Ge+Ldb=yLUg@mail.gmail.com>
 <20181030081757.GX32673@dhcp22.suse.cz>
In-Reply-To: <20181030081757.GX32673@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 30 Oct 2018 08:57:58 -0700
Message-ID: <CAPcyv4jPoNC86wKH7aNiJfy0ZHKDZ6kTjjomeu8uFecuMNpqHA@mail.gmail.com>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: alexander.h.duyck@linux.intel.com, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, Dave Hansen <dave.hansen@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, rppt@linux.vnet.ibm.com, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, osalvador@techadventures.net

On Tue, Oct 30, 2018 at 1:18 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 29-10-18 23:55:12, Dan Williams wrote:
> > On Mon, Oct 29, 2018 at 11:29 PM Michal Hocko <mhocko@kernel.org> wrote:
[..]
> > That testing identified this initialization performance problem and
> > thankfully got it addressed in time for the current merge window.
>
> And I still cannot see a word about that in changelogs.

True, I would have preferred that commit 966cf44f637e "mm: defer
ZONE_DEVICE page initialization to the point where we init pgmap"
include some notes about the scaling advantages afforded by not
serializing memmap_init_zone() work. I think this information got
distributed across several patch series because removing the lock was
not sufficient by itself, Alex went further to also rework the
physical socket affinity of the nvdimm sub-system's async
initialization threads.

As the code gets refactored further it's a chance to add commentary on
the scaling expectations of the design.
