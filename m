Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id 042226B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 15:58:49 -0500 (EST)
Received: by mail-yh0-f43.google.com with SMTP id z6so10771633yhz.2
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 12:58:48 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r70si9707159ykb.129.2015.01.12.12.58.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 12:58:47 -0800 (PST)
Date: Mon, 12 Jan 2015 12:58:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv2 0/2] mm: infrastructure for correctly handling foreign
 pages on Xen
Message-Id: <20150112125846.4a5a6418c5c130c1b7669086@linux-foundation.org>
In-Reply-To: <1421077993-7909-1-git-send-email-david.vrabel@citrix.com>
References: <1421077993-7909-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 12 Jan 2015 15:53:11 +0000 David Vrabel <david.vrabel@citrix.com> wrote:

> These two patches are the common parts of a larger Xen series[1]
> fixing several long-standing bugs the handling of foreign[2] pages in
> Xen guests.
> 
> The first patch is required to fix get_user_pages[_fast]() with
> userspace space mappings of such foreign pages.  Basically, pte_page()
> doesn't work so an alternate mechanism is needed to get the page from
> a VMA and address.  By requiring mappings needing this method are
> 'special' this should not have an impact on the common use cases.
> 
> The second patch isn't essential but helps with readability of the
> resulting user of the page flag.
> 
> For further background reading see:
> 
>   http://xenbits.xen.org/people/dvrabel/grant-improvements-C.pdf
> 

Looks OK to me.  I can merge them if you like, but it's probably more
convenient for you to include them in the Xen tree.

It would be nice if PG_foreign (and PG_everythingelse) was properly
documented at the definition site.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
