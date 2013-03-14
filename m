Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id A83996B0027
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 16:58:36 -0400 (EDT)
Received: from mailout-de.gmx.net ([10.1.76.33]) by mrigmx.server.lan
 (mrigmx002) with ESMTP (Nemesis) id 0MJYbl-1UIA6b41TX-0034zh for
 <linux-mm@kvack.org>; Thu, 14 Mar 2013 21:58:35 +0100
Message-ID: <514239F7.3050704@gmx.de>
Date: Thu, 14 Mar 2013 21:58:31 +0100
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
Subject: Re: SLUB + UML : WARNING: at mm/page_alloc.c:2386
References: <51422008.3020208@gmx.de> <CAFLxGvyzkSsUJQMefeB2PcVBykZNqCQe5k19k0MqyVr111848w@mail.gmail.com>
In-Reply-To: <CAFLxGvyzkSsUJQMefeB2PcVBykZNqCQe5k19k0MqyVr111848w@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Cc: linux-mm@kvack.org, user-mode-linux-user@lists.sourceforge.net, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On 03/14/2013 09:51 PM, richard -rw- weinberger wrote:
> Can you please re-run with the attached patch.
> I'm wondering how much memory is requested.
>>From reading the source I'd say it must be less than PAGE_SIZE.
> But such a small allocation would not trigger the WARN_ON()...


2013-03-14T21:56:58.000+01:00 trinity sshd[1158]: pam_unix(sshd:session): session opened for user tfoerste by (uid=0)
2013-03-14T21:56:59.852+01:00 trinity kernel: memdup_user: -14
2013-03-14T21:56:59.852+01:00 trinity kernel: ------------[ cut here ]------------
2013-03-14T21:56:59.852+01:00 trinity kernel: WARNING: at mm/page_alloc.c:2386 __alloc_pages_nodemask+0x153/0x750()
2013-03-14T21:56:59.852+01:00 trinity kernel: 38bfbd14:  [<08342dd8>] dump_stack+0x22/0x24
2013-03-14T21:56:59.852+01:00 trinity kernel: 38bfbd2c:  [<0807d0da>] warn_slowpath_common+0x5a/0x80
2013-03-14T21:56:59.852+01:00 trinity kernel: 38bfbd54:  [<0807d1a3>] warn_slowpath_null+0x23/0x30
2013-03-14T21:56:59.852+01:00 trinity kernel: 38bfbd64:  [<080d3213>] __alloc_pages_nodemask+0x153/0x750
2013-03-14T21:56:59.852+01:00 trinity kernel: 38bfbdf0:  [<080d3838>] __get_free_pages+0x28/0x50
2013-03-14T21:56:59.852+01:00 trinity kernel: 38bfbe08:  [<080fc48f>] __kmalloc_track_caller+0x3f/0x180
2013-03-14T21:56:59.852+01:00 trinity kernel: 38bfbe30:  [<080dec82>] memdup_user+0x32/0x70
2013-03-14T21:56:59.853+01:00 trinity kernel: 38bfbe4c:  [<080dee7e>] strndup_user+0x3e/0x60
2013-03-14T21:56:59.853+01:00 trinity kernel: 38bfbe68:  [<0811b440>] copy_mount_string+0x30/0x50
2013-03-14T21:56:59.853+01:00 trinity kernel: 38bfbe7c:  [<0811be0a>] sys_mount+0x1a/0xe0
2013-03-14T21:56:59.853+01:00 trinity kernel: 38bfbeac:  [<08062a92>] handle_syscall+0x82/0xb0
2013-03-14T21:56:59.853+01:00 trinity kernel: 38bfbef4:  [<08074e7d>] userspace+0x46d/0x590
2013-03-14T21:56:59.853+01:00 trinity kernel: 38bfbfec:  [<0805f7cc>] fork_handler+0x6c/0x70
2013-03-14T21:56:59.853+01:00 trinity kernel: 38bfbffc:  [<5a5a5a5a>] 0x5a5a5a5a
2013-03-14T21:56:59.853+01:00 trinity kernel:
2013-03-14T21:56:59.853+01:00 trinity kernel: ---[ end trace 5bf182a223bd623c ]---
2013-03-14T21:56:59.853+01:00 trinity kernel: memdup_user: -14
2013-03-14T21:56:59.942+01:00 trinity kernel: VFS: Warning: trinity-child0 using old stat() call. Recompile your binary.
2013-03-14T21:56:59.942+01:00 trinity kernel: VFS: Warning: trinity-child0 using old stat() call. Recompile your binary.
2013-03-14T21:56:59.942+01:00 trinity kernel: VFS: Warning: trinity-child0 using old stat() call. Recompile your binary.
2013-03-14T21:57:01.000+01:00 trinity sshd[1160]: Received disconnect from 192.168.0.254: 11: disconnected by user
2013-03-14T21:57:01.000+01:00 trinity sshd[1158]: pam_unix(sshd:session): session closed for user tfoerste
2013-03-14T21:57:09.087+01:00 trinity kernel: memdup_user: -14
2013-03-14T21:57:18.191+01:00 trinity kernel: memdup_user: 4089
2013-03-14T21:57:26.236+01:00 trinity kernel: memdup_user: 28




-- 
MfG/Sincerely
Toralf FA?rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
