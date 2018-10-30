Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id EDB3C6B04D0
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 02:55:25 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id w126-v6so8936447oib.18
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 23:55:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 10sor10466004otg.122.2018.10.29.23.55.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Oct 2018 23:55:24 -0700 (PDT)
MIME-Version: 1.0
References: <20181017075257.GF18839@dhcp22.suse.cz> <971729e6-bcfe-a386-361b-d662951e69a7@linux.intel.com>
 <20181029141210.GJ32673@dhcp22.suse.cz> <84f09883c16608ddd2ba88103f43ec6a1c649e97.camel@linux.intel.com>
 <20181029163528.GL32673@dhcp22.suse.cz> <18dfc5a0db11650ff31433311da32c95e19944d9.camel@linux.intel.com>
 <20181029172415.GM32673@dhcp22.suse.cz> <8e7a4311a240b241822945c0bb4095c9ffe5a14d.camel@linux.intel.com>
 <20181029181827.GO32673@dhcp22.suse.cz> <3281f3044fa231bbc1b02d5c5efca3502a0d05a8.camel@linux.intel.com>
 <20181030062915.GT32673@dhcp22.suse.cz>
In-Reply-To: <20181030062915.GT32673@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 29 Oct 2018 23:55:12 -0700
Message-ID: <CAPcyv4itSde5oiW2j5uK8PCqdpXkHKz=kS8NBk2Ge+Ldb=yLUg@mail.gmail.com>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: alexander.h.duyck@linux.intel.com, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, Dave Hansen <dave.hansen@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, rppt@linux.vnet.ibm.com, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, osalvador@techadventures.net

On Mon, Oct 29, 2018 at 11:29 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 29-10-18 12:59:11, Alexander Duyck wrote:
> > On Mon, 2018-10-29 at 19:18 +0100, Michal Hocko wrote:
[..]
> > The patches Andrew pushed addressed the immediate issue so that now
> > systems with nvdimm/DAX memory can at least initialize quick enough
> > that systemd doesn't refuse to mount the root file system due to a
> > timeout.
>
> This is about the first time you actually mention that. I have re-read
> the cover letter and all changelogs of patches in this serious. Unless I
> have missed something there is nothing about real users hitting issues
> out there. nvdimm is still considered a toy because there is no real HW
> users can play with.

Yes, you have missed something, because that's incorrect. There's been
public articles about these parts sampling since May.

    https://www.anandtech.com/show/12828/intel-launches-optane-dimms-up-to-512gb-apache-pass-is-here

That testing identified this initialization performance problem and
thankfully got it addressed in time for the current merge window.
