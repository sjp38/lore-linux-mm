Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6B0086B0313
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:49:16 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c23so182422479pfe.11
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 04:49:16 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 75si3944372pfr.248.2017.07.26.04.49.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 04:49:15 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6QBmwIK120351
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:49:15 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bxr7wq95y-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:49:14 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Wed, 26 Jul 2017 12:49:12 +0100
Date: Wed, 26 Jul 2017 13:49:03 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [RFC PATCH 3/5] mm, memory_hotplug: allocate memmap from the
 added memory range for sparse-vmemmap
References: <20170726083333.17754-1-mhocko@kernel.org>
 <20170726083333.17754-4-mhocko@kernel.org>
 <20170726114539.GG3218@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726114539.GG3218@osiris>
Message-Id: <20170726114903.GI3218@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dan Williams <dan.j.williams@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

On Wed, Jul 26, 2017 at 01:45:39PM +0200, Heiko Carstens wrote:
> > Please note that only the memory hotplug is currently using this
> > allocation scheme. The boot time memmap allocation could use the same
> > trick as well but this is not done yet.
> 
> Which kernel are these patches based on? I tried linux-next and Linus'
> vanilla tree, however the series does not apply.

I found the answer to this question in the meantime.. sorry ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
