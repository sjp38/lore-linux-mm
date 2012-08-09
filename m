Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 7AE3B6B0073
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 09:57:52 -0400 (EDT)
Date: Thu, 9 Aug 2012 08:56:35 -0500 (CDT)
From: "Christoph Lameter (Open Source)" <cl@linux.com>
Subject: Re: Common11 [06/20] Extract a common function for
 kmem_cache_destroy
In-Reply-To: <50238A10.1000606@parallels.com>
Message-ID: <alpine.DEB.2.02.1208090851020.15909@greybox.home>
References: <20120808210129.987345284@linux.com> <20120808210210.088838748@linux.com> <50238A10.1000606@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Thu, 9 Aug 2012, Glauber Costa wrote:

> These lines you are removing doesn't seem to exist on Pekka's, and are
> certainly not added in the previous patches. The patch fails to apply
> because of that.

These lines were added by the previous patch as per Joonsoo's request.

Unrefreshed patches again. Sorry but there are numerous other things that
require my attention at this point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
