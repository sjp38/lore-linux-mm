Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9DEA26B0038
	for <linux-mm@kvack.org>; Tue, 16 May 2017 12:52:20 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u187so139469939pgb.0
        for <linux-mm@kvack.org>; Tue, 16 May 2017 09:52:20 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id e19si14394059pgk.199.2017.05.16.09.52.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 09:52:19 -0700 (PDT)
Subject: Re: [PATCH RFC] hugetlbfs 'noautofill' mount option
References: <326e38dd-b4a8-e0ca-6ff7-af60e8045c74@oracle.com>
 <b0efc671-0d7a-0aef-5646-a635478c31b0@oracle.com>
 <7ff6fb32-7d16-af4f-d9d5-698ab7e9e14b@intel.com>
 <03127895-3c5a-5182-82de-3baa3116749e@oracle.com>
 <22557bf3-14bb-de02-7b1b-a79873c583f1@intel.com>
 <7677d20e-5d53-1fb7-5dac-425edda70b7b@oracle.com>
 <48a544c4-61b3-acaf-0386-649f073602b6@intel.com>
 <476ea1b6-36d1-bc86-fa99-b727e3c2650d@oracle.com>
 <20170509085825.GB32555@infradead.org>
 <1031e0d4-cdbb-db8b-dae7-7c733921e20e@oracle.com>
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Message-ID: <b189b36e-8cd0-cf59-ba6c-8bd7412b11b7@oracle.com>
Date: Tue, 16 May 2017 09:51:40 -0700
MIME-Version: 1.0
In-Reply-To: <1031e0d4-cdbb-db8b-dae7-7c733921e20e@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>



On 5/9/17 1:59 PM, Prakash Sangappa wrote:
>
>
> On 5/9/17 1:58 AM, Christoph Hellwig wrote:
>> On Mon, May 08, 2017 at 03:12:42PM -0700, prakash.sangappa wrote:
>>> Regarding #3 as a general feature, do we want to
>>> consider this and the complexity associated with the
>>> implementation?
>> We have to.  Given that no one has exclusive access to hugetlbfs
>> a mount option is fundamentally the wrong interface.
>
>
> A hugetlbfs filesystem may need to be mounted for exclusive use by
> an application. Note, recently the 'min_size' mount option was added
> to hugetlbfs, which would reserve minimum number of huge pages
> for that filesystem for use by an application. If the filesystem with
> min size specified, is not setup for exclusive use by an application,
> then the purpose of reserving huge pages is defeated.  The
> min_size option was for use by applications like the database.
>
> Also, I am investigating enabling hugetlbfs mounts within user
> namespace's mount namespace. That would allow an application
> to mount a hugetlbfs filesystem inside a namespace exclusively for
> its use, running as a non root user. For this it seems like the 
> 'min_size'
> should be subject to some user limits. Anyways, mounting inside
> user namespaces is  a different discussion.
>
> So, if a filesystem has to be setup for exclusive use by an application,
> then different mount options can be used for that filesystem.
>

Any further comments?

Cc'ing Andrea as we had discussed this requirement for the Database.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
