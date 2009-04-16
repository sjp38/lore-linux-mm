Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9E17C5F0001
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 01:01:34 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id f25so189848rvb.26
        for <linux-mm@kvack.org>; Wed, 15 Apr 2009 22:01:34 -0700 (PDT)
Date: Thu, 16 Apr 2009 14:01:29 +0900
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH] hugetlbfs: return negative error code for bad mount
	option
Message-ID: <20090416050129.GA4083@localhost.localdomain>
References: <20090413035623.GA4156@localhost.localdomain> <20090415145910.22910363.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090415145910.22910363.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, wli@holomorphy.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 15, 2009 at 02:59:10PM -0700, Andrew Morton wrote:
> On Mon, 13 Apr 2009 12:56:23 +0900
> Akinobu Mita <akinobu.mita@gmail.com> wrote:
> 
> > This fixes the following BUG:
> > 
> > # mount -o size=MM -t hugetlbfs none /huge
> > hugetlbfs: Bad value 'MM' for mount option 'size=MM'
> > ------------[ cut here ]------------
> > kernel BUG at fs/super.c:996!
> 
> I can't tell where this BUG (or WARN?) is happening unless I know
> exactly which kernel version was tested.

Oh, sorry.

> I assume that it is BUG_ON(!mnt->mnt_sb); in vfs_kern_mount()?

Yes. In vfs_kern_mount(), type->get_sb() returns 1 then BUG_ON(!mnt->mnt_sb);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
