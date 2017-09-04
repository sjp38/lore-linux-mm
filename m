Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id F2DEE6B04BD
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 11:51:29 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id p12so916386qkl.0
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 08:51:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s62si5866448qkl.491.2017.09.04.08.51.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Sep 2017 08:51:28 -0700 (PDT)
Date: Mon, 4 Sep 2017 11:51:23 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM-v25 19/19] mm/hmm: add new helper to hotplug CDM memory
 region v3
Message-ID: <20170904155123.GA3161@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
 <20170817000548.32038-20-jglisse@redhat.com>
 <a42b13a4-9f58-dcbb-e9de-c573fbafbc2f@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a42b13a4-9f58-dcbb-e9de-c573fbafbc2f@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <liubo95@huawei.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, majiuyue <majiuyue@huawei.com>, "xieyisheng (A)" <xieyisheng1@huawei.com>

On Mon, Sep 04, 2017 at 11:09:14AM +0800, Bob Liu wrote:
> On 2017/8/17 8:05, Jerome Glisse wrote:
> > Unlike unaddressable memory, coherent device memory has a real
> > resource associated with it on the system (as CPU can address
> > it). Add a new helper to hotplug such memory within the HMM
> > framework.
> > 
> 
> Got an new question, coherent device( e.g CCIX) memory are likely reported to OS 
> through ACPI and recognized as NUMA memory node.
> Then how can their memory be captured and managed by HMM framework?
> 

Only platform that has such memory today is powerpc and it is not reported
as regular memory by the firmware hence why they need this helper.

I don't think anyone has defined anything yet for x86 and acpi. As this is
memory on PCIE like interface then i don't expect it to be reported as NUMA
memory node but as io range like any regular PCIE resources. Device driver
through capabilities flags would then figure out if the link between the
device and CPU is CCIX capable if so it can use this helper to hotplug it
as device memory.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
