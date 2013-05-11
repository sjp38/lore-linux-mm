Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 82C786B0032
	for <linux-mm@kvack.org>; Sat, 11 May 2013 04:19:38 -0400 (EDT)
Received: from mailout-de.gmx.net ([10.1.76.33]) by mrigmx.server.lan
 (mrigmx002) with ESMTP (Nemesis) id 0MZzWr-1UpZNG0ilz-00LkNA for
 <linux-mm@kvack.org>; Sat, 11 May 2013 10:19:37 +0200
Message-ID: <518DFF16.1070408@gmx.de>
Date: Sat, 11 May 2013 10:19:34 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
Subject: Re: WARNING: at mm/slab_common.c:376 kmalloc_slab+0x33/0x80()
References: <518D6C18.4070607@gmx.de>
In-Reply-To: <518D6C18.4070607@gmx.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "user-mode-linux-user@lists.sourceforge.net" <user-mode-linux-user@lists.sourceforge.net>

On 05/10/2013 11:52 PM, Toralf FA?rster wrote:
> The bisected commit introduced this WARNING: on a user mode linux guest
> if the UML guest is fuzz tested with trinity :

Well, the behaviour is much older, a test with an UML guest kernel 3.7.10 showed a similar thing :
Sry for the noise.


2013-05-11T10:16:30.841+02:00 trinity kernel: ------------[ cut here ]------------
2013-05-11T10:16:30.841+02:00 trinity kernel: WARNING: at mm/page_alloc.c:2384 __alloc_pages_nodemask+0x13c/0x740()
2013-05-11T10:16:30.841+02:00 trinity kernel: 3fda7d10:  [<08332bd8>] dump_stack+0x22/0x24
2013-05-11T10:16:30.841+02:00 trinity kernel: 3fda7d28:  [<0807d6ca>] warn_slowpath_common+0x5a/0x80
2013-05-11T10:16:30.841+02:00 trinity kernel: 3fda7d50:  [<0807d793>] warn_slowpath_null+0x23/0x30
2013-05-11T10:16:30.841+02:00 trinity kernel: 3fda7d60:  [<080d43ac>] __alloc_pages_nodemask+0x13c/0x740
2013-05-11T10:16:30.841+02:00 trinity kernel: 3fda7df0:  [<080d49d8>] __get_free_pages+0x28/0x50
2013-05-11T10:16:30.841+02:00 trinity kernel: 3fda7e08:  [<080fc28d>] __kmalloc_track_caller+0x3d/0x170
2013-05-11T10:16:30.841+02:00 trinity kernel: 3fda7e30:  [<080dfbe6>] memdup_user+0x26/0x70
2013-05-11T10:16:30.841+02:00 trinity kernel: 3fda7e4c:  [<080dfdee>] strndup_user+0x3e/0x60
2013-05-11T10:16:30.856+02:00 trinity kernel: 3fda7e68:  [<0811ae70>] copy_mount_string+0x30/0x50
2013-05-11T10:16:30.856+02:00 trinity kernel: 3fda7e7c:  [<0811b6ba>] sys_mount+0x1a/0xe0
2013-05-11T10:16:30.856+02:00 trinity kernel: 3fda7eac:  [<08062c32>] handle_syscall+0x82/0xb0
2013-05-11T10:16:30.856+02:00 trinity kernel: 3fda7ef4:  [<0807503d>] userspace+0x46d/0x590
2013-05-11T10:16:30.856+02:00 trinity kernel: 3fda7fec:  [<0805f80c>] fork_handler+0x6c/0x70
2013-05-11T10:16:30.856+02:00 trinity kernel: 3fda7ffc:  [<00000000>] 0x0
2013-05-11T10:16:30.856+02:00 trinity kernel:
2013-05-11T10:16:30.856+02:00 trinity kernel: ---[ end trace db5193a4984ce93f ]---

-- 
MfG/Sincerely
Toralf FA?rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
