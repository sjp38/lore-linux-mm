Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 47DF36B0038
	for <linux-mm@kvack.org>; Thu, 14 May 2015 07:16:11 -0400 (EDT)
Received: by wguv19 with SMTP id v19so9589248wgu.1
        for <linux-mm@kvack.org>; Thu, 14 May 2015 04:16:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id co6si4618044wib.43.2015.05.14.04.16.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 May 2015 04:16:09 -0700 (PDT)
Message-ID: <555483F6.3080607@suse.cz>
Date: Thu, 14 May 2015 13:16:06 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/4] enhance shmem process and swap accounting
References: <1427474441-17708-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <1427474441-17708-1-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On 03/27/2015 05:40 PM, Vlastimil Babka wrote:
> Changes since v1:
> o In Patch 2, rely on SHMEM_I(inode)->swapped if possible, and fallback to
>    radix tree iterator on partially mapped shmem objects, i.e. decouple shmem
>    swap usage determination from the page walk, for performance reasons.
>    Thanks to Jerome and Konstantin for the tips.
>    The downside is that mm/shmem.c had to be touched.
>

Ping? I've got only a minor suggestion from Konstantin and no more 
feedback. Hugh?

Thanks,
Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
