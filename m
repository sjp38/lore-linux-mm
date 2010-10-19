Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E1E2D6B00D8
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 01:34:58 -0400 (EDT)
Received: by iwn1 with SMTP id 1so2211931iwn.14
        for <linux-mm@kvack.org>; Mon, 18 Oct 2010 22:34:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101019142640.44c87807.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101018021126.GB8654@localhost>
	<1287389631.1997.9.camel@myhost>
	<20101018180919.3AF8.A69D9226@jp.fujitsu.com>
	<1287454058.2078.12.camel@myhost>
	<20101019115952.d922763b.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikw6NizBStoXVz8Br_LYvoLoofsOB+d6-FX2=Be@mail.gmail.com>
	<20101019142640.44c87807.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 19 Oct 2010 14:34:57 +0900
Message-ID: <AANLkTim7CCfrqMa0661WEGeeg-AwQzaWi6Yfdi70se3W@mail.gmail.com>
Subject: Re: oom_killer crash linux system
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Figo.zhang" <zhangtianfei@leadcoretech.com>, lKOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, figo1802 <figo1802@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 19, 2010 at 2:26 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 19 Oct 2010 14:23:29 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> On Tue, Oct 19, 2010 at 11:59 AM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> >
>> > =A0Does anyone have idea about file-mapped-but-not-on-LRU pages ?
>>
>> Isn't it possible some file pages are much sharable?
>> Please see the page_add_file_rmap.
>>

Absolutely you're right.
Today, I need sleep. :(
Sorry for the noise.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
