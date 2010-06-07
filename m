Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id AA9476B0071
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 05:20:02 -0400 (EDT)
Subject: Re: mmotm 2010-06-03-16-36 lots of suspected kmemleak
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <AANLkTikXdy6GOQ2EzDt-yrcJ_jMIPvLsH3neWBozpVCK@mail.gmail.com>
References: <AANLkTikXdy6GOQ2EzDt-yrcJ_jMIPvLsH3neWBozpVCK@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 07 Jun 2010 10:19:55 +0100
Message-ID: <1275902395.7258.9.camel@toshiba-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Young <hidave.darkstar@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-06-07 at 06:20 +0100, Dave Young wrote:
> On Fri, Jun 4, 2010 at 9:55 PM, Dave Young <hidave.darkstar@gmail.com> wrote:
> > On Fri, Jun 4, 2010 at 6:50 PM, Catalin Marinas <catalin.marinas@arm.com> wrote:
> >> Dave Young <hidave.darkstar@gmail.com> wrote:
> >>> With mmotm 2010-06-03-16-36, I gots tuns of kmemleaks
> >>
> >> Do you have CONFIG_NO_BOOTMEM enabled? I posted a patch for this but
> >> hasn't been reviewed yet (I'll probably need to repost, so if it fixes
> >> the problem for you a Tested-by would be nice):
> >>
> >> http://lkml.org/lkml/2010/5/4/175
> >
> >
> > I'd like to test, but I can not access the test pc during weekend. So
> > I will test it next monday.
> 
> Bad news, the patch does not fix this issue.

Thanks for trying. Could you please just disable CONFIG_NO_BOOTMEM and
post the kmemleak reported leaks again?

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
