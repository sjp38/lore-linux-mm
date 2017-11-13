Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1EF296B0033
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 12:06:36 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 192so11086643pgd.18
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 09:06:36 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id w10si13688138pgp.597.2017.11.13.09.06.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Nov 2017 09:06:35 -0800 (PST)
Subject: Re: [PATCH] mm: show stats for non-default hugepage sizes in
 /proc/meminfo
References: <20171113160302.14409-1-guro@fb.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <8aa63aee-cbbb-7516-30cf-15fcf925060b@intel.com>
Date: Mon, 13 Nov 2017 09:06:32 -0800
MIME-Version: 1.0
In-Reply-To: <20171113160302.14409-1-guro@fb.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On 11/13/2017 08:03 AM, Roman Gushchin wrote:
> To solve this problem, let's display stats for all hugepage sizes.
> To provide the backward compatibility let's save the existing format
> for the default size, and add a prefix (e.g. 1G_) for non-default sizes.

Is there something keeping you from using the sysfs version of this
information?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
