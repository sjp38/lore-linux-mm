Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.42-mm2
Date: Sat, 12 Oct 2002 09:19:55 -0400
References: <3DA7C3A5.98FCC13E@digeo.com>
In-Reply-To: <3DA7C3A5.98FCC13E@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200210120919.55414.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

This builds fine but gets errors in depmod.

make -f arch/i386/lib/Makefile modules_install
if [ -r System.map ]; then /sbin/depmod -ae -F System.map  2.5.42-mm2; fi
depmod: *** Unresolved symbols in /lib/modules/2.5.42-mm2/kernel/fs/ext3/ext3.o
depmod:         generic_file_aio_read
depmod:         generic_file_aio_write
depmod: *** Unresolved symbols in /lib/modules/2.5.42-mm2/kernel/fs/nfs/nfs.o
depmod:         generic_file_aio_read
depmod:         generic_file_aio_write
depmod: *** Unresolved symbols in /lib/modules/2.5.42-mm2/kernel/fs/nfsd/nfsd.o
depmod:         auth_domain_find
depmod:         cache_fresh
depmod:         unix_domain_find
depmod:         auth_domain_put
depmod:         cache_flush
depmod:         cache_unregister
depmod:         add_hex
depmod:         cache_check
depmod:         svcauth_unix_purge
depmod:         get_word
depmod:         cache_clean
depmod:         cache_register
depmod:         auth_unix_lookup
depmod:         auth_unix_add_addr
depmod:         cache_init
depmod:         auth_unix_forget_old
depmod:         add_word

Hope this helps,
Ed Tomlinson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
