Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 726C26B014A
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 08:01:04 -0400 (EDT)
Received: by fxm2 with SMTP id 2so2081955fxm.4
        for <linux-mm@kvack.org>; Mon, 21 Sep 2009 05:01:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0909211244510.6209@sister.anvils>
References: <1253227412-24342-1-git-send-email-ngupta@vflare.org>
	 <Pine.LNX.4.64.0909180809290.2882@sister.anvils>
	 <1253260528.4959.13.camel@penberg-laptop>
	 <Pine.LNX.4.64.0909180857170.5404@sister.anvils>
	 <1253266391.4959.15.camel@penberg-laptop> <4AB3A16B.90009@vflare.org>
	 <4AB487FD.5060207@cs.helsinki.fi>
	 <Pine.LNX.4.64.0909211149360.32504@sister.anvils>
	 <1253531550.5216.32.camel@penberg-laptop>
	 <Pine.LNX.4.64.0909211244510.6209@sister.anvils>
Date: Mon, 21 Sep 2009 15:01:02 +0300
Message-ID: <84144f020909210501l4a216205q85523a06f4589f2a@mail.gmail.com>
Subject: Re: [PATCH 2/4] send callback when swap slot is freed
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: ngupta@vflare.org, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Mon, Sep 21, 2009 at 2:55 PM, Hugh Dickins
<hugh.dickins@tiscali.co.uk> wrote:
>> The callback setup from ->read() just looks gross. However, it's your
>> call Hugh so I'll just shut up now. ;-)
>
> Ah, no, please don't! =A0So it's _that_ end of it that's upsetting you,
> and rightly so, I hadn't grasped that.

Heh, right. :-)

On Mon, Sep 21, 2009 at 2:55 PM, Hugh Dickins
<hugh.dickins@tiscali.co.uk> wrote:
> (Nitin, your patch division is quite wrong: you should present a patch
> in which your driver works, albeit poorly, without the notifier; then
> a patch in which the notifier is added at the swapfile.c end and your
> driver end, so we can see how they fit together.)

Yes, please. Such standalone driver could go into drivers/staging for
2.6.32 probably.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
