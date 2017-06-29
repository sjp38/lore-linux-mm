Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id CDB466B0279
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 17:40:07 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id p77so18584462ioo.13
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 14:40:07 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id v97si5666200ioi.180.2017.06.29.14.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 14:40:06 -0700 (PDT)
Reply-To: prakash.sangappa@oracle.com
Subject: Re: [RFC PATCH] userfaultfd: Add feature to request for a signal
 delivery
References: <9363561f-a9cd-7ab6-9c11-ab9a99dc89f1@oracle.com>
 <20170627070643.GA28078@dhcp22.suse.cz> <20170627153557.GB10091@rapoport-lnx>
 <51508e99-d2dd-894f-8d8a-678e3747c1ee@oracle.com>
 <20170628131806.GD10091@rapoport-lnx>
 <3a8e0042-4c49-3ec8-c59f-9036f8e54621@oracle.com>
 <20170629080910.GC31603@dhcp22.suse.cz>
From: "prakash.sangappa" <prakash.sangappa@oracle.com>
Message-ID: <936bde7b-1913-5589-22f4-9bbfdb6a8dd5@oracle.com>
Date: Thu, 29 Jun 2017 14:41:22 -0700
MIME-Version: 1.0
In-Reply-To: <20170629080910.GC31603@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Dave Hansen <dave.hansen@intel.com>, Christoph Hellwig <hch@infradead.org>, linux-api@vger.kernel.org



On 06/29/2017 01:09 AM, Michal Hocko wrote:
> On Wed 28-06-17 11:23:32, Prakash Sangappa wrote:
>>
>> On 6/28/17 6:18 AM, Mike Rapoport wrote:
> [...]
>>> I've just been thinking that maybe it would be possible to use
>>> UFFD_EVENT_REMOVE for this case. We anyway need to implement the generation
>>> of UFFD_EVENT_REMOVE for the case of hole punching in hugetlbfs for
>>> non-cooperative userfaultfd. It could be that it will solve your issue as
>>> well.
>>>
>> Will this result in a signal delivery?
>>
>> In the use case described, the database application does not need any event
>> for  hole punching. Basically, just a signal for any invalid access to
>> mapped area over holes in the file.
> OK, but it would be better to think that through for other potential
> usecases so that this doesn't end up as a single hugetlb feature. E.g.
> what should happen if a regular anonymous memory gets swapped out?
> Should we deliver signal as well? How does userspace tell whether this
> was a no backing page from unavailable backing page?

This may not be useful in all cases. Potential, it could be used
with use of mlock() on anonymous memory to ensure any access
to memory that is not locked is caught, again for robustness
purpose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
