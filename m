Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 85B986B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 17:14:43 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rq2so11436305pbb.37
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 14:14:43 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id b4si3414742pbe.118.2014.02.13.14.14.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 14:14:39 -0800 (PST)
Received: by mail-pa0-f48.google.com with SMTP id kx10so11352265pab.7
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 14:14:39 -0800 (PST)
Date: Thu, 13 Feb 2014 14:14:37 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: 3.14.0-rc2: WARNING: at mm/slub.c:1007
In-Reply-To: <alpine.DEB.2.19.4.1402131158590.6233@trent.utfs.org>
Message-ID: <alpine.DEB.2.02.1402131413070.13899@chino.kir.corp.google.com>
References: <alpine.DEB.2.19.4.1402131144390.6233@trent.utfs.org> <alpine.DEB.2.19.4.1402131158590.6233@trent.utfs.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Kujau <lists@nerdbynature.de>
Cc: LKML <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com, linux-mm@kvack.org

On Thu, 13 Feb 2014, Christian Kujau wrote:

> > after upgrading from 3.13-rc8 to 3.14.0-rc2 on this PowerPC G4 machine, 
> > the WARNING below was printed.
> > 
> > Shortly after, a lockdep warning appeared (possibly related to my 
> > post to the XFS list yesterday[0]).
> 
> Sigh, only _after_ sending the email, I came across an earlier posting on 
> lkml: http://marc.info/?l=linux-mm&m=139145788623391
> 

There's a fix for that: http://marc.info/?l=linux-kernel&m=139145999324131
or alternatively wait for 3.14-rc3 which will already have it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
