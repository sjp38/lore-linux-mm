Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6233F8D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 17:58:26 -0500 (EST)
Received: by bwz17 with SMTP id 17so3341858bwz.14
        for <linux-mm@kvack.org>; Fri, 04 Mar 2011 14:58:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4D716D9C.6060903@cesarb.net>
References: <4D6D7FEA.80800@cesarb.net>
	<1299022128-6239-1-git-send-email-cesarb@cesarb.net>
	<20110303161550.GA4095@mgebm.net>
	<4D716D9C.6060903@cesarb.net>
Date: Fri, 4 Mar 2011 17:58:23 -0500
Message-ID: <AANLkTi=wcehH_czAT2iP4YOtsj1DKH+7p0uZo0VeB=Wy@mail.gmail.com>
Subject: Re: [PATCHv2 00/24] Refactor sys_swapon
From: Eric B Munson <emunson@mgebm.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org

On Fri, Mar 4, 2011 at 5:54 PM, Cesar Eduardo Barros <cesarb@cesarb.net> wr=
ote:
> Em 03-03-2011 13:15, Eric B Munson escreveu:
>>
>> On Tue, 01 Mar 2011, Cesar Eduardo Barros wrote:
>>
>>> This patch series refactors the sys_swapon function.
>>>
>>> sys_swapon is currently a very large function, with 313 lines (more tha=
n
>>> 12 25-line screens), which can make it a bit hard to read. This patch
>>> series reduces this size by half, by extracting large chunks of related
>>> code to new helper functions.
>>>
>>> One of these chunks of code was nearly identical to the part of
>>> sys_swapoff which is used in case of a failure return from
>>> try_to_unuse(), so this patch series also makes both share the same
>>> code.
>>>
>>> As a side effect of all this refactoring, the compiled code gets a bit
>>> smaller (from v1 of this patch series):
>>>
>>> =A0 =A0text =A0 =A0 =A0 data =A0 =A0 =A0 =A0bss =A0 =A0 =A0 =A0dec =A0 =
=A0 =A0 =A0hex =A0 =A0filename
>>> =A0 14012 =A0 =A0 =A0 =A0944 =A0 =A0 =A0 =A0276 =A0 =A0 =A015232 =A0 =
=A0 =A0 3b80
>>> =A0mm/swapfile.o.before
>>> =A0 13941 =A0 =A0 =A0 =A0944 =A0 =A0 =A0 =A0276 =A0 =A0 =A015161 =A0 =
=A0 =A0 3b39
>>> =A0mm/swapfile.o.after
>>>
>>> The v1 of this patch series was lightly tested on a x86_64 VM.
>>
>> One more small suggestion, you should cc LKML on this series, as well as
>> any
>> of the other emails suggested by get_maintainer.pl.
>
> Should I resend the whole patch series with the correct Cc:?
>

I would and you can add my Tested-by: and Acked-by: to each patch as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
