Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8948B6B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 01:03:04 -0400 (EDT)
Received: by pxi2 with SMTP id 2so1373801pxi.11
        for <linux-mm@kvack.org>; Wed, 23 Sep 2009 22:03:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090924125000.d734a7b1.kamezawa.hiroyu@jp.fujitsu.com>
References: <1253540040-24860-1-git-send-email-ngupta@vflare.org>
	 <20090924104708.4f54ce4e.kamezawa.hiroyu@jp.fujitsu.com>
	 <4ABAE340.7010403@vflare.org>
	 <20090924125000.d734a7b1.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 24 Sep 2009 10:33:04 +0530
Message-ID: <d760cf2d0909232203i48e9dfceo990308a3fc4ab397@mail.gmail.com>
Subject: Re: [PATCH RFC 1/2] Add notifiers for various swap events
From: Nitin Gupta <ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 24, 2009 at 9:20 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:

>> >
>> > In general, notifier chain codes allowed to return NOTIFY_BAD.
>> > But this patch just assumes all chains should return NOTIFY_OK or
>> > just ignore return code.
>> >
>> > That's not good as generic interface, I think.
>>
>>
>> What action we can take here if the notifier_call_chain() returns an error (apart
>> from maybe printing an error)? Perhaps we can add a warning in case of swapon/off
>> events but not in case of swap slot free event which is called under swap_lock.
>>
> If return code is ignored, please add commentary at least.
>

okay.

> I wonder I may able to move memcg's swap_cgroup code for swapon/swapoff onto this
> notifier. (swap_cgroup_swapon/swap_cgroup_swapoff) But it seems not.
> sorry for bothering you.
>

Thanks for your comments!

Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
