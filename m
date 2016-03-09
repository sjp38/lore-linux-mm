Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3DB666B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 18:08:56 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id p65so6381486wmp.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 15:08:56 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id fy10si1064651wjc.144.2016.03.09.15.08.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 15:08:55 -0800 (PST)
Date: Wed, 9 Mar 2016 15:08:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2]
 oom-clear-tif_memdie-after-oom_reaper-managed-to-unmap-the-address-space-fix
Message-Id: <20160309150853.2658e3bc75907e404cf3ca33@linux-foundation.org>
In-Reply-To: <20160309224829.GA5716@cmpxchg.org>
References: <1457442737-8915-1-git-send-email-mhocko@kernel.org>
	<1457442737-8915-3-git-send-email-mhocko@kernel.org>
	<20160309132142.80d0afbf0ae398df8e2adba8@linux-foundation.org>
	<201603100721.CDC86433.OMFOVOHSJFLFQt@I-love.SAKURA.ne.jp>
	<20160309224829.GA5716@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org, linux-mm@kvack.org, rientjes@google.com, linux-kernel@vger.kernel.org, mhocko@suse.com

On Wed, 9 Mar 2016 17:48:29 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> However, I disagree with your changelog.

What text would you prefer?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
