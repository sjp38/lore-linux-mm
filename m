Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id F1ACE6B0038
	for <linux-mm@kvack.org>; Fri,  6 Mar 2015 17:30:56 -0500 (EST)
Received: by oigh136 with SMTP id h136so20163208oig.1
        for <linux-mm@kvack.org>; Fri, 06 Mar 2015 14:30:56 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id v19si6808233oet.23.2015.03.06.14.30.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 06 Mar 2015 14:30:56 -0800 (PST)
Message-ID: <54FA2A8D.5090509@oracle.com>
Date: Fri, 06 Mar 2015 14:30:37 -0800
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] hugetlbfs: optionally reserve all fs pages at mount
 time
References: <1425432106-17214-1-git-send-email-mike.kravetz@oracle.com> <87lhj9ai5u.fsf@tassilo.jf.intel.com>
In-Reply-To: <87lhj9ai5u.fsf@tassilo.jf.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 03/06/2015 02:13 PM, Andi Kleen wrote:
> Mike Kravetz <mike.kravetz@oracle.com> writes:
>
>> hugetlbfs allocates huge pages from the global pool as needed.  Even if
>> the global pool contains a sufficient number pages for the filesystem
>> size at mount time, those global pages could be grabbed for some other
>> use.  As a result, filesystem huge page allocations may fail due to lack
>> of pages.
>
>
> What's the difference of this new option to simply doing
>
> mount -t hugetlbfs none /huge
> echo XXX > /proc/sys/vm/nr_hugepages

In the above sequence, it is still possible for another user/application
to allocate some (or all) of the XXX huge pages.  There is no guarantee
that users of the filesystem will get all XXX pages.

I see the use of the reserve option to be:
# Make sure there are XXX huge pages in the global pool
echo XXX > /proc/sys/vm/nr_hugepages
# Mount/create the filesystem and reserve XXX huge pages
mount -t hugetlbfs -o size=XXX,reserve=XXX none /huge

If the mount is successful, then users of the filesystem know their are
XXX huge pages available for their use.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
