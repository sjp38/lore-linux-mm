Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6925E6B0031
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 15:02:29 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id d1so9840274wiv.1
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 12:02:28 -0700 (PDT)
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
        by mx.google.com with ESMTPS id i7si2627185wjz.160.2014.04.03.12.02.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Apr 2014 12:02:27 -0700 (PDT)
Received: by mail-wg0-f50.google.com with SMTP id x13so2413338wgg.9
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 12:02:26 -0700 (PDT)
Message-ID: <533DB03D.7010308@colorfullife.com>
Date: Thu, 03 Apr 2014 21:02:21 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ipc,shm: disable shmmax and shmall by default
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net> <20140331170546.3b3e72f0.akpm@linux-foundation.org> <1396371699.25314.11.camel@buesod1.americas.hpqcorp.net> <CAHGf_=qsf6vN5k=-PLraG8Q_uU1pofoBDktjVH1N92o76xPadQ@mail.gmail.com> <1396377083.25314.17.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rLLBDr5ptLMvFD-M+TPQSnK3EP=7R+27K8or84rY-KLA@mail.gmail.com> <1396386062.25314.24.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rhXrBQSmDBJJ-vPxBbhjJ91Fh2iWe1cf_UQd-tCfpb2w@mail.gmail.com> <20140401142947.927642a408d84df27d581e36@linux-foundation.org> <CAHGf_=p70rLOYwP2OgtK+2b+41=GwMA9R=rZYBqRr1w_O5UnKA@mail.gmail.com> <20140401144801.603c288674ab8f417b42a043@linux-foundation.org> <CAHGf_=r5AUu6yvJgOzwYDghBo6iT2q+nNumpvqwer+igcfChrA@mail.gmail.com> <1396394931.25314.34.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rH+vfFzRrh35TETxjFU2HM0xnDQFweQ+Bfw20Pm2nL3g@mail.gmail.com> <1396484447.2953.1.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1396484447.2953.1.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg Thelen <gthelen@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi Davidlohr,

On 04/03/2014 02:20 AM, Davidlohr Bueso wrote:
> The default size for shmmax is, and always has been, 32Mb.
> Today, in the XXI century, it seems that this value is rather small,
> making users have to increase it via sysctl, which can cause
> unnecessary work and userspace application workarounds[1].
>
> Instead of choosing yet another arbitrary value, larger than 32Mb,
> this patch disables the use of both shmmax and shmall by default,
> allowing users to create segments of unlimited sizes. Users and
> applications that already explicitly set these values through sysctl
> are left untouched, and thus does not change any of the behavior.
>
> So a value of 0 bytes or pages, for shmmax and shmall, respectively,
> implies unlimited memory, as opposed to disabling sysv shared memory.
> This is safe as 0 cannot possibly be used previously as SHMMIN is
> hardcoded to 1 and cannot be modified.
Are we sure that no user space apps uses shmctl(IPC_INFO) and prints a 
pretty error message if shmall is too small?
We would break these apps.

--
     Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
