Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 381B56B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 20:45:50 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id a4so7436035wme.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 17:45:50 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f6si1172697wmh.51.2016.02.24.17.45.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 17:45:49 -0800 (PST)
Date: Wed, 24 Feb 2016 17:53:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 1/2] mm: introduce page reference manipulation
 functions
Message-Id: <20160224175333.8957903d.akpm@linux-foundation.org>
In-Reply-To: <20160225003454.GB9723@js1304-P5Q-DELUXE>
References: <1456212078-22732-1-git-send-email-iamjoonsoo.kim@lge.com>
	<20160223153244.83a5c3ca430c4248a4a34cc0@linux-foundation.org>
	<20160225003454.GB9723@js1304-P5Q-DELUXE>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Thu, 25 Feb 2016 09:34:55 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> > 
> > The patches will be a bit of a pain to maintain but surprisingly they
> > apply OK at present.  It's possible that by the time they hit upstream,
> > some direct ->_count references will still be present and it will
> > require a second pass to complete the conversion.
> 
> In fact, the patch doesn't change direct ->_count reference for
> *read*. That's the reason that it is surprisingly OK at present.
> 
> It's a good idea to change direct ->_count reference even for read.
> How about changing it in rc2 after mering this patch in rc1?

Sounds fair enough.

Although I'm counting only 11 such sites so perhaps we just go ahead
and do it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
