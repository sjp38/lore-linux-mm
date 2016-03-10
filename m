Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0F9056B0253
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 16:30:36 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fe3so60058742pab.1
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 13:30:36 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l27si8495025pfi.125.2016.03.10.13.30.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 13:30:35 -0800 (PST)
Date: Thu, 10 Mar 2016 13:30:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: memcontrol: clarify the uncharge_list() loop
Message-Id: <20160310133034.f566a14dfdfa058bf9891b42@linux-foundation.org>
In-Reply-To: <1457643015-8828-3-git-send-email-hannes@cmpxchg.org>
References: <1457643015-8828-3-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com


LGTM.  It's very late in the cycle so I'll queue all three for 4.6-rc1
and I tagged the first two patches (not this one) for -stable
backporting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
