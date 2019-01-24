Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7539B8E0097
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 14:10:52 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id s22so4565841pgv.8
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 11:10:52 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id z20si21527519pgv.159.2019.01.24.11.10.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 11:10:51 -0800 (PST)
Subject: Re: [RFC PATCH] x86, numa: always initialize all possible nodes
References: <20190114082416.30939-1-mhocko@kernel.org>
 <20190124141727.GN4087@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <3a7a3cf2-b7d9-719e-85b0-352be49a6d0f@intel.com>
Date: Thu, 24 Jan 2019 11:10:50 -0800
MIME-Version: 1.0
In-Reply-To: <20190124141727.GN4087@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 1/24/19 6:17 AM, Michal Hocko wrote:
> and nr_cpus set to 4. The underlying reason is tha the device is bound
> to node 2 which doesn't have any memory and init_cpu_to_node only
> initializes memory-less nodes for possible cpus which nr_cpus restrics.
> This in turn means that proper zonelists are not allocated and the page
> allocator blows up.

This looks OK to me.

Could we add a few DEBUG_VM checks that *look* for these invalid
zonelists?  Or, would our existing list debugging have caught this?

Basically, is this bug also a sign that we need better debugging around
this?
