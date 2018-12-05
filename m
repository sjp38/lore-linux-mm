Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B47C6B7390
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 04:20:40 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id l45so9585671edb.1
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 01:20:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id fx12-v6sor5553178ejb.6.2018.12.05.01.20.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 01:20:38 -0800 (PST)
Date: Wed, 5 Dec 2018 09:20:37 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 1/2] admin-guide/memory-hotplug.rst: remove locking
 internal part from admin-guide
Message-ID: <20181205092037.ks2uxvfasgqbd2oz@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181205023426.24029-1-richard.weiyang@gmail.com>
 <c4f2a712-391b-60b9-64fa-bc8b6bde9994@redhat.com>
 <20181205083012.GA19181@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181205083012.GA19181@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: David Hildenbrand <david@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, osalvador@suse.de, akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Mike Rapoport <rppt@linux.vnet.ibm.com>

On Wed, Dec 05, 2018 at 10:30:13AM +0200, Mike Rapoport wrote:
>On Wed, Dec 05, 2018 at 09:03:24AM +0100, David Hildenbrand wrote:
>> On 05.12.18 03:34, Wei Yang wrote:
>> > Locking Internal section exists in core-api documentation, which is more
>> > suitable for this.
>> > 
>> > This patch removes the duplication part here.
>> > 
>> > Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> > ---
>> >  Documentation/admin-guide/mm/memory-hotplug.rst | 40 -------------------------
>> >  1 file changed, 40 deletions(-)
>> > 
>> > diff --git a/Documentation/admin-guide/mm/memory-hotplug.rst b/Documentation/admin-guide/mm/memory-hotplug.rst
>> > index 5c4432c96c4b..241f4ce1e387 100644
>> > --- a/Documentation/admin-guide/mm/memory-hotplug.rst
>> > +++ b/Documentation/admin-guide/mm/memory-hotplug.rst
>> > @@ -392,46 +392,6 @@ Need more implementation yet....
>> >   - Notification completion of remove works by OS to firmware.
>> >   - Guard from remove if not yet.
>
>[ ... ]
>
>> >  Future Work
>> >  ===========
>> >  
>> > 
>> 
>> I reported this yesterday to Jonathan and Mike
>> 
>> https://lkml.org/lkml/2018/12/3/340
>
>Somehow I've missed it...
> 
>> Anyhow
>> 
>> Reviewed-by: David Hildenbrand <david@redhat.com>
>
>Acked-by: Mike Rapoport <rppt@linux.ibm.com>
>

Thanks :-)

>> 
>> -- 
>> 
>> Thanks,
>> 
>> David / dhildenb
>> 
>
>-- 
>Sincerely yours,
>Mike.

-- 
Wei Yang
Help you, Help me
