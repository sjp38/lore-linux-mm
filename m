Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 700DF6B0037
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 00:07:28 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id jt11so4689482pbb.36
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 21:07:28 -0800 (PST)
Received: from mail-pb0-x236.google.com (mail-pb0-x236.google.com [2607:f8b0:400e:c01::236])
        by mx.google.com with ESMTPS id gn5si12835921pbc.116.2014.03.03.21.07.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 21:07:27 -0800 (PST)
Received: by mail-pb0-f54.google.com with SMTP id ma3so4570313pbc.41
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 21:07:27 -0800 (PST)
Date: Mon, 3 Mar 2014 21:07:25 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] x86, kmemcheck: Use kstrtoint() instead of sscanf()
In-Reply-To: <5314804F.9090806@iki.fi>
Message-ID: <alpine.DEB.2.02.1403032107020.21548@chino.kir.corp.google.com>
References: <5304558F.9050605@huawei.com> <alpine.DEB.2.02.1402182344001.3551@chino.kir.corp.google.com> <alpine.DEB.2.02.1402191412300.31921@chino.kir.corp.google.com> <5314804F.9090806@iki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@iki.fi>
Cc: Vegard Nossum <vegardno@ifi.uio.no>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Xishi Qiu <qiuxishi@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 3 Mar 2014, Pekka Enberg wrote:

> > Kmemcheck should use the preferred interface for parsing command line
> > arguments, kstrto*(), rather than sscanf() itself.  Use it appropriately.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> Acked-by: Pekka Enberg <penberg@kernel.org>
> 

Thanks!

> Andrew, can you pick this up?
> 

It's already picked up, see 
http://ozlabs.org/~akpm/mmotm/broken-out/arch-x86-mm-kmemcheck-kmemcheckc-use-kstrtoint-instead-of-sscanf.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
