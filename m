Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 75C676B0069
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 03:43:43 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 33so90880657lfw.1
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 00:43:43 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id w128si2395470wmf.25.2016.08.23.00.43.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 00:43:42 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id i138so16788671wmf.3
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 00:43:41 -0700 (PDT)
Date: Tue, 23 Aug 2016 09:43:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM detection regressions since 4.7
Message-ID: <20160823074339.GB23577@dhcp22.suse.cz>
References: <20160822093249.GA14916@dhcp22.suse.cz>
 <20160822093707.GG13596@dhcp22.suse.cz>
 <20160822100528.GB11890@kroah.com>
 <20160822105441.GH13596@dhcp22.suse.cz>
 <20160822133114.GA15302@kroah.com>
 <20160822134227.GM13596@dhcp22.suse.cz>
 <20160822150517.62dc7cce74f1af6c1f204549@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160822150517.62dc7cce74f1af6c1f204549@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>
Cc: Greg KH <gregkh@linuxfoundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 22-08-16 15:05:17, Andrew Morton wrote:
> On Mon, 22 Aug 2016 15:42:28 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > Of course, if Linus/Andrew doesn't like to take those compaction
> > improvements this late then I will ask to merge the partial revert to
> > Linus tree as well and then there is not much to discuss.
> 
> This sounds like the prudent option.  Can we get 4.8 working
> well-enough, backport that into 4.7.x and worry about the fancier stuff
> for 4.9?

OK, fair enough.

I would really appreciate if the original reporters could retest with
this patch on top of the current Linus tree. The stable backport posted
earlier doesn't apply on the current master cleanly but the change is
essentially same. mmotm tree then can revert this patch before Vlastimil
series is applied because that code is touching the currently removed
code.
---
