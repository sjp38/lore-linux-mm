Date: Fri, 13 Feb 2004 23:27:51 -0600
Subject: Re: 2.6.3-rc2-mm1
Message-ID: <20040214052751.GA11750@gforce.johnson.home>
References: <20040212015710.3b0dee67.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040212015710.3b0dee67.akpm@osdl.org>
From: glennpj@charter.net (Glenn Johnson)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 12, 2004 at 01:57:10AM -0800, Andrew Morton wrote:

> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.3-rc2/2.6.3-rc2-mm1/

> +sysfs-class-10-vc.patch
> 
>  Bring back this patch, see if it triggers the tty race again.

It does on one of my machines, a P4c with HT enabled.  This is the same
machine that had the problem before.  Backing out the patch "fixes" it.

-- 
Glenn Johnson
glennpj@charter.net
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
