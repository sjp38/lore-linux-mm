Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 418B86B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 01:57:53 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id yy13so372498944pab.3
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 22:57:53 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id f7si14355507pat.97.2016.01.19.22.57.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 19 Jan 2016 22:57:52 -0800 (PST)
Date: Wed, 20 Jan 2016 16:00:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: fix migrate_zspage-zs_free race condition
Message-ID: <20160120070019.GC12293@bbox>
References: <1452818184-2994-1-git-send-email-junil0814.lee@lge.com>
 <20160115023518.GA10843@bbox>
 <20160115032712.GC1993@swordfish>
 <20160115044916.GB11203@bbox>
 <20160115050722.GE1993@swordfish>
 <CAGfvh60CYegQ1fRMzuWbRNsv5eYEEiXtXFSBr_CbnJHuYMs5pQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGfvh60CYegQ1fRMzuWbRNsv5eYEEiXtXFSBr_CbnJHuYMs5pQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell Knize <rknize@motorola.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Junil Lee <junil0814.lee@lge.com>, Andrew Morton <akpm@linux-foundation.org>, ngupta@vflare.org, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hello Russ,

On Tue, Jan 19, 2016 at 09:47:12AM -0600, Russell Knize wrote:
>    Just wanted to ack this, as we have been seeing the same problem (weird
>    race conditions during compaction) and fixed it in the same way a few
>    weeks ago (resetting the pin bit before recording the obj).
>    Russ

First of all, thanks for your comment.

The patch you tested have a problem although it's really subtle(ie,
it doesn't do store tearing when I disassemble ARM{32|64}) but it
could have a problem potentially for other architecutres or future ARM.
For right fix, I sent v5 - https://lkml.org/lkml/2016/1/18/263.
If you can prove it fixes your problem, please Tested-by to the thread.
It's really valuable to do testing for stable material.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
