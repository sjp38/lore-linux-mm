Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1443760080F
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 21:41:25 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o7O1fMdn001043
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 18:41:22 -0700
Received: from gwb17 (gwb17.prod.google.com [10.200.2.17])
	by hpaq3.eem.corp.google.com with ESMTP id o7O1fKJL030226
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 18:41:20 -0700
Received: by gwb17 with SMTP id 17so3220535gwb.10
        for <linux-mm@kvack.org>; Mon, 23 Aug 2010 18:41:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100824100943.F3B6.A69D9226@jp.fujitsu.com>
References: <20100821054808.GA29869@localhost> <AANLkTikS+DUfPz0E2SmCZTQBWL8h2zSsGM8--yqEaVgZ@mail.gmail.com>
 <20100824100943.F3B6.A69D9226@jp.fujitsu.com>
From: Michael Rubin <mrubin@google.com>
Date: Mon, 23 Aug 2010 18:41:00 -0700
Message-ID: <AANLkTi=OwGUzM0oZ5qTEFnGTuo8kVfW79oqH-Dcf8jdp@mail.gmail.com>
Subject: Re: [PATCH 4/4] writeback: Reporting dirty thresholds in /proc/vmstat
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 23, 2010 at 6:20 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Fri, Aug 20, 2010 at 10:48 PM, Wu Fengguang <fengguang.wu@intel.com> =
wrote:
>> LOL. I know about these counters. This goes back and forth a lot.
>> The reason we don't want to use this interface is several fold.
>
> Please don't use LOL if you want to get good discuttion. afaict, Wu have
> deep knowledge in this area. However all kernel-developer don't know all
> kernel knob.

Apologies. No offense was intended. I was laughing at the situation
and how I too once thought the per bdi counters were enough. Feng has
been very helpful and patient. The discussion has done nothing but
help the code so far so it is appreciated.

> In nowadays, many distro mount debugfs at boot time. so, can you please
> elaborate you worried risk? =A0even though we have namespace.

Right now we don't mount all of debugfs at boot time. We have not done
the work to verify its safe in our environment. It's mostly a nit.

Also I was under the impression that debugfs was intended more for
kernel devs while /proc and /sys was intended for application
developers.

>> 3) Full system counters are easier to handle the juggling of removable
>> storage where these numbers will appear and disappear due to being
>> dynamic.

This is the biggie to me. The idea is to get a complete view of the
system's writeback behaviour over time. With systems with hot plug
devices, or many many drives collecting that view gets difficult.

>> The goal is to get a full view of the system writeback behaviour not a
>> "kinda got it-oops maybe not" view.
>
> I bet nobody oppose this point :)

Yup.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
