Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8DE3C6B0038
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 12:40:10 -0400 (EDT)
Received: by wiaa2 with SMTP id a2so38768306wia.0
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 09:40:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pj3si4787206wic.4.2015.03.27.09.40.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Mar 2015 09:40:08 -0700 (PDT)
Message-ID: <551587D3.3050200@suse.cz>
Date: Fri, 27 Mar 2015 17:39:47 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] mm, shmem: Add shmem resident memory accounting
References: <1424958666-18241-1-git-send-email-vbabka@suse.cz> <1424958666-18241-4-git-send-email-vbabka@suse.cz> <54EF34C5.1090007@redhat.com>
In-Reply-To: <54EF34C5.1090007@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>

On 02/26/2015 03:59 PM, Jerome Marchand wrote:
> On 02/26/2015 02:51 PM, Vlastimil Babka wrote:
>>  
>> +/* Optimized variant when page is already known not to be PageAnon */
>> +static inline int mm_counter_file(struct page *page)
> 
> Just a nitpick, but I don't like that name as it keeps the confusion we
> currently have between shmem and file backed pages. I'm not sure what
> other name to use though. mm_counter_shared() maybe? I'm not sure it is
> less confusing...

I think that's also confusing, but differently. Didn't come up with better name,
so leaving as it is for v2.

Thanks

> Jerome
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
