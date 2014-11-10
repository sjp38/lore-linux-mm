Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2DC6B00D9
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 03:14:25 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id r20so9170256wiv.3
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 00:14:24 -0800 (PST)
Received: from tux-cave.hellug.gr (tux-cave.hellug.gr. [195.134.99.74])
        by mx.google.com with ESMTPS id a5si27894151wjy.155.2014.11.10.00.14.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Nov 2014 00:14:24 -0800 (PST)
From: "P. Christeas" <xrg@linux.gr>
Subject: Re: Early test: hangs in mm/compact.c w. Linus's 12d7aacab56e9ef185c
Date: Mon, 10 Nov 2014 10:14:10 +0200
Message-ID: <3191541.VgF98cnILq@xorhgos3.pefnos>
In-Reply-To: <545E96BD.5040103@suse.cz>
References: <12996532.NCRhVKzS9J@xorhgos3.pefnos> <3443150.6EQzxj6Rt9@xorhgos3.pefnos> <545E96BD.5040103@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, lkml <linux-kernel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>

On Saturday 08 November 2014, Vlastimil Babka wrote:
> >From fbf8eb0bcd2897090312e23da6a31bad9cc6b337 Mon Sep 17 00:00:00 2001
> 
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Sat, 8 Nov 2014 22:20:43 +0100
> Subject: [PATCH] mm, compaction: prevent endless loop in migrate scanner

After 30hrs uptime, I also mark this test as PASSED .

:)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
