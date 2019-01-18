Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 203278E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 12:45:20 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id w1so12890500qta.12
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 09:45:20 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x60si1022214qtd.345.2019.01.18.09.45.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 09:45:19 -0800 (PST)
Date: Fri, 18 Jan 2019 12:45:13 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: [LSF/MM TOPIC] NUMA, memory hierarchy and device memory
Message-ID: <20190118174512.GA3060@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Felix Kuehling <Felix.Kuehling@amd.com>, John Hubbard <jhubbard@nvidia.com>, Jonathan Cameron <jonathan.cameron@huawei.com>, Keith Busch <keith.busch@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Paul Blinzer <Paul.Blinzer@amd.com>, linux-kernel@vger.kernel.org

Hi, i would like to discuss about NUMA API and its short comings when
it comes to memory hierarchy (from fast HBM, to slower persistent
memory through regular memory) and also device memory (which can have
its own hierarchy).

I have proposed a patch to add a new memory topology model to the
kernel for application to be able to get that informations, it
also included a set of new API to bind/migrate process range [1].
Note that this model also support device memory.

So far device memory support is achieve through device specific ioctl
and this forbid some scenario like device memory interleaving accross
multiple devices for a range. It also make the whole userspace more
complex as program have to mix and match multiple device specific API
on top of NUMA API.

While memory hierarchy can be more or less expose through the existing
NUMA API by creating node for non-regular memory [2], i do not see this
as a satisfying solution. Moreover such scheme does not work for device
memory that might not even be accessible by CPUs.


Hence i would like to discuss few points:
    - What proof people wants to see this as problem we need to solve ?
    - How to build concensus to move forward on this ?
    - What kind of syscall API people would like to see ?

People to discuss this topic:
    Dan Williams <dan.j.williams@intel.com>
    Dave Hansen <dave.hansen@intel.com>
    Felix Kuehling <Felix.Kuehling@amd.com>
    John Hubbard <jhubbard@nvidia.com>
    Jonathan Cameron <jonathan.cameron@huawei.com>
    Keith Busch <keith.busch@intel.com>
    Mel Gorman <mgorman@techsingularity.net>
    Michal Hocko <mhocko@kernel.org>
    Paul Blinzer <Paul.Blinzer@amd.com>

Probably others, sorry if i miss anyone from previous discussions.

Cheers,
Jérôme

[1] https://lkml.org/lkml/2018/12/3/1072
[2] https://lkml.org/lkml/2018/12/10/1112
