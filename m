Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id A37676B0038
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 10:47:04 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so1493752eek.10
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 07:47:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id l41si31116291eef.188.2014.04.30.07.47.02
        for <linux-mm@kvack.org>;
        Wed, 30 Apr 2014 07:47:02 -0700 (PDT)
Message-ID: <53610C30.5080508@redhat.com>
Date: Wed, 30 Apr 2014 10:44:00 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: constify nmask argument to mbind()
References: <1398868157-24323-1-git-send-email-linux@rasmusvillemoes.dk>
In-Reply-To: <1398868157-24323-1-git-send-email-linux@rasmusvillemoes.dk>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jianguo Wu <wujianguo@huawei.com>

On 04/30/2014 10:29 AM, Rasmus Villemoes wrote:
> The nmask argument to mbind() is const according to the user-space
> header numaif.h, and since the kernel does indeed not modify it, it
> might as well be declared const in the kernel.
>
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
