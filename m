Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 699046B04B4
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 23:36:57 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id x85so1227651vkx.4
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 20:36:57 -0700 (PDT)
Received: from mail-ua0-x22a.google.com (mail-ua0-x22a.google.com. [2607:f8b0:400c:c08::22a])
        by mx.google.com with ESMTPS id k205si4401912vka.186.2017.09.04.20.36.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Sep 2017 20:36:56 -0700 (PDT)
Received: by mail-ua0-x22a.google.com with SMTP id s15so5452275uag.1
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 20:36:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170904155123.GA3161@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com> <20170817000548.32038-20-jglisse@redhat.com>
 <a42b13a4-9f58-dcbb-e9de-c573fbafbc2f@huawei.com> <20170904155123.GA3161@redhat.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Tue, 5 Sep 2017 13:36:55 +1000
Message-ID: <CAKTCnzmvnfSg8NyMOZwAVcESeSiNK+5uugs3aS88X+POpCP8Ew@mail.gmail.com>
Subject: Re: [HMM-v25 19/19] mm/hmm: add new helper to hotplug CDM memory
 region v3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Bob Liu <liubo95@huawei.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, majiuyue <majiuyue@huawei.com>, "xieyisheng (A)" <xieyisheng1@huawei.com>

On Tue, Sep 5, 2017 at 1:51 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> On Mon, Sep 04, 2017 at 11:09:14AM +0800, Bob Liu wrote:
>> On 2017/8/17 8:05, J=C3=A9r=C3=B4me Glisse wrote:
>> > Unlike unaddressable memory, coherent device memory has a real
>> > resource associated with it on the system (as CPU can address
>> > it). Add a new helper to hotplug such memory within the HMM
>> > framework.
>> >
>>
>> Got an new question, coherent device( e.g CCIX) memory are likely report=
ed to OS
>> through ACPI and recognized as NUMA memory node.
>> Then how can their memory be captured and managed by HMM framework?
>>
>
> Only platform that has such memory today is powerpc and it is not reporte=
d
> as regular memory by the firmware hence why they need this helper.
>
> I don't think anyone has defined anything yet for x86 and acpi. As this i=
s
> memory on PCIE like interface then i don't expect it to be reported as NU=
MA
> memory node but as io range like any regular PCIE resources. Device drive=
r
> through capabilities flags would then figure out if the link between the
> device and CPU is CCIX capable if so it can use this helper to hotplug it
> as device memory.

Yep, the arch needs to do the right thing at hotplug time, which is

1. Don't online the memory as a NUMA node
2. Use the HMM-CDM API's to map the memory to ZONE DEVICE via the driver

Like Jerome said and we tried as well, the NUMA approach needs more
agreement and discussion and probable extensions

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
