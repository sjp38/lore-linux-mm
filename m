Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE366B0036
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 18:33:15 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id e16so6245706lan.16
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 15:33:14 -0700 (PDT)
Received: from mail-lb0-x22a.google.com (mail-lb0-x22a.google.com [2a00:1450:4010:c04::22a])
        by mx.google.com with ESMTPS id e7si5175646lag.30.2014.04.14.15.33.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Apr 2014 15:33:13 -0700 (PDT)
Received: by mail-lb0-f170.google.com with SMTP id s7so6327486lbd.29
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 15:33:12 -0700 (PDT)
Date: Tue, 15 Apr 2014 02:33:09 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 2/4] mm: Dont forget to set softdirty on file mapped fault
Message-ID: <20140414223309.GC23983@moon>
References: <20140324122838.490106581@openvz.org>
 <20140324125926.013008345@openvz.org>
 <20140414152758.a9a80782dbb94c74a27f683a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140414152758.a9a80782dbb94c74a27f683a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, xemul@parallels.com

On Mon, Apr 14, 2014 at 03:27:58PM -0700, Andrew Morton wrote:
> 
> This will need to be redone for current kernels, please.  New patch, new
> title, new changelog, retest.

Sure, will resend once done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
