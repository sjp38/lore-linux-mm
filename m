Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id B13F16B007E
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 04:22:53 -0400 (EDT)
Received: by dadv6 with SMTP id v6so691208dad.14
        for <linux-mm@kvack.org>; Tue, 13 Mar 2012 01:22:53 -0700 (PDT)
Date: Tue, 13 Mar 2012 16:28:18 +0800
From: Zheng Liu <gnehzuil.liu@gmail.com>
Subject: Re: Fwd: Control page reclaim granularity
Message-ID: <20120313082818.GA5421@gmail.com>
References: <20120313024818.GA7125@barrios>
 <1331620214-4893-1-git-send-email-wenqing.lz@taobao.com>
 <20120313064832.GA4968@gmail.com>
 <4F5EF563.5000700@openvz.org>
 <CAFPAmTTPxGzrZrW+FR4B_MYDB372HyzdnioO0=CRwx0zQueRSQ@mail.gmail.com>
 <CAFPAmTS-ExDtS7rpJoygc6MCwC10spapyThq7=5cCCGFbjZtqA@mail.gmail.com>
 <20120313080535.GA5243@gmail.com>
 <CAFPAmTSR_Lvsi2+Uid3a9RQK5bBnN3vD_cje6o02f-gBusCJHQ@mail.gmail.com>
 <CAFPAmTQWsq5sjnTVYL5ark6=LSOmOwiRsCr7wqTp=4ymBAUdUQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFPAmTQWsq5sjnTVYL5ark6=LSOmOwiRsCr7wqTp=4ymBAUdUQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: minchan@kernel.org, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, Zheng Liu <wenqing.lz@taobao.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 13, 2012 at 01:38:56PM +0530, Kautuk Consul wrote:
> >
> > I agree, but that's not my point.
> >
> > All I'm saying is that we probably don't want to give normal
> > unprivileged usermode apps
> > the capability to set the mapping to AS_UNEVICTABLE as anyone can then
> > write an application
> > that hogs memory without allowing the kernel to free it through memory reclaim.

Yes, I think so.  But it seems that there has some codes that are
possible to be abused.  For example, as I said previously, applications
can mmap a normal data file with PROT_EXEC flag.  Then this file gets a
high priority to keep in memory (commit: 8cab4754).  So my point is that
we cannot control applications how to use these mechanisms.  We just
provide them and let applications to choose how to use them.
:-)

Regards,
Zheng

> 
> Sorry, I mean :
> "... that hogs kernel unmapped page-cache memory without allowing the
> kernel to free it through memory reclaim."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
