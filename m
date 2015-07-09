Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 42D3F6B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 10:03:34 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so19790011wiw.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 07:03:33 -0700 (PDT)
Date: Thu, 9 Jul 2015 17:02:48 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFCv3 0/5] enable migration of driver pages
Message-ID: <20150709140248.GA27109@node.dhcp.inet.fi>
References: <1436243785-24105-1-git-send-email-gioh.kim@lge.com>
 <20150707153701.bfcde75108d1fb8aaedc8134@linux-foundation.org>
 <559C68B3.3010105@lge.com>
 <20150707170746.1b91ba0d07382cbc9ba3db92@linux-foundation.org>
 <559C6CA6.1050809@lge.com>
 <CAPM=9txmUJ58=CAxDhf12Y3Y8wz7CGBy-Bd4pQ8YAAKDsCxU8w@mail.gmail.com>
 <559DB86D.40000@lge.com>
 <20150709130848.GD21858@phenom.ffwll.local>
 <20150709133301.GG5176@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150709133301.GG5176@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ville =?iso-8859-1?Q?Syrj=E4l=E4?= <ville.syrjala@linux.intel.com>
Cc: Gioh Kim <gioh.kim@lge.com>, Dave Airlie <airlied@gmail.com>, dri-devel <dri-devel@lists.freedesktop.org>, Andrew Morton <akpm@linux-foundation.org>, jlayton@poochiereds.net, bfields@fieldses.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, Al Viro <viro@zeniv.linux.org.uk>, "Michael S. Tsirkin" <mst@redhat.com>, koct9i@gmail.com, minchan@kernel.org, aquini@redhat.com, linux-fsdevel@vger.kernel.org, "open list:VIRTIO CORE, NET..." <virtualization@lists.linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, open@kvack.org, list@kvack.org, ABI/API <linux-api@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, gunho.lee@lge.com, Gioh Kim <gurugio@hanmail.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>

On Thu, Jul 09, 2015 at 04:33:01PM +0300, Ville SyrjA?lA? wrote:
> On Thu, Jul 09, 2015 at 03:08:48PM +0200, Daniel Vetter wrote:
> > On Thu, Jul 09, 2015 at 08:55:25AM +0900, Gioh Kim wrote:
> > > 
> > > 
> > > 2015-07-09 i??i ? 7:47i?? Dave Airlie i?'(e??) i?' e,?:
> > > >>>
> > > >>>
> > > >>>Can the various in-kernel GPU drivers benefit from this?  If so, wiring
> > > >>>up one or more of those would be helpful?
> > > >>
> > > >>
> > > >>I'm sure that other in-kernel GPU drivers can have benefit.
> > > >>It must be helpful.
> > > >>
> > > >>If I was familiar with other in-kernel GPU drivers code, I tried to patch
> > > >>them.
> > > >>It's too bad.
> > > >
> > > >I'll bring dri-devel into the loop here.
> > > >
> > > >ARM GPU developers please take a look at this stuff, Laurent, Rob,
> > > >Eric I suppose.
> > > 
> > > I sent a patch, https://lkml.org/lkml/2015/3/24/1182, and my opinion about compaction
> > > to ARM GPU developers via Korea ARM branch.
> > > I got a reply that they had no time to review it.
> > > 
> > > I hope they're interested to this patch.
> > 
> > i915 gpus would support 64kb and 2mb pages, but we never implemented this.
> > I don't think this would fit for gem based drivers since our backing
> > storage is shmemfs. So if we want to implement page migration (which we'd
> > probably want to make large pages work well) we'd need to pimp shmem to a)
> > hand large pages to us b) forward the migrate calls. Probably that means
> > we need to build our own gemfs reusing shmemfs code.
> 
> AFAIK there are efforts ongoing to make large pages work with shmem.
> 
> Kirill, IIRC you mentioned that you're were looking into this a while
> back?

I work in this direction, but don't have anything to show at the moment.

Hugh has published his implementation of huge tmpfs back in February:

http://lkml.kernel.org/g/alpine.LSU.2.11.1502201941340.14414@eggly.anvils

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
