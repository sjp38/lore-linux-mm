Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.41-mm3
Date: Fri, 11 Oct 2002 08:18:12 -0400
References: <3DA683F4.944DFC11@digeo.com>
In-Reply-To: <3DA683F4.944DFC11@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200210110818.12165.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

doing modules_install with mm3 gets:

if [ -r System.map ]; then /sbin/depmod -ae -F System.map  2.5.41; fi
depmod: *** Unresolved symbols in /lib/modules/2.5.41/kernel/fs/ext3/ext3.o
depmod:         generic_file_aio_read
depmod:         generic_file_aio_write
depmod: *** Unresolved symbols in /lib/modules/2.5.41/kernel/fs/nfs/nfs.o
depmod:         generic_file_aio_read
depmod:         generic_file_aio_write
oscar#

Hope this helps
Ed Tomlinson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
