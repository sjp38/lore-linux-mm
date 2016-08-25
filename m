Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BADFD8308D
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:11:06 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l4so27614561wml.0
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 00:11:06 -0700 (PDT)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id s2si12407247wjc.195.2016.08.25.00.11.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 00:11:05 -0700 (PDT)
Received: by mail-wm0-f47.google.com with SMTP id o80so56733064wme.1
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 00:11:05 -0700 (PDT)
Date: Thu, 25 Aug 2016 09:11:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM detection regressions since 4.7
Message-ID: <20160825071103.GC4230@dhcp22.suse.cz>
References: <20160822093249.GA14916@dhcp22.suse.cz>
 <20160822093707.GG13596@dhcp22.suse.cz>
 <20160822100528.GB11890@kroah.com>
 <20160822105441.GH13596@dhcp22.suse.cz>
 <20160822133114.GA15302@kroah.com>
 <20160822134227.GM13596@dhcp22.suse.cz>
 <20160822150517.62dc7cce74f1af6c1f204549@linux-foundation.org>
 <20160823074339.GB23577@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160823074339.GB23577@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>
Cc: Greg KH <gregkh@linuxfoundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 23-08-16 09:43:39, Michal Hocko wrote:
> On Mon 22-08-16 15:05:17, Andrew Morton wrote:
> > On Mon, 22 Aug 2016 15:42:28 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > > Of course, if Linus/Andrew doesn't like to take those compaction
> > > improvements this late then I will ask to merge the partial revert to
> > > Linus tree as well and then there is not much to discuss.
> > 
> > This sounds like the prudent option.  Can we get 4.8 working
> > well-enough, backport that into 4.7.x and worry about the fancier stuff
> > for 4.9?
> 
> OK, fair enough.
> 
> I would really appreciate if the original reporters could retest with
> this patch on top of the current Linus tree.

Any luck with the testing of this patch?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
