Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 210F76B0081
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 11:46:17 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id up15so8367508pbc.38
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 08:46:16 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id xa2si31167422pab.113.2013.11.26.08.46.14
        for <linux-mm@kvack.org>;
        Tue, 26 Nov 2013 08:46:15 -0800 (PST)
Date: Tue, 26 Nov 2013 08:46:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Devel] [PATCH v11 00/15] kmemcg shrinkers
Message-Id: <20131126084644.405a091d.akpm@linux-foundation.org>
In-Reply-To: <52949A4F.7030004@parallels.com>
References: <cover.1385377616.git.vdavydov@parallels.com>
	<20131125174135.GE22729@cmpxchg.org>
	<529443E4.7080602@parallels.com>
	<52949A4F.7030004@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, glommer@openvz.org, mhocko@suse.cz, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org

On Tue, 26 Nov 2013 16:55:43 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:

> What do you think about splitting this set into two main series as follows:
> 
> 1) Prepare vmscan to kmemcg-aware shrinkers; would include patches 1-7 
> of this set.
> 2) Make fs shrinkers memcg-aware; would include patches 9-11 of this set

Please just resend everything.

> and leave other patches, which are rather for optimization/extending 
> functionality, for future?

It will be helpful to describe such splitting opportunities in the
[0/n] changelog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
