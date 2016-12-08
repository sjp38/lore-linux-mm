Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 56A846B0267
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 11:21:34 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id p66so175435267pga.4
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 08:21:34 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 68si29442410pga.8.2016.12.08.08.21.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 08:21:33 -0800 (PST)
Subject: Re: [HMM v14 05/16] mm/ZONE_DEVICE/unaddressable: add support for
 un-addressable device memory
References: <1481215184-18551-1-git-send-email-jglisse@redhat.com>
 <1481215184-18551-6-git-send-email-jglisse@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <be2861b4-d830-fbd7-e9eb-ebc8e4d913a2@intel.com>
Date: Thu, 8 Dec 2016 08:21:28 -0800
MIME-Version: 1.0
In-Reply-To: <1481215184-18551-6-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On 12/08/2016 08:39 AM, JA(C)rA'me Glisse wrote:
> Architecture that wish to support un-addressable device memory should make
> sure to never populate the kernel linar mapping for the physical range.

Does the platform somehow provide a range of physical addresses for this
unaddressable area?  How do we know no memory will be hot-added in a
range we're using for unaddressable device memory, for instance?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
