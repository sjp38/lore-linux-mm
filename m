Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2F36B71A3
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 20:05:39 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id b8so15440271pfe.10
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 17:05:39 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id f2si17952977plt.101.2018.12.04.17.05.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 17:05:38 -0800 (PST)
Subject: Re: [PATCH 0/2] put_user_page*(): start converting the call sites
References: <20181204001720.26138-1-jhubbard@nvidia.com>
 <b31c7b3359344e778fc525013eeece64@AcuMS.aculab.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <cfba998a-8217-bf03-f0d0-c95708aea03d@nvidia.com>
Date: Tue, 4 Dec 2018 17:05:36 -0800
MIME-Version: 1.0
In-Reply-To: <b31c7b3359344e778fc525013eeece64@AcuMS.aculab.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>, "'john.hubbard@gmail.com'" <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Jan Kara <jack@suse.cz>, Tom Talpey <tom@talpey.com>, Al Viro <viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Ralph Campbell <rcampbell@nvidia.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

On 12/4/18 9:10 AM, David Laight wrote:
> From: john.hubbard@gmail.com
>> Sent: 04 December 2018 00:17
>>
>> Summary: I'd like these two patches to go into the next convenient cycle.
>> I *think* that means 4.21.
>>
>> Details
>>
>> At the Linux Plumbers Conference, we talked about this approach [1], and
>> the primary lingering concern was over performance. Tom Talpey helped me
>> through a much more accurate run of the fio performance test, and now
>> it's looking like an under 1% performance cost, to add and remove pages
>> from the LRU (this is only paid when dealing with get_user_pages) [2]. So
>> we should be fine to start converting call sites.
>>
>> This patchset gets the conversion started. Both patches already had a fair
>> amount of review.
> 
> Shouldn't the commit message contain actual details of the change?
> 

Hi David,

This "patch 0000" is not a commit message, as it never shows up in git log.
Each of the follow-up patches does have details about the changes it makes.

But maybe you are really asking for more background information, which I
should have added in this cover letter. Here's a start:

https://lore.kernel.org/r/20181110085041.10071-1-jhubbard@nvidia.com

...and it looks like this small patch series is not going to work out--I'm
going to have to fall back to another RFC spin. So I'll be sure to include 
you and everyone on that. Hope that helps.

thanks,
-- 
John Hubbard
NVIDIA
