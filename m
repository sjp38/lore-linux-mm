Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 72E856B0074
	for <linux-mm@kvack.org>; Tue, 28 May 2013 17:53:48 -0400 (EDT)
Message-ID: <51A52768.3020106@sr71.net>
Date: Tue, 28 May 2013 14:53:44 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: mmotm-2013-05-22: Bad page state
References: <51A526D9.3020803@sr71.net>
In-Reply-To: <51A526D9.3020803@sr71.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>

On 05/28/2013 02:51 PM, Dave Hansen wrote:
> I was rebasing my mapping->radix_tree lock batching patches on top of
> Mel's stuff.  It looks like something is jumping the gun and freeing a
> page before it has been written out.  Somebody probably did an extra
> put_page() or something.
> 
> I'm running 3.10.0-rc2-mm1-00322-g8d4c612 from
> 
> 	git://git.cmpxchg.org/linux-mmotm.git

This is the config, btw:

	http://sr71.net/~dave/linux/config-3.10-mmotmbad1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
