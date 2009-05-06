Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 609A56B004D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 02:34:10 -0400 (EDT)
Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id n466YcUO023046
	for <linux-mm@kvack.org>; Wed, 6 May 2009 07:34:38 +0100
Received: from wa-out-1112.google.com (wahk40.prod.google.com [10.114.237.40])
	by zps78.corp.google.com with ESMTP id n466YaWP028953
	for <linux-mm@kvack.org>; Tue, 5 May 2009 23:34:36 -0700
Received: by wa-out-1112.google.com with SMTP id k40so2116373wah.16
        for <linux-mm@kvack.org>; Tue, 05 May 2009 23:34:36 -0700 (PDT)
Date: Tue, 5 May 2009 23:34:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mmotm] mm: setup_per_zone_inactive_ratio - fix comment
 and make it __init
In-Reply-To: <20090506061923.GA4865@lenovo>
Message-ID: <alpine.DEB.2.00.0905052333390.9824@chino.kir.corp.google.com>
References: <20090506061923.GA4865@lenovo>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LMMML <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 6 May 2009, Cyrill Gorcunov wrote:

> The caller of setup_per_zone_inactive_ratio is module_init function.
> No need to keep the callee after is completed as well.
> Also fix a comment.
> 
> CC: David Rientjes <rientjes@google.com>
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>

Acked-by: David Rientjes <rientjes@google.com>

There's no need to specify -mmotm on the subject line since it isn't 
specific to that tree, this applies to HEAD just fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
