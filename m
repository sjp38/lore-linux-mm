Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9720A6B00A0
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 22:01:48 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kq14so10682583pab.23
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 19:01:48 -0700 (PDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id oq10si247544pbb.17.2014.04.01.19.01.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 19:01:47 -0700 (PDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4F79D3EE1DB
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 11:01:46 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 39A0445DE70
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 11:01:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.nic.fujitsu.com [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1624B45DE6D
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 11:01:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E93E1E08003
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 11:01:45 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 80A2AE08005
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 11:01:45 +0900 (JST)
Message-ID: <533B6EC0.10303@jp.fujitsu.com>
Date: Wed, 02 Apr 2014 10:58:24 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net> <20140331170546.3b3e72f0.akpm@linux-foundation.org> <1396371699.25314.11.camel@buesod1.americas.hpqcorp.net> <CAHGf_=qsf6vN5k=-PLraG8Q_uU1pofoBDktjVH1N92o76xPadQ@mail.gmail.com> <1396377083.25314.17.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rLLBDr5ptLMvFD-M+TPQSnK3EP=7R+27K8or84rY-KLA@mail.gmail.com> <1396386062.25314.24.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rhXrBQSmDBJJ-vPxBbhjJ91Fh2iWe1cf_UQd-tCfpb2w@mail.gmail.com> <20140401142947.927642a408d84df27d581e36@linux-foundation.org> <CAHGf_=p70rLOYwP2OgtK+2b+41=GwMA9R=rZYBqRr1w_O5UnKA@mail.gmail.com> <20140401144801.603c288674ab8f417b42a043@linux-foundation.org> <CAHGf_=r5AUu6yvJgOzwYDghBo6iT2q+nNumpvqwer+igcfChrA@mail. gmail.co m> <1396394931.25314.34.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rH+vfFzRrh35TETxjFU2HM0xnDQFweQ+Bfw20Pm2nL3g@mail.gmail.com> <1396399239.25314.47.camel@buesod1.americas.hpqcorp.net> <xr937g78k06y.fsf@gthelen.mtv.corp.google.co
 m>
In-Reply-To: <xr937g78k06y.fsf@gthelen.mtv.corp.google.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>, Davidlohr Bueso <davidlohr@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Manfred Spraul <manfred@colorfullife.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

(2014/04/02 10:08), Greg Thelen wrote:
> 
> On Tue, Apr 01 2014, Davidlohr Bueso <davidlohr@hp.com> wrote:
> 
>> On Tue, 2014-04-01 at 19:56 -0400, KOSAKI Motohiro wrote:
>>>>>> Ah-hah, that's interesting info.
>>>>>>
>>>>>> Let's make the default 64GB?
>>>>>
>>>>> 64GB is infinity at that time, but it no longer near infinity today. I like
>>>>> very large or total memory proportional number.
>>>>
>>>> So I still like 0 for unlimited. Nice, clean and much easier to look at
>>>> than ULONG_MAX. And since we cannot disable shm through SHMMIN, I really
>>>> don't see any disadvantages, as opposed to some other arbitrary value.
>>>> Furthermore it wouldn't break userspace: any existing sysctl would
>>>> continue to work, and if not set, the user never has to worry about this
>>>> tunable again.
>>>>
>>>> Please let me know if you all agree with this...
>>>
>>> Surething. Why not. :)
>>
>> *sigh* actually, the plot thickens a bit with SHMALL (total size of shm
>> segments system wide, in pages). Currently by default:
>>
>> #define SHMALL (SHMMAX/getpagesize()*(SHMMNI/16))
>>
>> This deals with physical memory, at least admins are recommended to set
>> it to some large percentage of ram / pagesize. So I think that if we
>> loose control over the default value, users can potentially DoS the
>> system, or at least cause excessive swapping if not manually set, but
>> then again the same goes for anon mem... so do we care?
> 
> At least when there's an egregious anon leak the oom killer has the
> power to free the memory by killing until the memory is unreferenced.
> This isn't true for shm or tmpfs.  So shm is more effective than anon at
> crushing a machine.

Hm..sysctl.kernel.shm_rmid_forced won't work with oom-killer ?

http://www.openwall.com/lists/kernel-hardening/2011/07/26/7

I like to handle this kind of issue under memcg but hmm..tmpfs's limit is half
of memory at default.

Thanks,
-Kame








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
