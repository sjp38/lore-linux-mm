Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 85C166B0069
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 09:01:17 -0400 (EDT)
Message-ID: <504DE3DA.7000802@parallels.com>
Date: Mon, 10 Sep 2012 16:58:02 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [glommer-memcg:kmemcg-slab 57/62] drivers/video/riva/fbdev.c:281:9:
 sparse: preprocessor token MAX_LEVEL redefined
References: <20120910111638.GC9660@localhost> <20120910125759.GA11808@localhost>
In-Reply-To: <20120910125759.GA11808@localhost>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: kernel-janitors@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On 09/10/2012 04:57 PM, Fengguang Wu wrote:
> Glauber,
> 
> The patch entitled
> 
>  sl[au]b: Allocate objects from memcg cache
> 
> changes
> 
>  include/linux/slub_def.h |   15 ++++++++++-----
> 
> which triggers this warning:
> 
> drivers/video/riva/fbdev.c:281:9: sparse: preprocessor token MAX_LEVEL redefined
> 
> It's the MAX_LEVEL that is defined in include/linux/idr.h.
> 
> MAX_LEVEL is obviously too generic. Better adding some prefix to it?
> 

I don't see any MAX_LEVEL definition in this patch. You say it is
defined in include/linux/idr.h, and as the diffstat shows, I am not
touching this file.

I think this needs patching independently.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
