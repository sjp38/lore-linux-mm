Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 76BFA6B005D
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 10:10:57 -0400 (EDT)
Message-ID: <504DF42F.2050504@parallels.com>
Date: Mon, 10 Sep 2012 18:07:43 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] idr: Rename MAX_LEVEL to MAX_ID_LEVEL
References: <20120910131426.GA12431@localhost>
In-Reply-To: <20120910131426.GA12431@localhost>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-janitors@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On 09/10/2012 05:14 PM, Fengguang Wu wrote:
> To avoid name conflicts:
> 
> drivers/video/riva/fbdev.c:281:9: sparse: preprocessor token MAX_LEVEL redefined
> 
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>

Acked-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
