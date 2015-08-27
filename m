Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id E39236B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 17:35:35 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so4363865wid.0
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 14:35:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p4si1088180wiz.86.2015.08.27.14.35.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Aug 2015 14:35:34 -0700 (PDT)
Subject: Re: [PATCH] mm, migrate: count pages failing all retries in vmstat
 and tracepoint
References: <1440685227-747-1-git-send-email-vbabka@suse.cz>
 <alpine.DEB.2.10.1508271401040.30543@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DF82AC.8010907@suse.cz>
Date: Thu, 27 Aug 2015 23:35:40 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1508271401040.30543@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On 27.8.2015 23:02, David Rientjes wrote:
> On Thu, 27 Aug 2015, Vlastimil Babka wrote:
> 
>> Migration tries up to 10 times to migrate pages that return -EAGAIN until it
>> gives up. If some pages fail all retries, they are counted towards the number
>> of failed pages that migrate_pages() returns. They should also be counted in
>> the /proc/vmstat pgmigrate_fail and in the mm_migrate_pages tracepoint.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Acked-by: David Rientjes <rientjes@google.com>

Thanks.

> I assume nothing else other than stats and tracepoints are affected by 
> this and this isn't a critical bugfix :)

Yep, no stable needed :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
