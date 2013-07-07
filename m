Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 668DE6B0036
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 08:01:27 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kl14so3482222pab.6
        for <linux-mm@kvack.org>; Sun, 07 Jul 2013 05:01:26 -0700 (PDT)
Subject: Re: [PATCH] swap: warn when a swap area overflows the maximum size
 (resent)
From: Raymond Jennings <shentino@gmail.com>
In-Reply-To: <1373197978.26573.7.camel@warfang>
References: <1373197450.26573.5.camel@warfang>
	 <1373197978.26573.7.camel@warfang>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 07 Jul 2013 05:01:24 -0700
Message-ID: <1373198484.26573.8.camel@warfang>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Valdis Kletnieks <valdis.kletnieks@vt.edu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

...I hate you gmail...

On Sun, 2013-07-07 at 04:52 -0700, Raymond Jennings wrote:
> # lvresize /dev/system/swap --size 16G

Typo in the second test.

The first line should read:

# lvresize /dev/system/swap --size 64G

First ever serious patch, got excited and burned the copypasta.

> # mkswap /dev/system/swap
> # swapon /dev/system/swap
> 
> Jul  7 04:27:22 warfang kernel: Truncating oversized swap area, only
> using 33554432k out of 67108860k
> Jul  7 04:27:22 warfang kernel: Adding 33554428k swap
> on /dev/mapper/system-swap.  Priority:-1 extents:1 across:33554428k 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
