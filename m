Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f173.google.com (mail-vc0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 782AB6B0031
	for <linux-mm@kvack.org>; Sun,  8 Jun 2014 17:33:17 -0400 (EDT)
Received: by mail-vc0-f173.google.com with SMTP id ik5so5456804vcb.18
        for <linux-mm@kvack.org>; Sun, 08 Jun 2014 14:33:17 -0700 (PDT)
Received: from mail-ve0-x22c.google.com (mail-ve0-x22c.google.com [2607:f8b0:400c:c01::22c])
        by mx.google.com with ESMTPS id cl2si9846607vcb.98.2014.06.08.14.33.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 08 Jun 2014 14:33:16 -0700 (PDT)
Received: by mail-ve0-f172.google.com with SMTP id jz11so1523771veb.3
        for <linux-mm@kvack.org>; Sun, 08 Jun 2014 14:33:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzRWZNt2AqdVzQpCChB1UJh12oBAof8UiKsvNGSMUe9BA@mail.gmail.com>
References: <20140607123518.88983301D2@webmail.sinamail.sina.com.cn>
	<CA+55aFzRWZNt2AqdVzQpCChB1UJh12oBAof8UiKsvNGSMUe9BA@mail.gmail.com>
Date: Sun, 8 Jun 2014 14:33:16 -0700
Message-ID: <CA+55aFxu2agkdu1ixbUP_XGy0ckyyOP_jOQ=LyyMRiVfAgS_NA@mail.gmail.com>
Subject: Re: Interactivity regression since v3.11 in mm/vmscan.c
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhdxzx@sina.com
Cc: Felipe Contreras <felipe.contreras@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, dhillf <dhillf@gmail.com>, "hillf.zj" <hillf.zj@alibaba-inc.com>

On Sat, Jun 7, 2014 at 11:24 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Comments? Mel, this code is mostly attributed to you, I'd like to hear
> what you think in particular.

In the meantime, I've removed the "nr_unqueued_dirty == nr_taken"
check for congestion_wait(), since I can't see how it can possibly be
sensible, and Felipe confirmed that it fixes his interactivity issue.

Nobody commented on it, but let's see if we get reactions to the
behavior changing..

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
