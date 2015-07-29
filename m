Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id EB8876B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 17:30:17 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so11583280pac.3
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 14:30:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e2si41839207pdd.99.2015.07.29.14.30.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 14:30:16 -0700 (PDT)
Date: Wed, 29 Jul 2015 14:30:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm v9 0/8] idle memory tracking
Message-Id: <20150729143015.e8420eca17acbd36d1ce9242@linux-foundation.org>
In-Reply-To: <20150729162908.GY8100@esperanza>
References: <cover.1437303956.git.vdavydov@parallels.com>
	<20150729123629.GI15801@dhcp22.suse.cz>
	<20150729135907.GT8100@esperanza>
	<20150729142618.GJ15801@dhcp22.suse.cz>
	<20150729152817.GV8100@esperanza>
	<20150729154718.GN15801@dhcp22.suse.cz>
	<20150729162908.GY8100@esperanza>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 29 Jul 2015 19:29:08 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:

> /proc/kpageidle should probably live somewhere in /sys/kernel/mm, but I
> added it where similar files are located (kpagecount, kpageflags) to
> keep things consistent.

I think these files should be moved elsewhere.  Consistency is good,
but not when we're being consistent with a bad thing.

So let's place these in /sys/kernel/mm and then start being consistent
with that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
