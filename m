Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0DC742808A3
	for <linux-mm@kvack.org>; Wed, 10 May 2017 11:45:30 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e64so26080768pfd.3
        for <linux-mm@kvack.org>; Wed, 10 May 2017 08:45:30 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id d62si3361816pga.183.2017.05.10.08.45.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 May 2017 08:45:29 -0700 (PDT)
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
 <a445774f-a307-25aa-d44e-c523a7a42da6@redhat.com>
 <0b55343e-4305-a9f1-2b17-51c3c734aea6@huawei.com>
 <20170510080542.GF31466@dhcp22.suse.cz>
 <885311a2-5b9f-4402-0a71-5a3be7870aa0@huawei.com>
 <20170510114319.GK31466@dhcp22.suse.cz>
 <1a8cc1f4-0b72-34ea-43ad-5ece22a8d5cf@huawei.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <b780ac13-4fc3-ac07-f0c0-7a6cc8dae694@intel.com>
Date: Wed, 10 May 2017 08:45:28 -0700
MIME-Version: 1.0
In-Reply-To: <1a8cc1f4-0b72-34ea-43ad-5ece22a8d5cf@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On 05/10/2017 08:19 AM, Igor Stoppa wrote:
> So I'd like to play a little what-if scenario:
> what if I was to support exclusively virtual memory and convert to it
> everything that might need sealing?

Because of the issues related to fracturing large pages, you might have
had to go this route eventually anyway.  Changing the kernel linear map
isn't nice.

FWIW, you could test this scheme by just converting all the users to
vmalloc() and seeing what breaks.  They'd all end up rounding up all
their allocations to PAGE_SIZE, but that'd be fine for testing.

Could you point out 5 or 10 places in the kernel that you want to convert?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
