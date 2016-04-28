Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0037F6B025F
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 11:37:34 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id s184so61540459vkb.3
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 08:37:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l132si5243732qhc.62.2016.04.28.08.37.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 08:37:33 -0700 (PDT)
Date: Thu, 28 Apr 2016 11:37:31 -0400
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: [PATCH 19/20] md: simplify free_params for kmalloc vs vmalloc
 fallback
Message-ID: <20160428153730.GA14570@redhat.com>
References: <1461849846-27209-1-git-send-email-mhocko@kernel.org>
 <1461849846-27209-20-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461849846-27209-20-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mikulas Patocka <mpatocka@redhat.com>, Shaohua Li <shli@kernel.org>

On Thu, Apr 28 2016 at  9:24am -0400,
Michal Hocko <mhocko@kernel.org> wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> Use kvfree rather than DM_PARAMS_[KV]MALLOC specific param flags.
> 
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Mikulas Patocka <mpatocka@redhat.com>
> Cc: dm-devel@redhat.com
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Nack, seriously, this is the 3rd time this patch has been attempted.
Did you actually test the change?  It'll crash very quickly, see:

https://www.redhat.com/archives/dm-devel/2016-April/msg00103.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
