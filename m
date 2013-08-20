Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 6C62C6B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 12:57:55 -0400 (EDT)
Message-ID: <5213A002.7020408@infradead.org>
Date: Tue, 20 Aug 2013 09:57:38 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] docs: Document soft dirty behaviour for freshly created
 memory regions
References: <20130820153132.GK18673@moon>
In-Reply-To: <20130820153132.GK18673@moon>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Pavel Emelyanov <xemul@parallels.com>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On 08/20/13 08:31, Cyrill Gorcunov wrote:
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
> Cc: Marcelo Tosatti <mtosatti@redhat.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  Documentation/vm/soft-dirty.txt |    7 +++++++
>  1 file changed, 7 insertions(+)
> 
> Index: linux-2.6.git/Documentation/vm/soft-dirty.txt
> ===================================================================
> --- linux-2.6.git.orig/Documentation/vm/soft-dirty.txt
> +++ linux-2.6.git/Documentation/vm/soft-dirty.txt
> @@ -28,6 +28,13 @@ This is so, since the pages are still ma
>  the kernel does is finds this fact out and puts both writable and soft-dirty
>  bits on the PTE.
>  
> +  While in most cases tracking memory changes by #PF-s is more than enough
                                                                       enough,

> +there is still a scenario when we can loose soft dirty bit -- a task does
                                         lose soft dirty bits -- a task

> +unmap previously mapped memory region and then maps new one exactly at the

   unmaps a previously mapped memory region and then maps a new one at exactly the

> +same place. When unmap called the kernel internally clears PTEs values

               When unmap is called, the kernel internally clears PTE values

> +including soft dirty bit. To notify user space application about such
                        bits.

> +memory region renewal the kernel always mark new memory regions (and
                                           marks

> +expanded regions) as soft dirtified.

or:                  as soft dirty.

>  
>    This feature is actively used by the checkpoint-restore project. You
>  can find more details about it on http://criu.org
> --


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
