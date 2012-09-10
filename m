Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 556C46B0069
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 09:06:23 -0400 (EDT)
Date: Mon, 10 Sep 2012 21:06:17 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [glommer-memcg:kmemcg-slab 57/62]
 drivers/video/riva/fbdev.c:281:9: sparse: preprocessor token MAX_LEVEL
 redefined
Message-ID: <20120910130617.GA11963@localhost>
References: <20120910111638.GC9660@localhost>
 <20120910125759.GA11808@localhost>
 <504DE3DA.7000802@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <504DE3DA.7000802@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: kernel-janitors@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Sep 10, 2012 at 04:58:02PM +0400, Glauber Costa wrote:
> On 09/10/2012 04:57 PM, Fengguang Wu wrote:
> > Glauber,
> > 
> > The patch entitled
> > 
> >  sl[au]b: Allocate objects from memcg cache
> > 
> > changes
> > 
> >  include/linux/slub_def.h |   15 ++++++++++-----
> > 
> > which triggers this warning:
> > 
> > drivers/video/riva/fbdev.c:281:9: sparse: preprocessor token MAX_LEVEL redefined
> > 
> > It's the MAX_LEVEL that is defined in include/linux/idr.h.
> > 
> > MAX_LEVEL is obviously too generic. Better adding some prefix to it?
> > 
> 
> I don't see any MAX_LEVEL definition in this patch. You say it is
> defined in include/linux/idr.h, and as the diffstat shows, I am not
> touching this file.

It's a rather *unexpected* side effect. You changed slub_def.h to
include memcontrol.h/cgroup.h which in turn includes idr.h.

> I think this needs patching independently.

Yes, sure. And perhaps send it for quick inclusion before your patches?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
