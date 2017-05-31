Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D2F156B02C3
	for <linux-mm@kvack.org>; Wed, 31 May 2017 11:58:52 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id g13so3801507wmd.9
        for <linux-mm@kvack.org>; Wed, 31 May 2017 08:58:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g185si31355163wme.137.2017.05.31.08.58.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 May 2017 08:58:51 -0700 (PDT)
Date: Wed, 31 May 2017 08:58:39 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [RFC v2 02/10] mm: Remove nest locking operation with mmap_sem
Message-ID: <20170531155839.GB28615@linux-80c1.suse>
References: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1495624801-8063-3-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <1495624801-8063-3-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, Andi Kleen <andi@firstfloor.org>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

On Wed, 24 May 2017, Laurent Dufour wrote:

>The range locking framework doesn't yet provide nest locking
>operation.
>
>Once the range locking API while provide nested operation support,
>this patch will have to be reviewed.

Please note that we already have range_write_lock_nest_lock().

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
