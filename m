Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 80ABE6B0044
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 14:20:14 -0400 (EDT)
Date: Thu, 26 Apr 2012 13:20:09 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] avoid swapping out with swappiness==0
In-Reply-To: <4F996BA6.9010900@gmail.com>
Message-ID: <alpine.DEB.2.00.1204261318330.16059@router.home>
References: <20120424082019.GA18395@alpha.arachsys.com> <alpine.DEB.2.00.1204260948520.16059@router.home> <4F996BA6.9010900@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Richard Davies <richard@arachsys.com>, Satoru Moriya <satoru.moriya@hds.com>, Jerome Marchand <jmarchan@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "riel@redhat.com" <riel@redhat.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "shaohua.li@intel.com" <shaohua.li@intel.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, 26 Apr 2012, KOSAKI Motohiro wrote:

> (4/26/12 10:50 AM), Christoph Lameter wrote:
> > On Tue, 24 Apr 2012, Richard Davies wrote:
> >
> > > I strongly believe that Linux should have a way to turn off swapping
> > > unless
> > > absolutely necessary. This means that users like us can run with swap
> > > present for emergency use, rather than having to disable it because of the
> > > side effects.
> >
> > Agree. And this ooperation mode should be the default behavior given that
> > swapping is a very slow and tedious process these days.
>
> Even though current patch is not optimal, I don't disagree this opinion. Can
> you please explain your use case? Why don't you use swapoff?

Because I do not want to have systems go OOM. In an emergency lets use
swap (and maybe generate some sort of alert if that happens).

> Off topic: I hope linux is going to aim good swap clustered io in future.
> Especially
> when using THP, 4k size io is not really good.

Swap to regular disks is going to be an ever greater problem since
the access speed of rotational media has not changed much whereas the
processing performance of the cpu has increased significantly. There is an
ever increasing gap in speed.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
