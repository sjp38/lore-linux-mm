Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id CBC196B00E9
	for <linux-mm@kvack.org>; Mon, 21 May 2012 16:08:41 -0400 (EDT)
Message-ID: <4FBAA04D.7010007@parallels.com>
Date: Tue, 22 May 2012 00:06:37 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] Common code 09/12] slabs: Extract a common function for
 kmem_cache_destroy
References: <20120518161906.207356777@linux.com> <20120518161932.147485968@linux.com> <4FBA0C2D.3000101@parallels.com> <alpine.DEB.2.00.1205211312270.30649@router.home> <4FBA9536.1020502@parallels.com> <alpine.DEB.2.00.1205211430020.10940@router.home>
In-Reply-To: <alpine.DEB.2.00.1205211430020.10940@router.home>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>, Alex Shi <alex.shi@intel.com>

On 05/21/2012 11:31 PM, Christoph Lameter wrote:
>> >  But until then, people bisecting into this patch will find a broken state,
>> >  right?
> I thought this was about clumsiness not breakage. What is broken? Aliases
> do not affect the call to __kmem_cache_shutdown. Its only called if there
> are no aliases anymore.
>
>
Well, that I missed - might be my fault. Can you point me to the exact 
point where you guarantee aliases are ignored, just so we're in the same 
page?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
