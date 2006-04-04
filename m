Date: Tue, 4 Apr 2006 20:04:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 2/6] Swapless V1:  Add SWP_TYPE_MIGRATION
Message-Id: <20060404200409.a78cdb2a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060404065750.24532.67454.sendpatchset@schroedinger.engr.sgi.com>
References: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
	<20060404065750.24532.67454.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, lee.schermerhorn@hp.com, lhms-devel@lists.sourceforge.net, taka@valinux.co.jp, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Mon, 3 Apr 2006 23:57:50 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

>
>  #define MAX_SWAPFILES_SHIFT	5
> -#define MAX_SWAPFILES		(1 << MAX_SWAPFILES_SHIFT)
> +#define MAX_SWAPFILES		((1 << MAX_SWAPFILES_SHIFT)-1)
> +
> +/* Use last entry for page migration swap entries */
> +#define SWP_TYPE_MIGRATION	MAX_SWAPFILES

How about this ?

#ifdef CONFIG_MIGRATION
#define MAX_SWAPFILES ((1 << MAX_SWAPFILES_SHIFT) - 1)
#else
#define MAX_SWAPFILES (1 << MAX_SWAPFILES_SHIFT)
#endif

#define SWP_TYPE_MIGRATION (MAX_SWAPFILES + 1)


.....but I don't think there is a user who uses 32 swaps....

--Kame
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
