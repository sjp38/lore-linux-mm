Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id D01836B0003
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 13:13:58 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id t27so3106136iob.20
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 10:13:58 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id v83si12854708iov.162.2018.03.07.10.13.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 10:13:57 -0800 (PST)
Date: Wed, 7 Mar 2018 12:13:56 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Fix misleading 'age' in verbose slub prints
In-Reply-To: <1520423266-28830-1-git-send-email-cpandya@codeaurora.org>
Message-ID: <alpine.DEB.2.20.1803071212150.6373@nuc-kabylake>
References: <1520423266-28830-1-git-send-email-cpandya@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 7 Mar 2018, Chintan Pandya wrote:

> In this case, object got freed later but 'age' shows
> otherwise. This could be because, while printing
> this info, we print allocation traces first and
> free traces thereafter. In between, if we get schedule
> out, (jiffies - t->when) could become meaningless.

Ok then get the jiffies earlier?

> So, simply print when the object was allocated/freed.

The tick value may not related to anything in the logs that is why the
"age" is there. How do I know how long ago the allocation was if I look at
the log and only see long and large number of ticks since bootup?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
