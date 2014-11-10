Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0017682BEF
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 05:50:34 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id l18so8689428wgh.10
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 02:50:31 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id id10si28442243wjb.177.2014.11.10.02.50.30
        for <linux-mm@kvack.org>;
        Mon, 10 Nov 2014 02:50:30 -0800 (PST)
Date: Mon, 10 Nov 2014 11:50:30 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] mm, compaction: prevent infinite loop in compact_zone
Message-ID: <20141110105030.GA20052@amd>
References: <1415608710-8326-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1415608710-8326-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Norbert Preining <preining@logic.at>, "P. Christeas" <xrg@linux.gr>

Hi!

>  	acct_isolated(zone, cc);
> -	/* Record where migration scanner will be restarted */
> -	cc->migrate_pfn = low_pfn;
> +	/* 

pavel@amd:/data/l/linux$ cat /tmp/delme | git apply
<stdin>:81: trailing whitespace.
	    /* 
warning: 1 line adds whitespace errors.

I have applied the patch, but the bug normally takes a while to
reproduce...

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
