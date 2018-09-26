Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 15DE78E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 11:45:28 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id a4-v6so6015328pfi.16
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 08:45:28 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id o5-v6si5589893pgo.250.2018.09.26.08.45.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 08:45:27 -0700 (PDT)
Subject: Re: [PATCH v5 2/4] mm: Provide kernel parameter to allow disabling
 page init poisoning
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925201921.3576.84239.stgit@localhost.localdomain>
 <20180926073831.GC6278@dhcp22.suse.cz>
 <c57da51a-009a-9500-4dc5-1d9912e78abd@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <98411844-19b7-a75b-d52c-6e2c46b40d57@intel.com>
Date: Wed, 26 Sep 2018 08:41:29 -0700
MIME-Version: 1.0
In-Reply-To: <c57da51a-009a-9500-4dc5-1d9912e78abd@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, jglisse@redhat.com, rppt@linux.vnet.ibm.com, dan.j.williams@intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com

On 09/26/2018 08:24 AM, Alexander Duyck wrote:
> With no options it works just like slub_debug and enables all
> available options. So in our case it is a NOP since we wanted the
> debugging enabled by default.

Yeah, but slub_debug is different.

First, nobody uses the slub_debug=- option because *that* is only used
when you have SLUB_DEBUG=y *and* CONFIG_SLUB_DEBUG_ON=y, which not even
Fedora does.

slub_debug is *primarily* for *adding* debug features.  For this, we
need to turn them off.

It sounds like following slub_debug was a bad idea, especially following
its semantics too closely when it doesn't make sense.
