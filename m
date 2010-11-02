Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B1ABB6B016E
	for <linux-mm@kvack.org>; Tue,  2 Nov 2010 08:47:30 -0400 (EDT)
Received: by wyf23 with SMTP id 23so6807899wyf.14
        for <linux-mm@kvack.org>; Tue, 02 Nov 2010 05:47:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTim0oHFehpJggt9c8PhSZpOZZA1Qz=h6rC5NjeCY@mail.gmail.com>
References: <1288668052-32036-1-git-send-email-bgamari.foss@gmail.com>
	<AANLkTim0oHFehpJggt9c8PhSZpOZZA1Qz=h6rC5NjeCY@mail.gmail.com>
Date: Tue, 2 Nov 2010 21:47:28 +0900
Message-ID: <AANLkTimmDUc7pigVysJn1T-Dt4sFKGFpw_EuBAEuxu6T@mail.gmail.com>
Subject: Re: [PATCH] Add Kconfig option for default swappiness
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Ben Gamari <bgamari.foss@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Juhl <jj@chaosbits.net>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

2010/11/2 Minchan Kim <minchan.kim@gmail.com>:

> Apparently, it wouldn't hurt maintain the kernel. But I have a concern.
> As someone think this parameter is very important and would be better
> to control by kernel config rather than init script to make the
> package, it would make new potential kernel configs by someone in
> future.
> But I can't convince my opinion myself. Because if there will be lots
> of kernel config for tuning parameters, could it hurt
> maintain/usability? I can't say "Yes" strongly. so I am not against
> this idea strongly.
> Hmm,, =A0Just pass the decision to others.
>

please modify sysctl setting....

No ack from me.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
