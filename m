Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB0E46B0388
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 00:04:35 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 1so2010831pgz.5
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 21:04:35 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id k1si141407pgp.246.2017.02.21.21.04.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Feb 2017 21:04:34 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id z128so195143pgb.3
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 21:04:34 -0800 (PST)
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 22 Feb 2017 16:04:25 +1100
Subject: Re: [PATCH 0/6] Enable parallel page migration
Message-ID: <20170222050425.GB9967@balbir.ozlabs.ibm.com>
References: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu

On Fri, Feb 17, 2017 at 04:54:47PM +0530, Anshuman Khandual wrote:
> 	This patch series is base on the work posted by Zi Yan back in
> November 2016 (https://lkml.org/lkml/2016/11/22/457) but includes some
> amount clean up and re-organization. This series depends on THP migration
> optimization patch series posted by Naoya Horiguchi on 8th November 2016
> (https://lwn.net/Articles/705879/). Though Zi Yan has recently reposted
> V3 of the THP migration patch series (https://lwn.net/Articles/713667/),
> this series is yet to be rebased.
> 
> 	Primary motivation behind this patch series is to achieve higher
> bandwidth of memory migration when ever possible using multi threaded
> instead of a single threaded copy. Did all the experiments using a two
> socket X86 sytsem (Intel(R) Xeon(R) CPU E5-2650). All the experiments
> here have same allocation size 4K * 100000 (which did not split evenly
> for the 2MB huge pages). Here are the results.
> 
> Vanilla:
> 
> Moved 100000 normal pages in 247.000000 msecs 1.544412 GBs
> Moved 100000 normal pages in 238.000000 msecs 1.602814 GBs
> Moved 195 huge pages in 252.000000 msecs 1.513769 GBs
> Moved 195 huge pages in 257.000000 msecs 1.484318 GBs
> 
> THP migration improvements:
> 
> Moved 100000 normal pages in 302.000000 msecs 1.263145 GBs

Is there a decrease here for normal pages?

> Moved 100000 normal pages in 262.000000 msecs 1.455991 GBs
> Moved 195 huge pages in 120.000000 msecs 3.178914 GBs
> Moved 195 huge pages in 129.000000 msecs 2.957130 GBs
> 
> THP migration improvements + Multi threaded page copy:
> 
> Moved 100000 normal pages in 1589.000000 msecs 0.240069 GBs **

Ditto?

> Moved 100000 normal pages in 1932.000000 msecs 0.197448 GBs **
> Moved 195 huge pages in 54.000000 msecs 7.064254 GBs ***
> Moved 195 huge pages in 86.000000 msecs 4.435694 GBs ***
>

Could you also comment on the CPU utilization impact of these
patches. 

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
