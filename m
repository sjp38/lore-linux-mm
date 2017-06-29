Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3B06B0279
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 17:47:16 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id m19so18703412ioe.12
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 14:47:16 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id h135si9409956ith.25.2017.06.29.14.47.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 14:47:15 -0700 (PDT)
Reply-To: prakash.sangappa@oracle.com
Subject: Re: [RFC PATCH] userfaultfd: Add feature to request for a signal
 delivery
References: <9363561f-a9cd-7ab6-9c11-ab9a99dc89f1@oracle.com>
 <20170627070643.GA28078@dhcp22.suse.cz> <20170627153557.GB10091@rapoport-lnx>
 <51508e99-d2dd-894f-8d8a-678e3747c1ee@oracle.com>
 <20170628131806.GD10091@rapoport-lnx>
 <3a8e0042-4c49-3ec8-c59f-9036f8e54621@oracle.com>
 <20170629104605.GA24911@rapoport-lnx>
From: "prakash.sangappa" <prakash.sangappa@oracle.com>
Message-ID: <64c1f66e-95ca-7abb-6e22-44209ff7c73f@oracle.com>
Date: Thu, 29 Jun 2017 14:49:01 -0700
MIME-Version: 1.0
In-Reply-To: <20170629104605.GA24911@rapoport-lnx>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Dave Hansen <dave.hansen@intel.com>, Christoph Hellwig <hch@infradead.org>, linux-api@vger.kernel.org



On 06/29/2017 03:46 AM, Mike Rapoport wrote:
> On Wed, Jun 28, 2017 at 11:23:32AM -0700, Prakash Sangappa wrote:
[...]
>>
>> Will this result in a signal delivery?
>>
>> In the use case described, the database application does not need any event
>> for  hole punching. Basically, just a signal for any invalid access to
>> mapped
>> area over holes in the file.
>   
> Well, what I had in mind was using a single-process uffd monitor that will
> track all the userfault file descriptors. With UFFD_EVENT_REMOVE this
> process will know what areas are invalid and it will be able to process the
> invalid access in any way it likes, e.g. send SIGBUS to the database
> application.


Use of a monitor process is also an overhead for the database.


>
> If you mmap() and userfaultfd_register() only at the initialization time,
> it might be also possible to avoid sending userfault file descriptors to
> the monitor process with UFFD_FEATURE_EVENT_FORK.

The new processes are always exec'd in the database case and these
processes could be mapping different files. So, not sure if
UFFD_FEATURE_EVENT_FORK will be useful.  Also, it may not be one
process spawning the other new processes.


>
> --
> Sincerely yours,
> Mike.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
