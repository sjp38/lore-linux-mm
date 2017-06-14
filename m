Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id A1D3E6B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 19:40:45 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id o21so10461245qtb.13
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 16:40:45 -0700 (PDT)
Received: from mail-qt0-x22b.google.com (mail-qt0-x22b.google.com. [2607:f8b0:400d:c0d::22b])
        by mx.google.com with ESMTPS id j35si1314166qtb.46.2017.06.14.16.40.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 16:40:44 -0700 (PDT)
Received: by mail-qt0-x22b.google.com with SMTP id u12so20697172qth.0
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 16:40:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <3a617630-2406-da49-707c-4959a2afd8e1@intel.com>
References: <20170614201144.9306-1-jglisse@redhat.com> <8219f8fb-65bb-7c6b-6c4c-acc0601c1e0f@intel.com>
 <20170614213800.GD4160@redhat.com> <3a617630-2406-da49-707c-4959a2afd8e1@intel.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Thu, 15 Jun 2017 09:40:43 +1000
Message-ID: <CAKTCnz=4AKGnfF5HtcyMQot6zMgtOc+eRiZ5=G+MDYWAFN1bEg@mail.gmail.com>
Subject: Re: [HMM-CDM 0/5] Cache coherent device memory (CDM) with HMM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Jerome Glisse <jglisse@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, Jun 15, 2017 at 7:58 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 06/14/2017 02:38 PM, Jerome Glisse wrote:
>> On Wed, Jun 14, 2017 at 02:20:23PM -0700, Dave Hansen wrote:
>>> On 06/14/2017 01:11 PM, J=C3=A9r=C3=B4me Glisse wrote:
>>>> Cache coherent device memory apply to architecture with system bus
>>>> like CAPI or CCIX. Device connected to such system bus can expose
>>>> their memory to the system and allow cache coherent access to it
>>>> from the CPU.
>>> How does this interact with device memory that's enumerated in the new
>>> ACPI 6.2 HMAT?  That stuff is also in the normal e820 and, by default,
>>> treated as normal system RAM.  Would this mechanism be used for those
>>> devices as well?
>>>
>>> http://www.uefi.org/sites/default/files/resources/ACPI_6_2.pdf
>> It doesn't interact with that. HMM-CDM is a set of helper that don't
>> do anything unless instructed so. So for device memory to be presented
>> as HMM-CDM you need to hotplug it as ZONE_DEVICE(DEVICE_PUBLIC) which
>> can be done with the helper introduced in patch 2 of this patchset.
>

[Removing my cc'd email id and responding from a different address]

> I guess I'm asking whether we *should* instruct HMM-CDM to manage all
> coherent device memory.  If not, where do we draw the line for what we
> use HMM-CDM, and for what we use the core MM?
>

If you believe the memory is managed by the device (and owned by a device
driver) I'd suggest using HMM-CDM. The idea behind HMM-CDM was that
it enables transparent migration of pages and its preferred when
locality of computation
and locality of memory access is the preferred model.

The other model was N_COHERENT_MEMORY that used the core MM, but
there were objections to exposing device memory using that technology.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
