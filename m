Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 71A506B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 23:13:25 -0400 (EDT)
Date: Wed, 17 Oct 2012 11:13:16 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: Re: [PATCH 4/5] Move the check for ra_pages after
 VM_SequentialReadHint()
Message-ID: <20121017031316.GE13769@localhost>
References: <cover.1348309711.git.rprabhu@wnohang.net>
 <b3c8b02fb273826f864f64d4588b36758fde2b5d.1348309711.git.rprabhu@wnohang.net>
 <20120922124250.GB15962@localhost>
 <20121016181521.GD2826@Archie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121016181521.GD2826@Archie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org

On Tue, Oct 16, 2012 at 11:45:21PM +0530, Raghavendra D Prabhu wrote:
> Hi,
> 
> 
> * On Sat, Sep 22, 2012 at 08:42:50PM +0800, Fengguang Wu <fengguang.wu@intel.com> wrote:
> >it.rprabhu@wnohang.net>
> >User-Agent: Mutt/1.5.21 (2010-09-15)
> >X-Date: Sat Sep 22 18:12:50 IST 2012
> >
> >On Sat, Sep 22, 2012 at 04:03:13PM +0530, raghu.prabhu13@gmail.com wrote:
> >>From: Raghavendra D Prabhu <rprabhu@wnohang.net>
> >>
> >>page_cache_sync_readahead checks for ra->ra_pages again, so moving the check
> >>after VM_SequentialReadHint.
> >
> >Well it depends on what case you are optimizing for. I suspect there
> >are much more tmpfs users than VM_SequentialReadHint users. So this
> >change is actually not desirable wrt the more widely used cases.
> 
> shm/tmpfs doesn't use this function for fault. They have shmem_fault
> for that.  So, that shouldn't matter here. Agree?

That's true for the regular tmpfs and it still calls filemap_fault()
in the !CONFIG_SHMEM case and squashfs/cramfs etc. They together
should still overweight the VM_SequentialReadHint users?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
