Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 9BAEF6B004D
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 14:55:17 -0500 (EST)
Date: Wed, 21 Nov 2012 11:55:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [memcg:since-3.6 456/496]
 drivers/virtio/virtio_balloon.c:145:10: warning: format '%zu' expects
 argument of type 'size_t', but argument 4 has type 'unsigned int'
Message-Id: <20121121115516.99b81f9a.akpm@linux-foundation.org>
In-Reply-To: <20121121154734.GE8761@dhcp22.suse.cz>
References: <50acf531.zaJ8wmQW+6NHVbhr%fengguang.wu@intel.com>
	<20121121154734.GE8761@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: kbuild test robot <fengguang.wu@intel.com>, Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org

On Wed, 21 Nov 2012 16:47:34 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> Bahh, my fault.
> I screwed while reverting previous version of the virtio patchset.
> Pushed to my tree. Thanks for reporting...
> 
> On Wed 21-11-12 23:37:21, Wu Fengguang wrote:
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-3.6
> > head:   223cdc1faeea55aa70fef23d54720ad3fdaf4c93
> > commit: 12cf48af8968fa1d0cc4c06065d7c37c3560c171 [456/496] virtio_balloon: introduce migration primitives to balloon pages
> > config: make ARCH=x86_64 allmodconfig
> ---
> >From 35f423ffe01b62cbe5bf88b0acbff5b3b4a09777 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Wed, 21 Nov 2012 16:42:02 +0100
> Subject: [PATCH] virtio_balloon-introduce-migration-primitives-to-balloon-pages-fix-fix-fix
>  mismerge fix
> 
> %u got back to %zu while while reverting
> %(4f2ac8495ba0477d8c3208de96dae7d1db6c2d49) obsolete version of
> virtio_balloon: introduce migration primitives to balloon pages
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  drivers/virtio/virtio_balloon.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index d0cfb7e..8cde4c9 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -141,7 +141,7 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
>  		if (!page) {
>  			if (printk_ratelimit())
>  				dev_printk(KERN_INFO, &vb->vdev->dev,
> -					   "Out of puff! Can't get %zu pages\n",
> +					   "Out of puff! Can't get %u pages\n",
>  					    VIRTIO_BALLOON_PAGES_PER_PAGE);
>  			/* Sleep for at least 1/5 of a second before retry. */
>  			msleep(200);

Yeah, that's quite old code - printk_ratelimit is naughty and has been
replaced by dev_info_ratelimited().

Are you using mmotm or http://ozlabs.org/~akpm/mmots/?  It might be
better to grab mmots at least while linux-next is on pause.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
