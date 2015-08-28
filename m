Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f53.google.com (mail-vk0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id B20F26B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 17:47:19 -0400 (EDT)
Received: by vkbc123 with SMTP id c123so15617644vkb.3
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 14:47:19 -0700 (PDT)
Received: from mail-vk0-f45.google.com (mail-vk0-f45.google.com. [209.85.213.45])
        by mx.google.com with ESMTPS id fa9si10010973vdb.66.2015.08.28.14.47.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 14:47:18 -0700 (PDT)
Received: by vkaw128 with SMTP id w128so15719681vka.2
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 14:47:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1440798084.14237.106.camel@hp.com>
References: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20150826012751.8851.78564.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20150826124124.GA7613@lst.de>
	<1440624859.31365.17.camel@intel.com>
	<1440798084.14237.106.camel@hp.com>
Date: Fri, 28 Aug 2015 14:47:18 -0700
Message-ID: <CAPcyv4iaado-ARQ4z=4jCYH3n7x5+pNsbDjd9XkWyiu=aFyBWA@mail.gmail.com>
Subject: Re: [PATCH v2 5/9] x86, pmem: push fallback handling to arch code
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: "hch@lst.de" <hch@lst.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mingo@kernel.org" <mingo@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "hpa@zytor.com" <hpa@zytor.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "mingo@redhat.com" <mingo@redhat.com>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "boaz@plexistor.com" <boaz@plexistor.com>, "david@fromorbit.com" <david@fromorbit.com>

On Fri, Aug 28, 2015 at 2:41 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> On Wed, 2015-08-26 at 21:34 +0000, Williams, Dan J wrote:
[..]
>> -#define ARCH_MEMREMAP_PMEM MEMREMAP_WB
>
> Should it be better to do:
>
> #else   /* !CONFIG_ARCH_HAS_PMEM_API */
> #define ARCH_MEMREMAP_PMEM MEMREMAP_WT
>
> so that you can remove all '#ifdef ARCH_MEMREMAP_PMEM' stuff?

Yeah, that seems like a nice incremental cleanup for memremap_pmem()
to just unconditionally use ARCH_MEMREMAP_PMEM, feel free to send it
along.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
