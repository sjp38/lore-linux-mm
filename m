Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6E3C26B0281
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 02:53:07 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id 194so3817386wmv.9
        for <linux-mm@kvack.org>; Sun, 07 Jan 2018 23:53:07 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t131si7347467wmg.163.2018.01.07.23.53.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Jan 2018 23:53:05 -0800 (PST)
Date: Mon, 8 Jan 2018 08:53:08 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
Message-ID: <20180108075308.GC24062@kroah.com>
References: <20171222084623.668990192@linuxfoundation.org>
 <20171222084625.007160464@linuxfoundation.org>
 <1515302062.6507.18.camel@gmx.de>
 <20180107091115.GB29329@kroah.com>
 <20180107101847.GC24862@dhcp22.suse.cz>
 <1515329042.13953.14.camel@gmx.de>
 <20180107132309.GD24862@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180107132309.GD24862@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Galbraith <efault@gmx.de>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Sun, Jan 07, 2018 at 02:23:09PM +0100, Michal Hocko wrote:
> On Sun 07-01-18 13:44:02, Mike Galbraith wrote:
> > On Sun, 2018-01-07 at 11:18 +0100, Michal Hocko wrote:
> > > On Sun 07-01-18 10:11:15, Greg KH wrote:
> > > > On Sun, Jan 07, 2018 at 06:14:22AM +0100, Mike Galbraith wrote:
> > > > > On Fri, 2017-12-22 at 09:45 +0100, Greg Kroah-Hartman wrote:
> > > > > > 4.14-stable review patch.  If anyone has any objections, please let me know.
> > > > > 
> > > > > FYI, this broke kdump, or rather the makedumpfile part thereof.
> > > > >  Forward looking wreckage is par for the kdump course, but...
> > > > 
> > > > Is it also broken in Linus's tree with this patch?  Or is there an
> > > > add-on patch that I should apply to 4.14 to resolve this issue there?
> > > 
> > > This one http://lkml.kernel.org/r/1513932498-20350-1-git-send-email-bhe@redhat.com
> > > I guess.
> > 
> > That won't unbreak kdump, else master wouldn't be broken.  I don't care
> > deeply, or know if anyone else does, I'm just reporting it because I
> > met it and chased it down.
> 
> OK, I didn't notice that d8cfbbfa0f7 ("mm/sparse.c: wrong allocation
> for mem_section") made it in after rc6. I am still wondering why
> 83e3c48729 ("mm/sparsemem: Allocate mem_section at runtime for
> CONFIG_SPARSEMEM_EXTREME=y") made it into the stable tree in the first
> place.

It was part of the prep for the KTPI code from what I can tell.  If you
think it should be reverted, just let me know and I'll be glad to do so.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
