Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id DFB8F6B13F0
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 07:46:47 -0500 (EST)
Received: by obbta7 with SMTP id ta7so7249429obb.14
        for <linux-mm@kvack.org>; Tue, 31 Jan 2012 04:46:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F26CAD1.2000209@stericsson.com>
References: <1327930436-10263-1-git-send-email-maxime.coquelin@stericsson.com>
	<1327930436-10263-4-git-send-email-maxime.coquelin@stericsson.com>
	<20120130152237.GS25268@csn.ul.ie>
	<4F26CAD1.2000209@stericsson.com>
Date: Tue, 31 Jan 2012 14:46:46 +0200
Message-ID: <CAOJsxLE_iby+-EGzqXDc9D=Db7mm1NDDqdHqN_a+mZAQfLBrFA@mail.gmail.com>
Subject: Re: [RFCv1 3/6] PASR: mm: Integrate PASR in Buddy allocator
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxime Coquelin <maxime.coquelin@stericsson.com>
Cc: Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus WALLEIJ <linus.walleij@stericsson.com>, Andrea GALLO <andrea.gallo@stericsson.com>, Vincent GUITTOT <vincent.guittot@stericsson.com>, Philippe LANGLAIS <philippe.langlais@stericsson.com>, Loic PALLARDY <loic.pallardy@stericsson.com>

On Mon, Jan 30, 2012 at 6:52 PM, Maxime Coquelin
<maxime.coquelin@stericsson.com> wrote:
>> What is more likely is that you will get pushed to doing something like
>> periodically scanning memory as part of a separate power management
>> module and calling into PASR if regions of memory that are found that
>> can be powered down in some ways.
>
> With this solution, we need in any case to add some hooks in the allocator
> to ensure the pages being allocated are refreshed.

Why do you insist on making this happen at page level when you're only
able to power off *much* larger chunks?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
