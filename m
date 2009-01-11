Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 30D266B004F
	for <linux-mm@kvack.org>; Sun, 11 Jan 2009 16:14:38 -0500 (EST)
Date: Mon, 12 Jan 2009 00:14:55 +0300
From: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Subject: Re: WARNING in vmap_page_range on alpha since 2.6.28
Message-ID: <20090111211455.GB1641@jurassic.park.msu.ru>
References: <20090111141855.GA7416@eric.schwarzvogel.de> <20090111183600.GA2728@ds20.borg.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090111183600.GA2728@ds20.borg.net>
Sender: owner-linux-mm@kvack.org
To: Thorsten Kranzkowski <dl8bcu@dl8bcu.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, klausman@schwarzvogel.de
List-ID: <linux-mm.kvack.org>

On Sun, Jan 11, 2009 at 06:36:00PM +0000, Thorsten Kranzkowski wrote:
> I see similar traces:
> 
> ------------[ cut here ]------------
> WARNING: at /export/data/scm/linux-2.6/mm/vmalloc.c:104 vmap_page_range+0x1c4/0x264()

The problem is that alpha allocates some VMALLOC space very early
on boot, but the new VM allocator doesn't know about this.

I've posted a fix few days ago:
http://lkml.org/lkml/2009/1/7/574

Ivan.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
