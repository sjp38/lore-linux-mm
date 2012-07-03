Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id DCBC66B0071
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 10:04:06 -0400 (EDT)
Received: by wibhq4 with SMTP id hq4so3599465wib.8
        for <linux-mm@kvack.org>; Tue, 03 Jul 2012 07:04:04 -0700 (PDT)
Date: Tue, 3 Jul 2012 16:04:01 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [MMTests] IO metadata on XFS
Message-ID: <20120703140401.GB5103@phenom.ffwll.local>
References: <20120620113252.GE4011@suse.de>
 <20120629111932.GA14154@suse.de>
 <20120629112505.GF14154@suse.de>
 <20120701235458.GM19223@dastard>
 <20120702063226.GA32151@infradead.org>
 <20120702143215.GS14154@suse.de>
 <20120702193516.GX14154@suse.de>
 <20120703130414.GD14154@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120703130414.GD14154@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, dri-devel@lists.freedesktop.org, Keith Packard <keithp@keithp.com>, Eugeni Dodonov <eugeni.dodonov@intel.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Chris Wilson <chris@chris-wilson.co.uk>

On Tue, Jul 03, 2012 at 02:04:14PM +0100, Mel Gorman wrote:
> On Mon, Jul 02, 2012 at 08:35:16PM +0100, Mel Gorman wrote:
> > > <SNIP>
> > >
> > It was obvious very quickly that there were two distinct regression so I
> > ran two bisections. One led to a XFS and the other led to an i915 patch
> > that enables RC6 to reduce power usage.
> > 
> > [c999a223: xfs: introduce an allocation workqueue]
> > [aa464191: drm/i915: enable plain RC6 on Sandy Bridge by default]
> > 
> > gdm was running on the machine so i915 would have been in use. 
> 
> Bah, more PEBKAC. gdm was *not* running on this machine. i915 is loaded
> but X is not.

See my little explanation of rc6, just loading the driver will have
effects. But I'm happy to know that the issue also happens without using
it, makes it really unlikely it's an issue with the gpu or i915.ko ;-)
-Daniel
-- 
Daniel Vetter
Mail: daniel@ffwll.ch
Mobile: +41 (0)79 365 57 48

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
