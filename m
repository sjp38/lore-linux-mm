Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 46EFF828F3
	for <linux-mm@kvack.org>; Sun, 10 Jan 2016 12:38:55 -0500 (EST)
Received: by mail-lb0-f169.google.com with SMTP id bc4so243209642lbc.2
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 09:38:55 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u79si25794285lfd.72.2016.01.10.09.38.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jan 2016 09:38:53 -0800 (PST)
Date: Sun, 10 Jan 2016 12:38:48 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH mmotm] memcg: avoid vmpressure oops when memcg disabled
Message-ID: <20160110173848.GA20871@cmpxchg.org>
References: <alpine.LSU.2.11.1601091717160.10107@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1601091717160.10107@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Sat, Jan 09, 2016 at 05:21:44PM -0800, Hugh Dickins wrote:
> A CONFIG_MEMCG=y kernel booted with "cgroup_disable=memory" crashes on
> a NULL memcg (but non-NULL root_mem_cgroup) when vmpressure kicks in.
> Here's the patch I use to avoid that, but you might prefer a test on
> mem_cgroup_disabled() somewhere.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Thanks Hugh. This looks good.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
