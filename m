Date: Fri, 6 Sep 2002 02:50:10 +0200
From: Axel Siebenwirth <axel@hh59.org>
Subject: Re: 2.5.33-mm3
Message-ID: <20020906005010.GB8109@prester.freenet.de>
References: <3D77143F.E441133D@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D77143F.E441133D@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Andrew!

On Thu, 05 Sep 2002, Andrew Morton wrote:

> URL: http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.33/2.5.33-mm3/
> 
> +filemap-integration.patch
> 
>   Cleanup and code consolidation for readv and writev: generic_file_read()
>   and generic_file_write() take an iovec, and tons of code goes away.
> 
>   A work in progress.

Just compiled 2.5.33 with mm3 patch:

if [ -r System.map ]; then /sbin/depmod -ae -F System.map  2.5.33; fi
depmod: *** Unresolved symbols in /lib/modules/2.5.33/kernel/fs/ext2/ext2.o
depmod:         generic_file_writev

Best regards,
Axel Siebenwirth
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
