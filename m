Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9AD7082BEF
	for <linux-mm@kvack.org>; Sun,  9 Nov 2014 03:22:50 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id x12so6671087wgg.18
        for <linux-mm@kvack.org>; Sun, 09 Nov 2014 00:22:50 -0800 (PST)
Received: from tux-cave.hellug.gr (tux-cave.hellug.gr. [195.134.99.74])
        by mx.google.com with ESMTPS id cd14si11501677wib.39.2014.11.09.00.22.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Nov 2014 00:22:49 -0800 (PST)
From: "P. Christeas" <xrg@linux.gr>
Subject: Re: Early test: hangs in mm/compact.c w. Linus's 12d7aacab56e9ef185c
Date: Sun, 09 Nov 2014 10:22:26 +0200
Message-ID: <1433036.WjB5pb09Zh@xorhgos3.pefnos>
In-Reply-To: <00a801cffbd8$434189b0$c9c49d10$@alibaba-inc.com>
References: <00a801cffbd8$434189b0$c9c49d10$@alibaba-inc.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, linux-kernel <linux-kernel@vger.kernel.org>
Cc: 'Vlastimil Babka' <vbabka@suse.cz>, linux-mm@kvack.org

On Sunday 09 November 2014, Hillf Danton wrote:
> -		return COMPACT_CONTINUE;
> +		return COMPACT_SKIPPED;

I guess this one would mitigate against Vlastmil's migration scanner issue, 
wouldn't it?

In that case, I should wait a bit[1] to try the first patch, then revert, try 
yours and (hopefully) have some results.

Then, apply both.

[1] trying to push the vm by loading memory-hungry apps and random load.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
