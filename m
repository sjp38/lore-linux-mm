Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 55B058E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 18:01:41 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id m13so4788733pls.15
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 15:01:41 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id h75si7791244pfj.257.2019.01.16.15.01.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 15:01:40 -0800 (PST)
Subject: Re: [PATCH 2/4] mm/memory-hotplug: allow memory resources to be
 children
References: <20190116181859.D1504459@viggo.jf.intel.com>
 <20190116181902.670EEBC3@viggo.jf.intel.com>
 <20190116191635.GD3617@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <2b52778d-f120-eec7-3e7a-3a9c182170f0@intel.com>
Date: Wed, 16 Jan 2019 15:01:39 -0800
MIME-Version: 1.0
In-Reply-To: <20190116191635.GD3617@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: dave@sr71.net, dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com, baiyaowei@cmss.chinamobile.com, tiwai@suse.de

On 1/16/19 11:16 AM, Jerome Glisse wrote:
>> We also rework the old error message a bit since we do not get
>> the conflicting entry back: only an indication that we *had* a
>> conflict.
> We should keep the device private check (moving it in __request_region)
> as device private can try to register un-use physical address (un-use
> at time of device private registration) that latter can block valid
> physical address the error message you are removing report such event.

If a resource can't support having a child, shouldn't it just be marked
IORESOURCE_BUSY, rather than trying to somehow special-case
IORES_DESC_DEVICE_PRIVATE_MEMORY behavior?
