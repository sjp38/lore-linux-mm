Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8CB268E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 12:43:30 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id s11-v6so1253683pgv.9
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 09:43:30 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 3-v6si1476077plv.314.2018.09.12.09.43.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 09:43:29 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm: Provide kernel parameter to allow disabling page
 init poisoning
References: <20180910232615.4068.29155.stgit@localhost.localdomain>
 <20180910234341.4068.26882.stgit@localhost.localdomain>
 <20180912141053.GL10951@dhcp22.suse.cz>
 <CAKgT0UdvhV7U5Zniq=KskXz2QsRP8C7ctr5=ZtJwYAVpBT-RHw@mail.gmail.com>
 <841e8101-40db-9ff2-f688-5f175d91fc31@intel.com>
 <CAKgT0UeKnaY4XebOmtGozbjEJN4k3cwyhdBLPPJLc677-QU+Sw@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <68ccf46e-8c1e-c796-df35-afb5b295d6ea@intel.com>
Date: Wed, 12 Sep 2018 09:43:27 -0700
MIME-Version: 1.0
In-Reply-To: <CAKgT0UeKnaY4XebOmtGozbjEJN4k3cwyhdBLPPJLc677-QU+Sw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>, mhocko@kernel.org, pavel.tatashin@microsoft.com, dan.j.williams@intel.com
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-nvdimm@lists.01.org, dave.jiang@intel.com, Ingo Molnar <mingo@kernel.org>, jglisse@redhat.com, Andrew Morton <akpm@linux-foundation.org>, logang@deltatee.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 09/12/2018 09:36 AM, Alexander Duyck wrote:
>>         vm_debug =      [KNL] Available with CONFIG_DEBUG_VM=y.
>>                         May slow down boot speed, especially on larger-
>>                         memory systems when enabled.
>>                         off: turn off all runtime VM debug features
>>                         all: turn on all debug features (default)
> This would introduce a significant amount of code change if we do it
> as a parameter that has control over everything.

Sure, but don't do that now.  Just put page poisoning under it now.
