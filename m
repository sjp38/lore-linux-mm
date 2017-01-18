Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 946FC6B0038
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 15:23:56 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 80so30533684pfy.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 12:23:56 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w71si1177521pfj.282.2017.01.18.12.23.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 12:23:55 -0800 (PST)
Date: Wed, 18 Jan 2017 12:23:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: + mm-swap-add-cluster-lock-v5.patch added to -mm tree
Message-Id: <20170118122354.9b06459e2588e53b537ca78c@linux-foundation.org>
In-Reply-To: <20170118083731.GF7015@dhcp22.suse.cz>
References: <587eaca3.MRSwND8OEi+lF+VH%akpm@linux-foundation.org>
	<20170118083731.GF7015@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: ying.huang@intel.com, aarcange@redhat.com, aaron.lu@intel.com, ak@linux.intel.com, borntraeger@de.ibm.com, corbet@lwn.net, dave.hansen@intel.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, hughd@google.com, kirill.shutemov@linux.intel.com, minchan@kernel.org, riel@redhat.com, shli@kernel.org, tim.c.chen@linux.intel.com, vdavydov.dev@gmail.com, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Wed, 18 Jan 2017 09:37:31 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> On Tue 17-01-17 15:45:39, Andrew Morton wrote:
> [...]
> > From: "Huang\, Ying" <ying.huang@intel.com>
> > Subject: mm-swap-add-cluster-lock-v5
> 
> I assume you are going to fold this into the original patch. Do you
> think it would make sense to have it in a separate patch along with
> the reasoning provided via email?

It should be OK - the v5 changelog (which I shall use for the folded
patch, as usual) has

: Compared with a previous implementation using bit_spin_lock, the
: sequential swap out throughput improved about 3.2%.  Test was done on a
: Xeon E5 v3 system.  The swap device used is a RAM simulated PMEM
: (persistent memory) device.  To test the sequential swapping out, the test
: case created 32 processes, which sequentially allocate and write to the
: anonymous pages until the RAM and part of the swap device is used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
