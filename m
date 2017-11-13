Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1DBB06B025F
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 13:11:40 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id w125so9026801qkb.17
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 10:11:40 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id w7si8082720qtk.223.2017.11.13.10.11.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Nov 2017 10:11:39 -0800 (PST)
Date: Mon, 13 Nov 2017 18:11:12 +0000
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm: show stats for non-default hugepage sizes in
 /proc/meminfo
Message-ID: <20171113181105.GA27034@castle>
References: <20171113160302.14409-1-guro@fb.com>
 <8aa63aee-cbbb-7516-30cf-15fcf925060b@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <8aa63aee-cbbb-7516-30cf-15fcf925060b@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Mon, Nov 13, 2017 at 09:06:32AM -0800, Dave Hansen wrote:
> On 11/13/2017 08:03 AM, Roman Gushchin wrote:
> > To solve this problem, let's display stats for all hugepage sizes.
> > To provide the backward compatibility let's save the existing format
> > for the default size, and add a prefix (e.g. 1G_) for non-default sizes.
> 
> Is there something keeping you from using the sysfs version of this
> information?

Just answered the same question to Michal.

In two words: it would be nice to have a high-level overview of
memory usage in the system in /proc/meminfo. 

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
