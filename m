Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3486C6B0038
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 07:39:04 -0400 (EDT)
Received: by wibhh20 with SMTP id hh20so19871337wib.0
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 04:39:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i5si5266789wja.87.2015.08.05.04.39.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 04:39:02 -0700 (PDT)
Subject: Re: [PATCH v2] mm: show proportional swap share of the mapping
References: <1434373614-1041-1-git-send-email-minchan@kernel.org>
 <55B88FF1.7050502@redhat.com> <20150729102849.GA19352@bgram>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55C1F5D0.3010603@suse.cz>
Date: Wed, 5 Aug 2015 13:38:56 +0200
MIME-Version: 1.0
In-Reply-To: <20150729102849.GA19352@bgram>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Jerome Marchand <jmarchan@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Bongkyu Kim <bongkyu.kim@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Jonathan Corbet <corbet@lwn.net>

On 07/29/2015 12:30 PM, Minchan Kim wrote:
>> This won't work for sysV shm, tmpfs and MAP_SHARED | MAP_ANONYMOUS
>> mapping pages which are pte_none when paged out. They're currently not
>> accounted at all when in swap.
>
> This patch doesn't handle those pages because we don't have supported
> thoses pages. IMHO, if someone need it, it should be another patch and
> he can contribute it in future.

OK, time to try again...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
