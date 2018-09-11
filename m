Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 135C18E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 20:38:04 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id r19-v6so44681835itc.4
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 17:38:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u127-v6sor8607205itf.124.2018.09.10.17.38.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Sep 2018 17:38:02 -0700 (PDT)
MIME-Version: 1.0
References: <20180910232615.4068.29155.stgit@localhost.localdomain> <20180910234400.4068.15541.stgit@localhost.localdomain>
In-Reply-To: <20180910234400.4068.15541.stgit@localhost.localdomain>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 10 Sep 2018 17:37:50 -0700
Message-ID: <CAKgT0UceRHjfoKPxAJEchX4O91j_mtCQxqjTSQ=GJSoSOGbWmg@mail.gmail.com>
Subject: Re: [PATCH 4/4] nvdimm: Trigger the device probe on a cpu local to
 the device
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-nvdimm@lists.01.org
Cc: pavel.tatashin@microsoft.com, Michal Hocko <mhocko@suse.com>, dave.jiang@intel.com, Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@intel.com>, jglisse@redhat.com, Andrew Morton <akpm@linux-foundation.org>, logang@deltatee.com, dan.j.williams@intel.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Sep 10, 2018 at 4:44 PM Alexander Duyck
<alexander.duyck@gmail.com> wrote:
>
> From: Alexander Duyck <alexander.h.duyck@intel.com>
>
> This patch is based off of the pci_call_probe function used to initialize
> PCI devices. The general idea here is to move the probe call to a location
> that is local to the memory being initialized. By doing this we can shave
> significant time off of the total time needed for initialization.
>
> With this patch applied I see a significant reduction in overall init time
> as without it the init varied between 23 and 37 seconds to initialize a 3GB
> node. With this patch applied the variance is only between 23 and 26
> seconds to initialize each node.

Same mistake here as in patch 1. It is 3TB, not 3GB. I will fix for
the next version.

- Alex
