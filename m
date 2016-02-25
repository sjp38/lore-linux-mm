Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 16D686B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 08:48:54 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id a4so28332291wme.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 05:48:54 -0800 (PST)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id dc4si9925045wjc.52.2016.02.25.05.48.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 05:48:52 -0800 (PST)
Received: by mail-wm0-f46.google.com with SMTP id g62so28454480wme.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 05:48:52 -0800 (PST)
Date: Thu, 25 Feb 2016 14:48:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: remove __GFP_NOFAIL is deprecated comment
Message-ID: <20160225134850.GA4204@dhcp22.suse.cz>
References: <1456397002-27172-1-git-send-email-mhocko@kernel.org>
 <56CEE72B.5040009@kyup.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56CEE72B.5040009@kyup.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 25-02-16 13:36:11, Nikolay Borisov wrote:
[...]
> > +		/*
> > +		 * We most definitely don't want callers attempting to
> > +		 * allocate greater than order-1 page units with __GFP_NOFAIL.
> > +		 */
> > +		WARN_ON_ONCE(unlikely(gfp_flags & __GFP_NOFAIL) && (order > 1));
> 
> WARN_ON_ONCE already includes an unlikely in its definition:
> http://lxr.free-electrons.com/source/include/asm-generic/bug.h#L109

OK, I just wanted to keep the condition untouched but you are right the
unlikely can be removed.

> Reviewed-by: Nikolay Borisov <kernel@kyup.com>

Thanks!
---
