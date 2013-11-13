Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id D07446B00AE
	for <linux-mm@kvack.org>; Tue, 12 Nov 2013 21:40:05 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id r10so2484490pdi.35
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 18:40:05 -0800 (PST)
Received: from psmtp.com ([74.125.245.169])
        by mx.google.com with SMTP id bf6si10562740pad.77.2013.11.12.18.40.03
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 18:40:04 -0800 (PST)
Date: Wed, 13 Nov 2013 11:42:52 +0900
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: zsmalloc: Ensure handle is never 0 on success
Message-ID: <20131113024252.GA1023@kroah.com>
References: <20131107070451.GA10645@bbox>
 <20131112154137.GA3330@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131112154137.GA3330@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, lliubbo@gmail.com, jmarchan@redhat.com, mgorman@suse.de, riel@redhat.com, hughd@google.com, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Luigi Semenzato <semenzato@google.com>

On Wed, Nov 13, 2013 at 12:41:38AM +0900, Minchan Kim wrote:
> We spent much time with preventing zram enhance since it have been in staging
> and Greg never want to improve without promotion.

It's not "improve", it's "Greg does not want you adding new features and
functionality while the code is in staging."  I want you to spend your
time on getting it out of staging first.

Now if something needs to be done based on review and comments to the
code, then that's fine to do and I'll accept that, but I've been seeing
new functionality be added to the code, which I will not accept because
it seems that you all have given up on getting it merged, which isn't
ok.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
