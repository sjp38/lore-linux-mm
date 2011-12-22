Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id A94676B004D
	for <linux-mm@kvack.org>; Thu, 22 Dec 2011 02:38:35 -0500 (EST)
Received: by yhgm50 with SMTP id m50so4837324yhg.14
        for <linux-mm@kvack.org>; Wed, 21 Dec 2011 23:38:34 -0800 (PST)
Date: Wed, 21 Dec 2011 23:38:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Change void* into explict vm_struct*
In-Reply-To: <1324524793-14049-1-git-send-email-minchan@kernel.org>
Message-ID: <alpine.DEB.2.00.1112212338190.23374@chino.kir.corp.google.com>
References: <1324524793-14049-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 22 Dec 2011, Minchan Kim wrote:

> Now, vmap_area->private is void* but we don't use the field
> for various purpose but use only for vm_struct.
> So change it with vm_struct* with naming and it's more good
> for readability and type checking.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
