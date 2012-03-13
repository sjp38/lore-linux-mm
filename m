Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id C78546B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 05:03:48 -0400 (EDT)
Received: by yenm8 with SMTP id m8so365371yen.14
        for <linux-mm@kvack.org>; Tue, 13 Mar 2012 02:03:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFPAmTQ-7GiDfQkU5wKFfR5UVacrN-HrP5h_yNmAdK8tRO-xTA@mail.gmail.com>
References: <20120313024818.GA7125@barrios>
	<1331620214-4893-1-git-send-email-wenqing.lz@taobao.com>
	<20120313064832.GA4968@gmail.com>
	<4F5EF563.5000700@openvz.org>
	<CAFPAmTTPxGzrZrW+FR4B_MYDB372HyzdnioO0=CRwx0zQueRSQ@mail.gmail.com>
	<CAFPAmTS-ExDtS7rpJoygc6MCwC10spapyThq7=5cCCGFbjZtqA@mail.gmail.com>
	<20120313080535.GA5243@gmail.com>
	<CAFPAmTSR_Lvsi2+Uid3a9RQK5bBnN3vD_cje6o02f-gBusCJHQ@mail.gmail.com>
	<CAFPAmTQWsq5sjnTVYL5ark6=LSOmOwiRsCr7wqTp=4ymBAUdUQ@mail.gmail.com>
	<20120313082818.GA5421@gmail.com>
	<CAFPAmTQ-7GiDfQkU5wKFfR5UVacrN-HrP5h_yNmAdK8tRO-xTA@mail.gmail.com>
Date: Tue, 13 Mar 2012 14:33:47 +0530
Message-ID: <CAFPAmTTO6FhwfW1ObbHUpv0qi1a-1321Mwkm+jZVaOvbLaGmxw@mail.gmail.com>
Subject: Re: Fwd: Control page reclaim granularity
From: Kautuk Consul <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, Zheng Liu <wenqing.lz@taobao.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> The only problem that might happen might be in OOM because we will
> have to include selection points for
> these page-cache pages (proportionately) while finding the most
> expensive process to kill.
> ( I'm talking about the page-cache pages which are not mapped to
> usermode page-tables at all. )
>
> If any usermode application reads in an extremely huge file, whose
> inode has been set to AS_UNEVICTABLE,
> we might want to kill those applications that read in those
> pages(proportionately) so that the guilty application
> can be killed.

On some more thought, I guess for OOM and proprtionate working set accounting,
the approach mentioned by Konstantin (with fake VMA) should work fine
with respect to the
way oom_kill.c accounts for virtual address size of kill candidates.

So, I now think that the best way might indeed be to have a fake VMA
to account for the
page-cache pages not mapped to usermode.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
