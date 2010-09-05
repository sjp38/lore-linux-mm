Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E3D026B0047
	for <linux-mm@kvack.org>; Sun,  5 Sep 2010 18:04:31 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o85M4SoB019308
	for <linux-mm@kvack.org>; Sun, 5 Sep 2010 15:04:28 -0700
Received: from pzk9 (pzk9.prod.google.com [10.243.19.137])
	by kpbe14.cbf.corp.google.com with ESMTP id o85M4QJ6027597
	for <linux-mm@kvack.org>; Sun, 5 Sep 2010 15:04:26 -0700
Received: by pzk9 with SMTP id 9so1225076pzk.19
        for <linux-mm@kvack.org>; Sun, 05 Sep 2010 15:04:26 -0700 (PDT)
Date: Sun, 5 Sep 2010 15:04:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 13/14] mm: mempolicy: Check return code of check_range
In-Reply-To: <1283711588-7628-1-git-send-email-segooon@gmail.com>
Message-ID: <alpine.DEB.2.00.1009051503580.5003@chino.kir.corp.google.com>
References: <1283711588-7628-1-git-send-email-segooon@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Kulikov Vasiliy <segooon@gmail.com>
Cc: kernel-janitors@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 5 Sep 2010, Kulikov Vasiliy wrote:

> From: Vasiliy Kulikov <segooon@gmail.com>
> 
> Function check_range may return ERR_PTR(...). Check for it.
> 
> Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
