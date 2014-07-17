Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8095A6B0035
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 23:57:50 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id l18so1766739wgh.13
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 20:57:49 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id er6si23727898wib.22.2014.07.16.20.57.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 20:57:49 -0700 (PDT)
Date: Wed, 16 Jul 2014 23:57:40 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, writeback: prevent race when calculating dirty limits
Message-ID: <20140717035740.GE29639@cmpxchg.org>
References: <alpine.DEB.2.02.1407161733200.23892@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1407161733200.23892@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jul 16, 2014 at 05:36:49PM -0700, David Rientjes wrote:
> Setting vm_dirty_bytes and dirty_background_bytes is not protected by any 
> serialization.
> 
> Therefore, it's possible for either variable to change value after the 
> test in global_dirty_limits() to determine whether available_memory needs 
> to be initialized or not.
> 
> Always ensure that available_memory is properly initialized.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: David Rientjes <rientjes@google.com>

Any such race should be barely noticable to the user, so I assume you
realized this while looking at the code?  The patch looks good, but I
don't see that it's stable material.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
