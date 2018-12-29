Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id BD3448E005B
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 16:26:23 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id o17so22181072pgi.14
        for <linux-mm@kvack.org>; Sat, 29 Dec 2018 13:26:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u10sor8051452pgr.25.2018.12.29.13.26.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 29 Dec 2018 13:26:22 -0800 (PST)
Date: Sat, 29 Dec 2018 15:26:19 -0600
From: Dennis Zhou <dennis@kernel.org>
Subject: Re: [PATCH] percpu: plumb gfp flag to pcpu_get_pages
Message-ID: <20181229212619.GB73871@dennisz-mbp>
References: <20181229013147.211079-1-shakeelb@google.com>
 <20181229130352.8a1075da5b7583d5e0e4aa9a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181229130352.8a1075da5b7583d5e0e4aa9a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shakeel Butt <shakeelb@google.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Andrew,

On Sat, Dec 29, 2018 at 01:03:52PM -0800, Andrew Morton wrote:
> On Fri, 28 Dec 2018 17:31:47 -0800 Shakeel Butt <shakeelb@google.com> wrote:
> 
> > __alloc_percpu_gfp() can be called from atomic context, so, make
> > pcpu_get_pages use the gfp provided to the higher layer.
> 
> Does this fix any user-visible issues?

Sorry for not getting to this earlier. I'm currently traveling. I
respoeded on the patch itself. Do you mind unqueuing? I explain in more
detail on the patch, but __alloc_percpu_gfp() will never call
pcpu_get_pages() when called as not GFP_KERNEL.

Thanks,
Dennis
