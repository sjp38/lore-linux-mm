Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1FF726B0256
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 17:18:07 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id l68so6149210wml.0
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 14:18:07 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id wp6si7300144wjb.151.2016.03.10.14.18.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 14:18:05 -0800 (PST)
Date: Thu, 10 Mar 2016 17:16:52 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: clarify the uncharge_list() loop
Message-ID: <20160310221652.GA10884@cmpxchg.org>
References: <1457643015-8828-3-git-send-email-hannes@cmpxchg.org>
 <20160310133034.f566a14dfdfa058bf9891b42@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160310133034.f566a14dfdfa058bf9891b42@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Mar 10, 2016 at 01:30:34PM -0800, Andrew Morton wrote:
> 
> LGTM.  It's very late in the cycle so I'll queue all three for 4.6-rc1
> and I tagged the first two patches (not this one) for -stable
> backporting.

Sounds good, thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
