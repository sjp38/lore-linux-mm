Subject: Re: 2.6.2-rc2-mm2
From: Torrey Hoffman <thoffman@arnor.net>
In-Reply-To: <20040130014108.09c964fd.akpm@osdl.org>
References: <20040130014108.09c964fd.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1075489136.5995.30.camel@moria.arnor.net>
Mime-Version: 1.0
Date: Fri, 30 Jan 2004 10:58:56 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux-Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2004-01-30 at 01:41, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.2-rc2/2.6.2-rc2-mm2/

I used the rc2-mm1-1 patch and got this on make modules_install:

WARNING: /lib/modules/2.6.2-rc2-mm2/kernel/net/sunrpc/sunrpc.ko needs
unknown symbol groups_free
WARNING: /lib/modules/2.6.2-rc2-mm2/kernel/fs/nfsd/nfsd.ko needs unknown
symbol sys_setgroups

Same .config had no problems in 2.6.2-rc2-mm1.

-- 
Torrey Hoffman <thoffman@arnor.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
