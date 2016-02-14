Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id ED4D66B0009
	for <linux-mm@kvack.org>; Sun, 14 Feb 2016 11:51:35 -0500 (EST)
Received: by mail-qg0-f47.google.com with SMTP id y89so96545591qge.2
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 08:51:35 -0800 (PST)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id b130si28897720qhc.18.2016.02.14.08.51.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Feb 2016 08:51:35 -0800 (PST)
Received: by mail-qk0-x244.google.com with SMTP id q184so4643974qkb.0
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 08:51:34 -0800 (PST)
Date: Sun, 14 Feb 2016 11:51:33 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH RFC] Introduce atomic and per-cpu add-max and sub-min
 operations
Message-ID: <20160214165133.GB3965@htj.duckdns.org>
References: <145544094056.28219.12239469516497703482.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <145544094056.28219.12239469516497703482.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-arch@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Hello, Konstantin.

On Sun, Feb 14, 2016 at 12:09:00PM +0300, Konstantin Khlebnikov wrote:
> bool atomic_add_max(atomic_t *var, int add, int max);
> bool atomic_sub_min(atomic_t *var, int sub, int min);
> 
> bool this_cpu_add_max(var, add, max);
> bool this_cpu_sub_min(var, sub, min);
> 
> They add/subtract only if result will be not bigger than max/lower that min.
> Returns true if operation was done and false otherwise.

If I'm reading the code right, all the above functions do is wrapping
the corresponding cmpxchg implementations.  Given that most use cases
would build further abstractions on top, I'm not sure how useful
providing another layer of abstraction is.  For the most part, we
introduce new per-cpu operations to take advantage of capabilities of
underlying hardware which can't be utilized in a different way (like
the x86 128bit atomic ops).

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
