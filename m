Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.44-mm1
Date: Sun, 20 Oct 2002 22:32:47 -0400
References: <3DB2FFEA.4048E82@digeo.com>
In-Reply-To: <3DB2FFEA.4048E82@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200210202232.47601.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

Looks like something was missed (UP config):

if [ -r System.map ]; then /sbin/depmod -ae -F System.map  2.5.44-mm1; fi
depmod: *** Unresolved symbols in /lib/modules/2.5.44-mm1/kernel/drivers/char/agp/agpgart.o
depmod:         page_states__per_cpu
depmod: *** Unresolved symbols in /lib/modules/2.5.44-mm1/kernel/drivers/char/drm/mga.o
depmod:         page_states__per_cpu
depmod: *** Unresolved symbols in /lib/modules/2.5.44-mm1/kernel/fs/ext3/ext3.o
depmod:         posix_acl_create_masq
depmod:         posix_acl_permission
depmod:         posix_acl_clone
depmod:         posix_acl_alloc
depmod:         posix_acl_chmod_masq
depmod:         posix_acl_valid
depmod:         posix_acl_equiv_mode
depmod: *** Unresolved symbols in /lib/modules/2.5.44-mm1/kernel/net/packet/af_packet.o
depmod:         page_states__per_cpu
depmod: *** Unresolved symbols in /lib/modules/2.5.44-mm1/kernel/sound/core/snd.o
depmod:         page_states__per_cpu

Hope this helps
Ed


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
