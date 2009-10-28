Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 610086B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 08:55:44 -0400 (EDT)
Date: Wed, 28 Oct 2009 13:55:26 +0100 (CET)
From: Tobi Oetiker <tobi@oetiker.ch>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC
 failures V2
In-Reply-To: <20091028114208.GA14476@bizet.domek.prywatny>
Message-ID: <alpine.DEB.2.00.0910281353180.19210@sebohet.brgvxre.pu>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <20091023165810.GA4588@bizet.domek.prywatny> <20091023211239.GA6185@bizet.domek.prywatny> <9ec2d7290910240646p75b93c68v6ea1648d628a9660@mail.gmail.com>
 <20091028114208.GA14476@bizet.domek.prywatny>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Cc: Mel LKML <mel.lkml@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

 Today Karol Lewandowski wrote:

> On Sat, Oct 24, 2009 at 02:46:56PM +0100, Mel LKML wrote:
> > Hi,
>
> Hi,
>
> > On 10/23/09, Karol Lewandowski <karol.k.lewandowski@gmail.com> wrote:
> > > On Fri, Oct 23, 2009 at 06:58:10PM +0200, Karol Lewandowski wrote:
>
> > > Ok, I've tested patches 1+2+4 and bug, while very hard to trigger, is
> > > still present. I'll test complete 1-4 patchset as time permits.
>
> Sorry for silence, I've been quite busy lately.
>
>
> > And also patch 5 please which is the revert. Patch 5 as pointed out is
> > probably a red herring. Hwoever, it has changed the timing and made a
> > difference for some testing so I'd like to know if it helps yours as
> > well.
>
> I've tested patches 1+2+3+4 in my normal usage scenario (do some work,
> suspend, do work, suspend, ...) and it failed today after 4 days (== 4
> suspend-resume cycles).

I have been testing 1+2,1+2+3 as well as 3+4 and have been of the
assumption that 3+4 does help ... I have now been runing a modified
version of 4 which prints a warning instead of doing anything ... I
have now seen the allocation issue again without the warning being
printed. So in other words

1+2+3 make the problem less severe, but do not solve it
4 seems to be a red hering.

cheers
tobi


-- 
Tobi Oetiker, OETIKER+PARTNER AG, Aarweg 15 CH-4600 Olten, Switzerland
http://it.oetiker.ch tobi@oetiker.ch ++41 62 775 9902 / sb: -9900

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
