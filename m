Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 6CC486B0031
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 16:00:23 -0400 (EDT)
Message-ID: <1375991950.10300.216.camel@misato.fc.hp.com>
Subject: Re: [PATCH] mm/hotplug: Verify hotplug memory range
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 08 Aug 2013 13:59:10 -0600
In-Reply-To: <CAHGf_=qPnmpqxeQ1TkXxapRFvdLbLhC53qS3kNATurhoxKd2PQ@mail.gmail.com>
References: <1375980460-28311-1-git-send-email-toshi.kani@hp.com>
	 <CAHGf_=qPnmpqxeQ1TkXxapRFvdLbLhC53qS3kNATurhoxKd2PQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, dave@sr71.net, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, "vasilis.liaskovitis" <vasilis.liaskovitis@profitbricks.com>

On Thu, 2013-08-08 at 15:53 -0400, KOSAKI Motohiro wrote:
> On Thu, Aug 8, 2013 at 12:47 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> > add_memory() and remove_memory() can only handle a memory range aligned
> > with section.  There are problems when an unaligned range is added and
> > then deleted as follows:
> >
> >  - add_memory() with an unaligned range succeeds, but __add_pages()
> >    called from add_memory() adds a whole section of pages even though
> >    a given memory range is less than the section size.
> >  - remove_memory() to the added unaligned range hits BUG_ON() in
> >    __remove_pages().
> >
> > This patch changes add_memory() and remove_memory() to check if a given
> > memory range is aligned with section at the beginning.  As the result,
> > add_memory() fails with -EINVAL when a given range is unaligned, and
> > does not add such memory range.  This prevents remove_memory() to be
> > called with an unaligned range as well.  Note that remove_memory() has
> > to use BUG_ON() since this function cannot fail.
> >
> > Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> > ---
> >  mm/memory_hotplug.c |   22 ++++++++++++++++++++++
> 
> memory_hotplug.c is maintained by me and kamezawa-san. Please cc us
> if you have a subsequent patch.

Oh, I see.  Sorry about that.  Yes, I will copy you two from the next
time. 

> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Thanks!
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
