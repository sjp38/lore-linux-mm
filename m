Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 94D6E6B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 18:08:24 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id l6so1238454iti.0
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 15:08:24 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id m7si1255833ite.18.2017.06.14.15.08.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 15:08:23 -0700 (PDT)
Message-ID: <1497478076.2897.46.camel@kernel.crashing.org>
Subject: Re: [HMM-CDM 0/5] Cache coherent device memory (CDM) with HMM
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 15 Jun 2017 08:07:56 +1000
In-Reply-To: <3a617630-2406-da49-707c-4959a2afd8e1@intel.com>
References: <20170614201144.9306-1-jglisse@redhat.com>
	 <8219f8fb-65bb-7c6b-6c4c-acc0601c1e0f@intel.com>
	 <20170614213800.GD4160@redhat.com>
	 <3a617630-2406-da49-707c-4959a2afd8e1@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Jerome Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, cgroups@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Balbir Singh <balbirs@au1.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>

On Wed, 2017-06-14 at 14:58 -0700, Dave Hansen wrote:
> > > http://www.uefi.org/sites/default/files/resources/ACPI_6_2.pdf
> > 
> > It doesn't interact with that. HMM-CDM is a set of helper that don't
> > do anything unless instructed so. So for device memory to be presented
> > as HMM-CDM you need to hotplug it as ZONE_DEVICE(DEVICE_PUBLIC) which
> > can be done with the helper introduced in patch 2 of this patchset.
> 
> I guess I'm asking whether we *should* instruct HMM-CDM to manage all
> coherent device memory.A  If not, where do we draw the line for what we
> use HMM-CDM, and for what we use the core MM?

Well, if you want the features of HMM ... It basically boils down to
whether you have some kind of coherent processing unit close to that
memory and want to manage transparent migration of pages between system
and device memory, that sort of thing.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
