Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id CFA576B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 14:52:18 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id z10so802360pdj.33
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 11:52:18 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id eb3si11026564pbc.236.2014.01.22.11.52.16
        for <linux-mm@kvack.org>;
        Wed, 22 Jan 2014 11:52:17 -0800 (PST)
Date: Wed, 22 Jan 2014 11:52:15 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 67651] Bisected: Lots of fragmented mmaps cause gimp to
 fail in 3.12 after exceeding vm_max_map_count
Message-Id: <20140122115215.f723ddf2e2a3c3d4b6ab9bf3@linux-foundation.org>
In-Reply-To: <20140122190816.GB4963@suse.de>
References: <20140122190816.GB4963@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@parallels.com>, gnome@rvzt.net, drawoc@darkrefraction.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org

On Wed, 22 Jan 2014 19:08:16 +0000 Mel Gorman <mgorman@suse.de> wrote:

> X-related junk is there was because I was using a headless server and
> xinit directly to launch gimp to reproduce the bug.

I've never done this.  Can you share the magic recipe for running an X
app in this way?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
