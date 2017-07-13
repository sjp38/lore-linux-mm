Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9451A4408E5
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 19:02:20 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s4so74276398pgr.3
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 16:02:20 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id c12si5037712pfh.468.2017.07.13.16.02.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 16:02:19 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id u62so8413761pgb.0
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 16:02:19 -0700 (PDT)
Message-ID: <1499986876.28717.1.camel@gmail.com>
Subject: Re: [PATCH 2/6] mm/device-public-memory: device memory cache
 coherent with CPU v4
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 14 Jul 2017 09:01:16 +1000
In-Reply-To: <20170713211532.970-3-jglisse@redhat.com>
References: <20170713211532.970-1-jglisse@redhat.com>
	 <20170713211532.970-3-jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@kernel.org>, Balbir Singh <balbirs@au1.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Thu, 2017-07-13 at 17:15 -0400, JA(C)rA'me Glisse wrote:
> Platform with advance system bus (like CAPI or CCIX) allow device
> memory to be accessible from CPU in a cache coherent fashion. Add
> a new type of ZONE_DEVICE to represent such memory. The use case
> are the same as for the un-addressable device memory but without
> all the corners cases.
> 
> Changed since v3:
>   - s/public/public (going back)
> Changed since v2:
>   - s/public/public
>   - add proper include in migrate.c and drop useless #if/#endif
> Changed since v1:
>   - Kconfig and #if/#else cleanup
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Cc: Balbir Singh <balbirs@au1.ibm.com>
> Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---

Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
