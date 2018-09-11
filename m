Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6D31F8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 20:35:46 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id f4-v6so2328053ioh.13
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 17:35:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g18-v6sor11367346ita.91.2018.09.10.17.35.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Sep 2018 17:35:45 -0700 (PDT)
MIME-Version: 1.0
References: <20180910232615.4068.29155.stgit@localhost.localdomain> <20180910234341.4068.26882.stgit@localhost.localdomain>
In-Reply-To: <20180910234341.4068.26882.stgit@localhost.localdomain>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 10 Sep 2018 17:35:34 -0700
Message-ID: <CAKgT0UcP4G-Y8ad2yGh_kGSSD4ry-Z+FtZ+6wwFzUS3YkpeFyg@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm: Provide kernel parameter to allow disabling page
 init poisoning
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-nvdimm@lists.01.org
Cc: pavel.tatashin@microsoft.com, Michal Hocko <mhocko@suse.com>, dave.jiang@intel.com, Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@intel.com>, jglisse@redhat.com, Andrew Morton <akpm@linux-foundation.org>, logang@deltatee.com, dan.j.williams@intel.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Sep 10, 2018 at 4:43 PM Alexander Duyck
<alexander.duyck@gmail.com> wrote:
>
> From: Alexander Duyck <alexander.h.duyck@intel.com>
>
> On systems with a large amount of memory it can take a significant amount
> of time to initialize all of the page structs with the PAGE_POISON_PATTERN
> value. I have seen it take over 2 minutes to initialize a system with
> over 12GB of RAM.

Minor typo. I meant 12TB here, not 12GB.

- Alex
