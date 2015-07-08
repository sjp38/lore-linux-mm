Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9DB7B6B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 04:12:56 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so204700363wib.1
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 01:12:56 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r7si1882237wix.23.2015.07.08.01.12.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Jul 2015 01:12:55 -0700 (PDT)
Date: Wed, 8 Jul 2015 10:12:49 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH block/for-4.3] writeback: explain why @inode is allowed
 to be NULL for inode_congested()
Message-ID: <20150708081248.GA725@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-31-git-send-email-tj@kernel.org>
 <20150630152105.GP7252@quack.suse.cz>
 <20150702014634.GF26440@mtj.duckdns.org>
 <20150703121721.GJ23329@quack.suse.cz>
 <20150704151200.GA13251@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150704151200.GA13251@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Sat 04-07-15 11:12:00, Tejun Heo wrote:
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Suggested-by: Jan Kara <jack@suse.cz>
> ---
> Hello,
> 
> So, something like this.  I'll resend this patch as part of a patch
> series once -rc1 drops.
  Looks good. Thanks!

								Honza

>  fs/fs-writeback.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -700,7 +700,7 @@ void wbc_account_io(struct writeback_con
>  
>  /**
>   * inode_congested - test whether an inode is congested
> - * @inode: inode to test for congestion
> + * @inode: inode to test for congestion (may be NULL)
>   * @cong_bits: mask of WB_[a]sync_congested bits to test
>   *
>   * Tests whether @inode is congested.  @cong_bits is the mask of congestion
> @@ -710,6 +710,9 @@ void wbc_account_io(struct writeback_con
>   * determined by whether the cgwb (cgroup bdi_writeback) for the blkcg
>   * associated with @inode is congested; otherwise, the root wb's congestion
>   * state is used.
> + *
> + * @inode is allowed to be NULL as this function is often called on
> + * mapping->host which is NULL for the swapper space.
>   */
>  int inode_congested(struct inode *inode, int cong_bits)
>  {
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
