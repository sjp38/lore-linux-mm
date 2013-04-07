Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id CAEEB6B0027
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 13:59:53 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <dc2642fc-f662-41cd-a236-fccf4c252dfa@default>
Date: Sun, 7 Apr 2013 10:59:18 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH part2 v6 0/3] staging: zcache: Support zero-filled pages
 more efficiently
References: <1364984183-9711-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130407090341.GA22589@hacker.(null)>
 <62e1fe34-e5be-42f5-83af-f8f428fce57b@default>
In-Reply-To: <62e1fe34-e5be-42f5-83af-f8f428fce57b@default>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Fengguang Wu <fengguang.wu@intel.com>, Bob Liu <bob.liu@oracle.com>, Ric Mason <ric.masonn@gmail.com>

> From: Dan Magenheimer
> Subject: RE: [PATCH part2 v6 0/3] staging: zcache: Support zero-filled pa=
ges more efficiently
>=20
> > From: Wanpeng Li [mailto:liwanp@linux.vnet.ibm.com]
> > Subject: Re: [PATCH part2 v6 0/3] staging: zcache: Support zero-filled =
pages more efficiently
> >
> > Hi Dan,
> >
> > Some issues against Ramster:
> >
>=20
> Sure!  I am concerned about Konrad's patches adding debug.c as they
> add many global variables.  They are only required when ZCACHE_DEBUG
> is enabled so they may be ok.  If not, adding ramster variables
> to debug.c may make the problem worse.

Oops, I just noticed/remembered that ramster uses BOTH debugfs and sysfs.
The sysfs variables are all currently required, i.e. for configuration
so should not be tied to debugfs or a DEBUG config option.  However,
if there is a more acceptable way to implement the function of
those sysfs variables, that would be fine.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
