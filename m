Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A9226B0038
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 18:26:27 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id l4so2967134wre.10
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 15:26:27 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k184si2651122wmd.221.2017.12.06.15.26.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 15:26:25 -0800 (PST)
Date: Wed, 6 Dec 2017 15:26:21 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: terminate shrink_slab loop if signal is pending
Message-Id: <20171206152621.2c263569ea623dd1e0119848@linux-foundation.org>
In-Reply-To: <20171206192026.25133-1-surenb@google.com>
References: <20171206192026.25133-1-surenb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: mhocko@suse.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, timmurray@google.com, tkjos@google.com

On Wed,  6 Dec 2017 11:20:26 -0800 Suren Baghdasaryan <surenb@google.com> wrote:

> Slab shrinkers can be quite time consuming and when signal
> is pending they can delay handling of the signal. If fatal
> signal is pending there is no point in shrinking that process
> since it will be killed anyway. This change checks for pending
> fatal signals inside shrink_slab loop and if one is detected
> terminates this loop early.

Some quantification of "quite time consuming" and "delay" would be
interesting, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
