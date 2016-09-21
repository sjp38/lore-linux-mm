Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 001556B0264
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 05:49:12 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w84so37386857wmg.1
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 02:49:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x188si16478960wmx.16.2016.09.21.02.49.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Sep 2016 02:49:11 -0700 (PDT)
Subject: Re: [PATCH 0/1] memory offline issues with hugepage size > memory
 block size
References: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>
 <bc000c05-3186-da92-e868-f2dbf0c28a98@oracle.com>
 <57E175B3.1040802@linux.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <147658a7-bf29-d2db-a4b6-f8638f973ba7@suse.cz>
Date: Wed, 21 Sep 2016 11:49:09 +0200
MIME-Version: 1.0
In-Reply-To: <57E175B3.1040802@linux.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Mike Kravetz <mike.kravetz@oracle.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>

On 09/20/2016 07:45 PM, Dave Hansen wrote:
> On 09/20/2016 10:37 AM, Mike Kravetz wrote:
>>
>> Their approach (I believe) would be to fail the offline operation in
>> this case.  However, I could argue that failing the operation, or
>> dissolving the unused huge page containing the area to be offlined is
>> the right thing to do.
>
> I think the right thing to do is dissolve the whole huge page if even a
> part of it is offlined.  The only question is what to do with the
> gigantic remnants.

Just free them into the buddy system? Or what are the alternatives? 
Creating smaller huge pages (if supported)? That doesn't make much 
sense. Offline it completely? That's probably not what the user requested.

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
