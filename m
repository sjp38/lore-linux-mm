Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1C1F34402ED
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 11:04:47 -0500 (EST)
Received: by igl9 with SMTP id 9so96683188igl.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 08:04:46 -0800 (PST)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id m7si6677898igj.18.2015.11.25.08.04.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 25 Nov 2015 08:04:45 -0800 (PST)
Date: Wed, 25 Nov 2015 10:04:44 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/vmstat: retrieve more accurate vmstat value
In-Reply-To: <20151125025735.GC9563@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.20.1511251002380.31590@east.gentwo.org>
References: <1448346123-2699-1-git-send-email-iamjoonsoo.kim@lge.com> <alpine.DEB.2.20.1511240934130.20512@east.gentwo.org> <20151125025735.GC9563@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 25 Nov 2015, Joonsoo Kim wrote:

> I think that maintaining duplicate counter to guarantee accuracy isn't
> reasonable solution. It would cause more overhead to the system.

Simply remove the counter from the vmstat handling and do it differently
then.

> Although vmstat values aren't designed for accuracy, these are already
> used by some sensitive places so it is better to be more accurate.

The design is to sacrifice accuracy and the time the updates occur for
performance reasons. This is not the purpose the counters were designed
for. If you put these demands on the vmstat then you will get complex
convoluted code and compromise performance.

> What this patch does is just adding current cpu's diff to global value
> when retrieving in order to get more accurate value and this would not be
> expensive. I think that it doesn't break any design principle of vmstat.

There have been a number of expectations recently regarding the accuracy
of vmstat. We are on the wrong track here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
