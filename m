Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 511516B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 04:00:23 -0400 (EDT)
Received: by iajr24 with SMTP id r24so640240iaj.14
        for <linux-mm@kvack.org>; Tue, 13 Mar 2012 01:00:22 -0700 (PDT)
Date: Tue, 13 Mar 2012 16:05:35 +0800
From: Zheng Liu <gnehzuil.liu@gmail.com>
Subject: Re: Fwd: Control page reclaim granularity
Message-ID: <20120313080535.GA5243@gmail.com>
References: <20120313024818.GA7125@barrios>
 <1331620214-4893-1-git-send-email-wenqing.lz@taobao.com>
 <20120313064832.GA4968@gmail.com>
 <4F5EF563.5000700@openvz.org>
 <CAFPAmTTPxGzrZrW+FR4B_MYDB372HyzdnioO0=CRwx0zQueRSQ@mail.gmail.com>
 <CAFPAmTS-ExDtS7rpJoygc6MCwC10spapyThq7=5cCCGFbjZtqA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFPAmTS-ExDtS7rpJoygc6MCwC10spapyThq7=5cCCGFbjZtqA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: minchan@kernel.org, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, Zheng Liu <wenqing.lz@taobao.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 13, 2012 at 01:17:41PM +0530, Kautuk Consul wrote:
> On Tue, Mar 13, 2012 at 1:13 PM, Kautuk Consul <consul.kautuk@gmail.com> wrote:
> > Hi,
> >
> > I noticed this discussion and decided to pitch in one small idea from my side.
> >
> > It would be nice to range lock an inode's pages by storing those
> > ranges which would be locked.
> > This could also add some good routines for the kernel in terms of
> > range locking for a single inode.
> > However, wouldn't this add some overhead to shrink_page_list() since
> > that code would need to go through
> > all these ranges while trying to reclaim a single page ?
> >
> > One small suggestion from my side is:
> > Why don't we implement something like : "Complete page-cache reclaim
> > control from usermode"?
> > In this, we can set/unset the mapping to AS_UNEVICTABLE (as Konstantin
> > mentioned) for a file's
> > inode from usermode by using ioctl or fcntl or maybe even go as far as
> > implementing an O_NORECL
> > option to the open system call.
> >
> 
> Of course, only an application executing with root privileges should
> be allowed to set the inode's
> mapping flags in this manner.

Hi Kautuk,

IMHO, running application with root privilege is too dangerous.  We
should avoid it.

Regards,
Zheng

> 
> 
> > After setting the AS_UNEVICTABLE, the usermode application can choose
> > to keep and remove pages by
> > using the fadvise(WILLNEED) and fadvise(DONTNEED).
> >
> > ( I think maybe the presence of any VMA is might not really be
> > required for this idea. )
> >
> > Thanks,
> > Kautuk.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
