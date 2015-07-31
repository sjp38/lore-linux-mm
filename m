Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id D39519003C8
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 05:35:20 -0400 (EDT)
Received: by laah7 with SMTP id h7so40497015laa.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 02:35:20 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id c5si3111515lag.135.2015.07.31.02.35.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 02:35:18 -0700 (PDT)
Date: Fri, 31 Jul 2015 12:34:57 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v9 0/8] idle memory tracking
Message-ID: <20150731093457.GG8100@esperanza>
References: <cover.1437303956.git.vdavydov@parallels.com>
 <20150729123629.GI15801@dhcp22.suse.cz>
 <20150729135907.GT8100@esperanza>
 <20150729142618.GJ15801@dhcp22.suse.cz>
 <20150729152817.GV8100@esperanza>
 <20150729154718.GN15801@dhcp22.suse.cz>
 <20150729162908.GY8100@esperanza>
 <20150729143015.e8420eca17acbd36d1ce9242@linux-foundation.org>
 <20150730091212.GA8100@esperanza>
 <20150730130122.GC8100@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150730130122.GC8100@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jul 30, 2015 at 04:01:22PM +0300, Vladimir Davydov wrote:
> On Thu, Jul 30, 2015 at 12:12:12PM +0300, Vladimir Davydov wrote:
> > On Wed, Jul 29, 2015 at 02:30:15PM -0700, Andrew Morton wrote:
> > > On Wed, 29 Jul 2015 19:29:08 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:
> > > 
> > > > /proc/kpageidle should probably live somewhere in /sys/kernel/mm, but I
> > > > added it where similar files are located (kpagecount, kpageflags) to
> > > > keep things consistent.
> > > 
> > > I think these files should be moved elsewhere.  Consistency is good,
> > > but not when we're being consistent with a bad thing.
> > > 
> > > So let's place these in /sys/kernel/mm and then start being consistent
> > > with that?
> > 
> > I really don't think we should separate kpagecgroup from kpagecount and
> > kpageflags, because they look very similar (each of them is read-only,
> > contains an array of u64 values referenced by PFN). Scattering these
> > files between different filesystems would look ugly IMO.
> > 
> > However, kpageidle is somewhat different (it's read-write, contains a
> > bitmap) so I think it's worth moving it to /sys/kernel/mm. We have to
> > move the code from fs/proc to mm/something then to remove dependency
> > from PROC_FS, which would be unnecessary. Let me give it a try.
> 
> Here it goes:
> 
> From: Vladimir Davydov <vdavydov@parallels.com>
> Subject: [PATCH] Move /proc/kpageidle to /sys/kernel/mm/page_idle/bitmap

Since it is rather difficult to merge it into proc-add-kpageidle, should
I resend the whole series with all fixes included, provided you find
this patch OK of course?

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
