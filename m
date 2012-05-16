Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 9440A6B0082
	for <linux-mm@kvack.org>; Wed, 16 May 2012 17:53:07 -0400 (EDT)
Date: Wed, 16 May 2012 14:53:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [bug] shrink_slab shrinkersize handling
Message-Id: <20120516145303.8a9cb329.akpm@linux-foundation.org>
In-Reply-To: <CAD5x=MPcwXyy0eOdqPxc_8K_i3enoU3ZbtwLS71SHR58FCT6rg@mail.gmail.com>
References: <CAD5x=MPcwXyy0eOdqPxc_8K_i3enoU3ZbtwLS71SHR58FCT6rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: solmac john <johnsolmac@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Kernelnewbies@kernelnewbies.org, linux-kernel@vger.kernel.org, Konstantin Khlebnikov <khlebnikov@openvz.org>

On Wed, 16 May 2012 14:33:18 +0530
solmac john <johnsolmac@gmail.com> wrote:

> Hi All,
> 
> During mm performance testing sometimes I observed below kernel messages
> 
> [   80.776000] shrink_slab: ashmem_shrink+0x0/0x114 negative objects to
> delete nr=-2133936901
> [   80.784000] shrink_slab: ashmem_shrink+0x0/0x114 negative objects to
> delete nr=-2139256767
> [   80.796000] shrink_slab: ashmem_shrink+0x0/0x114 negative objects to
> delete nr=-2079333971
> [   80.804000] shrink_slab: ashmem_shrink+0x0/0x114 negative objects to
> delete nr=-2096156269
> [   80.812000] shrink_slab: ashmem_shrink+0x0/0x114 negative objects to
> delete nr=-20658392
> 
> ...
>
> I found one patch  http://lkml.org/lkml/2011/8/22/80    for this fix
> Please let me know reason why I am getting above error and above is really
> fix for this problem.  ?

Yes, that patch should fix it.

Aside: I spent some time trying to work out the reason why local
variable `max_pass' in shrink_slab() is called `max_pass' and failed.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
