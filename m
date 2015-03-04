Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7B5806B00A6
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 12:21:43 -0500 (EST)
Received: by obbnt9 with SMTP id nt9so8311769obb.3
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 09:21:43 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id s7si2492033obd.35.2015.03.04.09.21.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Mar 2015 09:21:42 -0800 (PST)
Message-ID: <54F73F1C.4050601@oracle.com>
Date: Wed, 04 Mar 2015 09:21:32 -0800
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] hugetlbfs: optionally reserve all fs pages at mount
 time
References: <1425432106-17214-1-git-send-email-mike.kravetz@oracle.com> <alpine.DEB.2.10.1503032145110.12253@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1503032145110.12253@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 03/03/2015 09:49 PM, David Rientjes wrote:
> On Tue, 3 Mar 2015, Mike Kravetz wrote:
>> Add a new hugetlbfs mount option 'reserved' to specify that the number
>> of pages associated with the size of the filesystem will be reserved.  If
>> there are insufficient pages, the mount will fail.  The reservation is
>> maintained for the duration of the filesystem so that as pages are
>> allocated and free'ed a sufficient number of pages remains reserved.
>>
>
> This functionality is somewhat limited because it's not possible to
> reserve a subset of the size for a single mount point, it's either all or
> nothing.  It shouldn't be too difficult to just add a reserved=<value>
> option where <value> is <= size.  If it's done that way, you should be
> able to omit size= entirely for unlimited hugepages but always ensure that
> a low watermark of hugepages are reserved for the database.

Thanks, I like that suggestion.  You are correct in that it should not
be too difficult to pass in a size for reserved.  I'll work on the
modification.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
