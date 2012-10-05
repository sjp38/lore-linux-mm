Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id E256B6B005A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 17:28:36 -0400 (EDT)
Date: Fri, 5 Oct 2012 14:28:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm] get rid of the remaining VM_RESERVED usage
Message-Id: <20121005142835.254b9809.akpm@linux-foundation.org>
In-Reply-To: <20121004123639.GE27536@dhcp22.suse.cz>
References: <20121004113428.GD27536@dhcp22.suse.cz>
	<20121004123639.GE27536@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org

On Thu, 4 Oct 2012 14:36:40 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 04-10-12 13:34:28, Michal Hocko wrote:
> > Hi Andrew, Konstantin,
> > it seems that these slipped through when VM_RESERVED was removed by
> > broken-out/mm-kill-vma-flag-vm_reserved-and-mm-reserved_vm-counter.patch
> > 
> > I hope I didn't screw anything... Please merge it with the original
> > patch if it looks correctly.
> > ---
> >  drivers/media/video/meye.c                      |    2 +-
> >  drivers/media/video/omap/omap_vout.c            |    2 +-
> >  drivers/media/video/sn9c102/sn9c102_core.c      |    1 -
> >  drivers/media/video/usbvision/usbvision-video.c |    2 --
> >  drivers/media/video/videobuf-dma-sg.c           |    2 +-
> >  drivers/media/video/videobuf-vmalloc.c          |    2 +-
> >  drivers/media/video/videobuf2-memops.c          |    2 +-
> >  drivers/media/video/vino.c                      |    2 +-
> >  drivers/staging/media/easycap/easycap_main.c    |    2 +-
> 
> Hmm, those files are in Linus tree but they are removed from mmotm by
> broken-out/linux-next.patch. Strange.

yeah, drivers/media has been spinning like a top lately.  I think I saw
a pull request go past today so I'll try to remember to do a tree-wide
grep for VM_RESERVED on Monday to check for leftovers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
