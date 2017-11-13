Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id F0BDA6B0033
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 13:45:32 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id q45so2687776qtq.21
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 10:45:32 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id w62si10220852qtd.403.2017.11.13.10.45.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Nov 2017 10:45:32 -0800 (PST)
Date: Mon, 13 Nov 2017 18:45:01 +0000
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm: show stats for non-default hugepage sizes in
 /proc/meminfo
Message-ID: <20171113184454.GA18531@castle>
References: <20171113160302.14409-1-guro@fb.com>
 <8aa63aee-cbbb-7516-30cf-15fcf925060b@intel.com>
 <20171113181105.GA27034@castle>
 <c716ac71-f467-dcbe-520f-91b007309a4d@intel.com>
 <2579a26d-81d1-732e-ef57-33bb4c293cd6@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <2579a26d-81d1-732e-ef57-33bb4c293cd6@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Mon, Nov 13, 2017 at 10:30:10AM -0800, Mike Kravetz wrote:
> On 11/13/2017 10:17 AM, Dave Hansen wrote:
> > On 11/13/2017 10:11 AM, Roman Gushchin wrote:
> >> On Mon, Nov 13, 2017 at 09:06:32AM -0800, Dave Hansen wrote:
> >>> On 11/13/2017 08:03 AM, Roman Gushchin wrote:
> >>>> To solve this problem, let's display stats for all hugepage sizes.
> >>>> To provide the backward compatibility let's save the existing format
> >>>> for the default size, and add a prefix (e.g. 1G_) for non-default sizes.
> >>>
> >>> Is there something keeping you from using the sysfs version of this
> >>> information?
> >>
> >> Just answered the same question to Michal.
> >>
> >> In two words: it would be nice to have a high-level overview of
> >> memory usage in the system in /proc/meminfo. 
> > 
> > I don't think it's worth cluttering up meminfo for this, imnho.
> 
> I tend to agree that it would be better not to add additional huge page
> sizes here.  It may not seem too intrusive to (potentially) add one extra
> set of entries for GB huge pages on x86.  However, other architectures
> such as powerpc or sparc have several several huge pages sizes that could
> potentially be added here as well.  Although, in practice one does tend
> to use a single huge pages size.  If you change the default huge page
> size, then those entries will be in /proc/meminfo.

I do agree that it might add some unnecessary verbosity if these sizes
are not used, but if they are, this information is super-useful.
So, might be a conditional printing will work here?

Or, at least, some total counter, e.g. how much memory is consumed
by hugetlb pages?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
