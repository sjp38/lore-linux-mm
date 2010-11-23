Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3FEF06B0071
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 21:54:48 -0500 (EST)
Received: by yxl31 with SMTP id 31so1944748yxl.14
        for <linux-mm@kvack.org>; Mon, 22 Nov 2010 18:54:44 -0800 (PST)
Subject: Re: [PATCH] scripts: Fix gfp-translate for recent changes to gfp.h
From: Namhyung Kim <namhyung@gmail.com>
In-Reply-To: <20101122120002.GB1890@csn.ul.ie>
References: <20101122120002.GB1890@csn.ul.ie>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 23 Nov 2010 11:54:36 +0900
Message-ID: <1290480876.1857.2.camel@leonhard>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

2010-11-22 (i??), 12:00 +0000, Mel Gorman:
> The recent changes to gfp.h to satisfy sparse broke
> scripts/gfp-translate. This patch fixes it up to work with old and new
> versions of gfp.h .

Oh, I didn't even know the script exists. Sorry.

-- 
Regards,
Namhyung Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
