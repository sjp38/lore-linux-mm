Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 281E46B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 01:23:23 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so65257721pdn.0
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 22:23:22 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id we3si694021pab.16.2015.03.18.22.23.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 22:23:22 -0700 (PDT)
Date: Wed, 18 Mar 2015 22:22:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
Message-Id: <20150318222246.bc608dd0.akpm@linux-foundation.org>
In-Reply-To: <20150319050826.GA1591708@devbig257.prn2.facebook.com>
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com>
	<20150318153100.5658b741277f3717b52e42d9@linux-foundation.org>
	<20150319050826.GA1591708@devbig257.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, danielmicay@gmail.com, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>

On Wed, 18 Mar 2015 22:08:26 -0700 Shaohua Li <shli@fb.com> wrote:

> > Daniel also had microbenchmark testing results for glibc and jemalloc. 
> > Can you please do this?
> 
> I run Daniel's microbenchmark too, and not surprise the result is
> similar:
> glibc: 32.82
> jemalloc: 70.35
> jemalloc+mremap: 33.01
> tcmalloc: 68.81
> 
> but tcmalloc doesn't support mremap currently, so I cant test it.

But Daniel's changelog implies strongly that tcmalloc would benefit
from his patch.  Was that inaccurate or is this a difference between
his patch and yours?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
