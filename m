Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f45.google.com (mail-lf0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 253206B0259
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 04:10:59 -0500 (EST)
Received: by lfs39 with SMTP id 39so29872967lfs.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 01:10:58 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id j78si3987911lfi.123.2015.12.09.01.10.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 01:10:57 -0800 (PST)
Date: Wed, 9 Dec 2015 12:10:39 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 3/8] mm: memcontrol: give the kmem states more
 descriptive names
Message-ID: <20151209091038.GM11488@esperanza>
References: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
 <1449599665-18047-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1449599665-18047-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Dec 08, 2015 at 01:34:20PM -0500, Johannes Weiner wrote:
> On any given memcg, the kmem accounting feature has three separate
> states: not initialized, structures allocated, and actively accounting
> slab memory. These are represented through a combination of the
> kmem_acct_activated and kmem_acct_active flags, which is confusing.
> 
> Convert to a kmem_state enum with the states NONE, ALLOCATED, and
> ONLINE. Then rename the functions to modify the state accordingly.
> This follows the nomenclature of css object states more closely.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
