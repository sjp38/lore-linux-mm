Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A2316B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 17:58:34 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b74so10642283pfj.5
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 14:58:34 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id m2si870449pln.134.2017.06.14.14.58.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 14:58:33 -0700 (PDT)
Subject: Re: [HMM-CDM 0/5] Cache coherent device memory (CDM) with HMM
References: <20170614201144.9306-1-jglisse@redhat.com>
 <8219f8fb-65bb-7c6b-6c4c-acc0601c1e0f@intel.com>
 <20170614213800.GD4160@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <3a617630-2406-da49-707c-4959a2afd8e1@intel.com>
Date: Wed, 14 Jun 2017 14:58:30 -0700
MIME-Version: 1.0
In-Reply-To: <20170614213800.GD4160@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, cgroups@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Balbir Singh <balbirs@au1.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/14/2017 02:38 PM, Jerome Glisse wrote:
> On Wed, Jun 14, 2017 at 02:20:23PM -0700, Dave Hansen wrote:
>> On 06/14/2017 01:11 PM, JA(C)rA'me Glisse wrote:
>>> Cache coherent device memory apply to architecture with system bus
>>> like CAPI or CCIX. Device connected to such system bus can expose
>>> their memory to the system and allow cache coherent access to it
>>> from the CPU.
>> How does this interact with device memory that's enumerated in the new
>> ACPI 6.2 HMAT?  That stuff is also in the normal e820 and, by default,
>> treated as normal system RAM.  Would this mechanism be used for those
>> devices as well?
>>
>> http://www.uefi.org/sites/default/files/resources/ACPI_6_2.pdf
> It doesn't interact with that. HMM-CDM is a set of helper that don't
> do anything unless instructed so. So for device memory to be presented
> as HMM-CDM you need to hotplug it as ZONE_DEVICE(DEVICE_PUBLIC) which
> can be done with the helper introduced in patch 2 of this patchset.

I guess I'm asking whether we *should* instruct HMM-CDM to manage all
coherent device memory.  If not, where do we draw the line for what we
use HMM-CDM, and for what we use the core MM?

> I don't think that the HMAT inside ACPI is restricted or even intended
> for device memory.

It can definitely describe memory attached to memory controllers which
are not directly attached to CPUs.  That means either some kind of
memory expander, or device memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
