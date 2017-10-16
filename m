Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id E1B876B0038
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 17:18:58 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id r18so17142255qkh.9
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 14:18:58 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d18si3269493qkc.392.2017.10.16.14.18.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 14:18:57 -0700 (PDT)
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
References: <f4a46a19-5f71-ebcc-3098-a35728fbfd03@oracle.com>
 <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake>
 <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131040570.4247@nuc-kabylake>
 <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131053450.4400@nuc-kabylake>
 <20171013161736.htumyr4cskfrjq64@dhcp22.suse.cz>
 <752b49eb-55c6-5a34-ab41-6e91dd93ea70@mellanox.com>
 <aff6b405-6a06-f84d-c9b1-c6fb166dff81@oracle.com>
 <20171016180749.2y2v4ucchb33xnde@dhcp22.suse.cz>
 <e8cf6227-003d-8a82-8b4d-07176b43810c@oracle.com>
 <4994fc18-f0ee-300d-d61f-c1a1b63e55e4@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <a66f521b-d1d8-6508-dd25-ae9bd7fc58af@oracle.com>
Date: Mon, 16 Oct 2017 14:18:49 -0700
MIME-Version: 1.0
In-Reply-To: <4994fc18-f0ee-300d-d61f-c1a1b63e55e4@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Michal Hocko <mhocko@kernel.org>
Cc: Guy Shattah <sguy@mellanox.com>, Christopher Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>

On 10/16/2017 02:03 PM, Laura Abbott wrote:
> On 10/16/2017 01:32 PM, Mike Kravetz wrote:
>> On 10/16/2017 11:07 AM, Michal Hocko wrote:
>>> On Mon 16-10-17 10:43:38, Mike Kravetz wrote:
>>>> Just to be clear, the posix standard talks about a typed memory object.
>>>> The suggested implementation has one create a connection to the memory
>>>> object to receive a fd, then use mmap as usual to get a mapping backed
>>>> by contiguous pages/memory.  Of course, this type of implementation is
>>>> not a requirement.
>>>
>>> I am not sure that POSIC standard for typed memory is easily
>>> implementable in Linux. Does any OS actually implement this API?
>>
>> A quick search only reveals Blackberry QNX and PlayBook OS.
>>
>> Also somewhat related.  In a earlier thread someone pointed out this
>> out of tree module used for contiguous allocations in SOC (and other?)
>> environments.  It even has the option of making use of CMA.
>> http://processors.wiki.ti.com/index.php/CMEM_Overview
>>
> 
> If we're at the point where we're discussing CMEM, I'd like to
> point out that ion (drivers/staging/android/ion) already provides an
> ioctl interface to allocate CMA and other types of memory. It's
> mostly used for Android as the name implies. I don't pretend the
> interface is perfect but it could be useful as a discussion point
> for allocation interfaces.

Thanks Laura,

I was just pointing out other use cases where people thought contiguous
allocations were useful.  And, it was useful enough that someone actually
wrote code to make it happen.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
