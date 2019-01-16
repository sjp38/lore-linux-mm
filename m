Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC2A8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 16:53:05 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id c14so4662119pls.21
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 13:53:05 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id k6si7643648pgr.500.2019.01.16.13.53.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 13:53:04 -0800 (PST)
Subject: Re: [PATCH 4/4] dax: "Hotplug" persistent memory for use like normal
 RAM
References: <20190116181859.D1504459@viggo.jf.intel.com>
 <20190116181905.12E102B4@viggo.jf.intel.com>
 <CAErSpo55j7odYf-B-KSoogabD9Qqt605oUGYe6td9wZdYNq_Hg@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <f786481c-d38d-5129-318b-cb61b6251c47@intel.com>
Date: Wed, 16 Jan 2019 13:53:03 -0800
MIME-Version: 1.0
In-Reply-To: <CAErSpo55j7odYf-B-KSoogabD9Qqt605oUGYe6td9wZdYNq_Hg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bjorn Helgaas <bhelgaas@google.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: dave@sr71.net, Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, linux-nvdimm@lists.01.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Huang Ying <ying.huang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>, baiyaowei@cmss.chinamobile.com, Takashi Iwai <tiwai@suse.de>

On 1/16/19 1:16 PM, Bjorn Helgaas wrote:
>> +       /*
>> +        * Set flags appropriate for System RAM.  Leave ..._BUSY clear
>> +        * so that add_memory() can add a child resource.
>> +        */
>> +       new_res->flags = IORESOURCE_SYSTEM_RAM;
> IIUC, new_res->flags was set to "IORESOURCE_MEM | ..." in the
> devm_request_mem_region() path.  I think you should keep at least
> IORESOURCE_MEM so the iomem_resource tree stays consistent.

I went to look at fixing this.  It looks like "IORESOURCE_SYSTEM_RAM"
includes IORESOURCE_MEM:

> #define IORESOURCE_SYSTEM_RAM           (IORESOURCE_MEM|IORESOURCE_SYSRAM)

Did you want the patch to expand this #define, or did you just want to
ensure that IORESORUCE_MEM got in there somehow?
