Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A63E2831F4
	for <linux-mm@kvack.org>; Thu,  4 May 2017 10:31:00 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id k14so12233796pga.5
        for <linux-mm@kvack.org>; Thu, 04 May 2017 07:31:00 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 3si2240044plu.43.2017.05.04.07.30.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 May 2017 07:31:00 -0700 (PDT)
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
 <70a9d4db-f374-de45-413b-65b74c59edcb@intel.com>
 <b7bb1884-3125-5c98-f1fe-53b974454ce2@huawei.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <210752b7-1cbf-2ac3-9f9a-62536dfd24d8@intel.com>
Date: Thu, 4 May 2017 07:30:59 -0700
MIME-Version: 1.0
In-Reply-To: <b7bb1884-3125-5c98-f1fe-53b974454ce2@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/04/2017 01:17 AM, Igor Stoppa wrote:
> Or, let me put it differently: my goal is to not fracture more pages
> than needed.
> It will probably require some profiling to figure out what is the
> ballpark of the memory footprint.

This is easy to say, but hard to do.  What if someone loads a different
set of LSMs, or uses a very different configuration?  How could this
possibly work generally without vastly over-reserving in most cases?

> I might have overlooked some aspect of this, but the overall goal
> is to have a memory range (I won't call it zone, to avoid referring to a
> specific implementation) which is as tightly packed as possible, stuffed
> with all the data that is expected to become read-only.

I'm starting with the assumption that a new zone isn't feasible. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
