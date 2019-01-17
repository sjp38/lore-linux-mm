Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8EAD48E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 16:57:22 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id z6so10408132qtj.21
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 13:57:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a123si6317145qkd.182.2019.01.17.13.57.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 13:57:21 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 0/4] Allow persistent memory to be used like normal RAM
References: <20190116181859.D1504459@viggo.jf.intel.com>
	<x49sgxr9rjd.fsf@segfault.boston.devel.redhat.com>
	<20190117164736.GC31543@localhost.localdomain>
	<x49pnsv8am1.fsf@segfault.boston.devel.redhat.com>
	<20190117193403.GD31543@localhost.localdomain>
Date: Thu, 17 Jan 2019 16:57:17 -0500
In-Reply-To: <20190117193403.GD31543@localhost.localdomain> (Keith Busch's
	message of "Thu, 17 Jan 2019 12:34:03 -0700")
Message-ID: <x49ef9b6j7m.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, thomas.lendacky@amd.com, fengguang.wu@intel.com, dave@sr71.net, linux-nvdimm@lists.01.org, tiwai@suse.de, zwisler@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, baiyaowei@cmss.chinamobile.com, ying.huang@intel.com, bhelgaas@google.com, akpm@linux-foundation.org, bp@suse.de

Keith Busch <keith.busch@intel.com> writes:

>> Keith, you seem to be implying that there are platforms that won't
>> support memory mode.  Do you also have some insight into how customers
>> want to use this, beyond my speculation?  It's really frustrating to see
>> patch sets like this go by without any real use cases provided.
>
> Right, most NFIT reporting platforms today don't have memory mode, and
> the kernel currently only supports the persistent DAX mode with these.
> This series adds another option for those platforms.

All NFIT reporting platforms today are shipping NVDIMM-Ns, where it
makes absolutely no sense to use them as regular DRAM.  I don't think
that's a good argument to make.

> I think numactl as you mentioned is the first consideration for how
> customers may make use. Dave or Dan might have other use cases in mind.

Well, it sure looks like this took a lot of work, so I thought there
were known use cases or users asking for this functionality.

Cheers,
Jeff
