Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 85AF16B038C
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 05:22:33 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w189so76364070pfb.4
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 02:22:33 -0700 (PDT)
Received: from shells.gnugeneration.com (shells.gnugeneration.com. [66.240.222.126])
        by mx.google.com with ESMTP id 1si4708721plu.161.2017.03.16.02.22.32
        for <linux-mm@kvack.org>;
        Thu, 16 Mar 2017 02:22:32 -0700 (PDT)
Date: Thu, 16 Mar 2017 02:23:18 -0700
From: lkml@pengaru.com
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
Message-ID: <20170316092318.GQ802@shells.gnugeneration.com>
References: <82bce413-1bd7-7f66-1c3d-0d890bbaf6f1@wiesinger.com>
 <20170227090236.GA2789@bbox>
 <20170227094448.GF14029@dhcp22.suse.cz>
 <20170228051723.GD2702@bbox>
 <20170228081223.GA26792@dhcp22.suse.cz>
 <20170302071721.GA32632@bbox>
 <feebcc24-2863-1bdf-e586-1ac9648b35ba@wiesinger.com>
 <20170316082714.GC30501@dhcp22.suse.cz>
 <20170316084733.GP802@shells.gnugeneration.com>
 <20170316090844.GG30501@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170316090844.GG30501@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: lkml@pengaru.com, Gerhard Wiesinger <lists@wiesinger.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, Mar 16, 2017 at 10:08:44AM +0100, Michal Hocko wrote:
> On Thu 16-03-17 01:47:33, lkml@pengaru.com wrote:
> [...]
> > While on the topic of understanding allocation stalls, Philip Freeman recently
> > mailed linux-kernel with a similar report, and in his case there are plenty of
> > page cache pages.  It was also a GFP_HIGHUSER_MOVABLE 0-order allocation.
> 
> care to point me to the report?

http://lkml.iu.edu/hypermail/linux/kernel/1703.1/06360.html

>  
> > I'm no MM expert, but it appears a bit broken for such a low-order allocation
> > to stall on the order of 10 seconds when there's plenty of reclaimable pages,
> > in addition to mostly unused and abundant swap space on SSD.
> 
> yes this might indeed signal a problem.

Well maybe I missed something obvious that a better informed eye will catch.

Regards,
Vito Caputo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
