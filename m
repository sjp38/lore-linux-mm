Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8507D6B0075
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 11:03:41 -0500 (EST)
Received: by mail-la0-f44.google.com with SMTP id gf13so973423lab.3
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 08:03:40 -0800 (PST)
Received: from tux-cave.hellug.gr (tux-cave.hellug.gr. [195.134.99.74])
        by mx.google.com with ESMTPS id f6si7026761lbc.6.2014.11.05.08.03.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Nov 2014 08:03:39 -0800 (PST)
From: "P. Christeas" <xrg@linux.gr>
Subject: Re: Early test: hangs in mm/compact.c w. Linus's 12d7aacab56e9ef185c
Date: Wed, 05 Nov 2014 18:02:02 +0200
Message-ID: <2478068.rAhurny29o@xorhgos3.pefnos>
In-Reply-To: <545A419C.3090900@suse.cz>
References: <12996532.NCRhVKzS9J@xorhgos3.pefnos> <2357788.X5UHX7WJZF@xorhgos3.pefnos> <545A419C.3090900@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, lkml <linux-kernel@vger.kernel.org>

On Wednesday 05 November 2014, Vlastimil Babka wrote:
> I see. I've tried to reproduce such issues with 3.18-rc3 but wasn't
> successful. But I noticed a possible issue that could lead to your problem.
> Can you please try the following patch?

OK, I can give it a try.

FYI, the "stability canary" is still alive, my system is on for 28hours, under 
avg. load >=3 all this time, HEAD=980d0d51b1c9617a4

/me goes busy fire-proofing your patch...



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
