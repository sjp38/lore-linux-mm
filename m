Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4EA736B0069
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 14:31:28 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id y5so17835618pgq.15
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 11:31:28 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id w15si5436612pgc.761.2017.11.13.11.31.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Nov 2017 11:31:27 -0800 (PST)
Subject: Re: [PATCH] mm: show stats for non-default hugepage sizes in
 /proc/meminfo
References: <20171113160302.14409-1-guro@fb.com>
 <8aa63aee-cbbb-7516-30cf-15fcf925060b@intel.com>
 <20171113181105.GA27034@castle>
 <c716ac71-f467-dcbe-520f-91b007309a4d@intel.com>
 <2579a26d-81d1-732e-ef57-33bb4c293cd6@oracle.com>
 <20171113184454.GA18531@castle> <20171113191056.GA28749@cmpxchg.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <940679cd-b044-707d-a693-e360cf8623b5@intel.com>
Date: Mon, 13 Nov 2017 11:31:14 -0800
MIME-Version: 1.0
In-Reply-To: <20171113191056.GA28749@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On 11/13/2017 11:10 AM, Johannes Weiner wrote:
> Maybe a simple summary counter for everything set aside by the hugetlb
> subsystem - default and non-default page sizes, whether they're used
> or only reserved etc.?

Yeah, one line is a lot more sane than 5 lines times all the extra
sizes.  It'll just be a matter of bikeshedding the name and whether it
should include the default pages being consumed or not.  I vote for:

	Hugetlb: "/sysfs FTW!" kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
