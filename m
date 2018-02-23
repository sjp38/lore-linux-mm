Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id AC7546B002B
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 21:45:28 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id h8so6380941iob.20
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 18:45:28 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id 73si564431itz.88.2018.02.22.18.45.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 18:45:27 -0800 (PST)
Date: Thu, 22 Feb 2018 20:45:24 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC 1/2] Protect larger order pages from breaking up
In-Reply-To: <1B85435E-A9FB-47E7-A2FE-FE21632778F0@cs.rutgers.edu>
Message-ID: <alpine.DEB.2.20.1802222042290.2375@nuc-kabylake>
References: <20180216160110.641666320@linux.com> <20180216160121.519788537@linux.com> <20180219101935.cb3gnkbjimn5hbud@techsingularity.net> <68050f0f-14ca-d974-9cf4-19694a2244b9@schoebel-theuer.de> <E4FA7972-B97C-4D63-8473-C6F1F4FAB7A0@cs.rutgers.edu>
 <alpine.DEB.2.20.1802222000470.2221@nuc-kabylake> <1B85435E-A9FB-47E7-A2FE-FE21632778F0@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

On Thu, 22 Feb 2018, Zi Yan wrote:

> Yes. I saw the attached patches. I am definitely going to apply them and see how they work out.
>
> In his last patch, there are a bunch of magic numbers used to reserve free page blocks
> at different orders. I think that is the most interesting part. If Thomas can share how
> to determine these numbers with his theory based on workloads, hardware/chipset, that would
> be a great guideline for sysadmins to take advantage of the patches.

These numbers are specific to the loads encountered in his situation and
the patches are specific to the machine configurations in his environment.

I have tried to generalize his idea and produce a patchset that is
reviewable and acceptable. I will update the patchset as needed.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
