Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7A62D6B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 11:13:03 -0500 (EST)
Received: by mail-qa0-f46.google.com with SMTP id n4so22834952qaq.5
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 08:13:03 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id k95si7886111qgd.40.2015.02.23.08.13.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Feb 2015 08:13:02 -0800 (PST)
Date: Mon, 23 Feb 2015 11:12:22 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 0/4] cleancache: remove limit on the number of cleancache
 enabled filesystems
Message-ID: <20150223161222.GD30733@l.oracle.com>
References: <cover.1424628280.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1424628280.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>, Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>, Stefan Hengelein <ilendir@googlemail.com>, Florian Schmaus <fschmaus@gmail.com>, Andor Daam <andor.daam@googlemail.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Feb 22, 2015 at 09:31:51PM +0300, Vladimir Davydov wrote:
> Hi,
> 
> Currently, maximal number of cleancache enabled filesystems equals 32,
> which is insufficient nowadays, because a Linux host can have hundreds
> of containers on board, each of which might want its own filesystem.
> This patch set targets at removing this limitation - see patch 4 for
> more details. Patches 1-3 prepare the code for this change.

Hey Vladimir,

Thank you for posting these patches. I was wondering if you had
run through some of the different combinations that you can
load the filesystems/tmem drivers in random order? The #4 patch
deleted a nice chunk of documentation that outlines the different
combinations.

Thank you!
> 
> Thanks,
> 
> Vladimir Davydov (4):
>   ocfs2: copy fs uuid to superblock
>   cleancache: zap uuid arg of cleancache_init_shared_fs
>   cleancache: forbid overriding cleancache_ops
>   cleancache: remove limit on the number of cleancache enabled
>     filesystems
> 
>  Documentation/vm/cleancache.txt |    4 +-
>  drivers/xen/tmem.c              |   16 ++-
>  fs/ocfs2/super.c                |    4 +-
>  fs/super.c                      |    2 +-
>  include/linux/cleancache.h      |   13 +-
>  mm/cleancache.c                 |  270 +++++++++++----------------------------
>  6 files changed, 94 insertions(+), 215 deletions(-)
> 
> -- 
> 1.7.10.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
