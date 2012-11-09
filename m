Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id EEE066B0044
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 16:44:56 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id rq2so3382189pbb.14
        for <linux-mm@kvack.org>; Fri, 09 Nov 2012 13:44:56 -0800 (PST)
Date: Fri, 9 Nov 2012 13:44:53 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: mmotm 2012-11-08-15-17 uploaded (mm/balloon_compaction.c)
In-Reply-To: <509D84C4.4050308@infradead.org>
Message-ID: <alpine.DEB.2.00.1211091344400.2974@chino.kir.corp.google.com>
References: <20121108231753.E6B7A100047@wpzn3.hot.corp.google.com> <509D84C4.4050308@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org

On Fri, 9 Nov 2012, Randy Dunlap wrote:

> on i386:
> 
> mm/balloon_compaction.c: In function 'balloon_page_putback':
> mm/balloon_compaction.c:243:3: error: implicit declaration of function '__WARN'
> 

Sent a fix for this an hour ago: 
http://marc.info/?l=linux-kernel&m=135249681031225

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
