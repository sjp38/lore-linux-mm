Message-ID: <3EE6F3B7.9040809@gts.it>
Date: Wed, 11 Jun 2003 11:17:43 +0200
From: Stefano Rivoir <s.rivoir@gts.it>
MIME-Version: 1.0
Subject: Re: 2.5.70-mm8
References: <20030611013325.355a6184.akpm@digeo.com>
In-Reply-To: <20030611013325.355a6184.akpm@digeo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.70/2.5.70-mm8/

arch/i386/kernel/setup.c: In function 'setup_early_printk':
arch/i386/kernel/setup.c:919: error: invalid lvalue in unary '&'
make[1]: *** [arch/i386/kernel/setup.o] Error 1

Bye

-- 
Stefano RIVOIR
GTS Srl



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
