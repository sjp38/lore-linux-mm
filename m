Message-ID: <3FF2C93F.2080908@pobox.com>
Date: Wed, 31 Dec 2003 08:03:59 -0500
From: Jeff Garzik <jgarzik@pobox.com>
MIME-Version: 1.0
Subject: Re: 2.6.0-rc1-mm1
References: <20031231004725.535a89e4.akpm@osdl.org>
In-Reply-To: <20031231004725.535a89e4.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-rc1/2.6.0-rc1-mm1/
> 
> 
> A few small additions, but mainly a resync with mainline.
> 
> 
> 
> 
> Changes since 2.6.0-mm2:
> 
> 
> -2.6.0-netdrvr-exp3.patch
> -2.6.0-netdrvr-exp3-fix.patch
> -Space_c-warning-fix.patch
> -via-rhine-netpoll-support.patch
> +2.6.0-bk2-netdrvr-exp1.patch


Argh, I missed a bonding build fix, and warning fix...  Plus rediffed 
against 2.6.0-rc1:

http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/2.6.0-rc1-netdrvr-exp1.patch.bz2
http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/2.6.0-rc1-netdrvr-exp1.log

Have another big batch from Al Viro pending, with yet-more fixes from 
his audits...

	Jeff



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
