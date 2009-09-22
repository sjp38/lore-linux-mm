Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1A8FC6B004D
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 23:05:29 -0400 (EDT)
Received: by ey-out-1920.google.com with SMTP id 13so719744eye.18
        for <linux-mm@kvack.org>; Mon, 21 Sep 2009 20:05:29 -0700 (PDT)
Message-ID: <4AB83EB5.60307@vflare.org>
Date: Tue, 22 Sep 2009 08:34:21 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] send callback when swap slot is freed
References: <1253227412-24342-1-git-send-email-ngupta@vflare.org>	 <Pine.LNX.4.64.0909180809290.2882@sister.anvils>	 <1253260528.4959.13.camel@penberg-laptop>	 <Pine.LNX.4.64.0909180857170.5404@sister.anvils>	 <1253266391.4959.15.camel@penberg-laptop> <4AB3A16B.90009@vflare.org>	 <4AB487FD.5060207@cs.helsinki.fi>	 <Pine.LNX.4.64.0909211149360.32504@sister.anvils>	 <1253531550.5216.32.camel@penberg-laptop>	 <Pine.LNX.4.64.0909211244510.6209@sister.anvils> <84144f020909210501l4a216205q85523a06f4589f2a@mail.gmail.com>
In-Reply-To: <84144f020909210501l4a216205q85523a06f4589f2a@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On 09/21/2009 05:31 PM, Pekka Enberg wrote:
> On Mon, Sep 21, 2009 at 2:55 PM, Hugh Dickins
> 
> On Mon, Sep 21, 2009 at 2:55 PM, Hugh Dickins
> <hugh.dickins@tiscali.co.uk> wrote:
>> (Nitin, your patch division is quite wrong: you should present a patch
>> in which your driver works, albeit poorly, without the notifier; then
>> a patch in which the notifier is added at the swapfile.c end and your
>> driver end, so we can see how they fit together.)
> 
> Yes, please. Such standalone driver could go into drivers/staging for
> 2.6.32 probably.
> 


Ok, for now all I will remove all swap notifier bits from the patches so
they reside completely in drivers/staging/. That should make it easier for
GregKH to merge it. The problematic swap notifier part will be added later.

Thanks to you and Hugh for looking into these patches.

Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
