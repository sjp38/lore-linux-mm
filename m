Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 13B806B00FA
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 12:11:26 -0400 (EDT)
Date: Mon, 16 Apr 2012 11:52:07 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [Lsf] [RFC] writeback and cgroup
Message-ID: <20120416155207.GB15437@redhat.com>
References: <20120404145134.GC12676@redhat.com>
 <20120407080027.GA2584@quack.suse.cz>
 <20120410180653.GJ21801@redhat.com>
 <20120410210505.GE4936@quack.suse.cz>
 <20120410212041.GP21801@redhat.com>
 <20120410222425.GF4936@quack.suse.cz>
 <20120411154005.GD16692@redhat.com>
 <1334406314.2528.90.camel@twins>
 <20120416125432.GB12776@redhat.com>
 <20120416130707.GA10532@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120416130707.GA10532@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, ctalbott@google.com, rni@google.com, andrea@betterlinux.com, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, lsf@lists.linux-foundation.org, linux-mm@kvack.org, jmoyer@redhat.com, lizefan@huawei.com, linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org

On Mon, Apr 16, 2012 at 09:07:07PM +0800, Fengguang Wu wrote:

[..]
> Vivek, I noticed these lines in cfq code
> 
>                 sscanf(dev_name(bdi->dev), "%u:%u", &major, &minor);
> 
> Why not use bdi->dev->devt?  The problem is that dev_name() will
> return "btrfs-X" for btrfs rather than "major:minor".

Isn't bdi->dev->devt 0?  I see following code.

add_disk()
   bdi_register_dev()
      bdi_register()
         device_create_vargs(MKDEV(0,0))
	      dev->devt = devt = MKDEV(0,0);

So for normal block devices, I think bdi->dev->devt will be zero, that's
why probably we don't use it.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
