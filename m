Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A42FC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 12:18:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBB892085A
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 12:18:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="bCteQWEQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBB892085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 879516B0003; Mon, 18 Mar 2019 08:18:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 827D96B0006; Mon, 18 Mar 2019 08:18:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7175E6B0007; Mon, 18 Mar 2019 08:18:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 51E3E6B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 08:18:17 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id z6so12826604ioh.16
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 05:18:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=vhc34cp7ul6RIl6hg+LkbLQXlFAa0bux2b/Uv9Q+8ds=;
        b=Krf6tMrA+u04GcSiEn37q+KzznkhWgBJg8INTyNvevSoUcncZ9/4x8WpPHKB+Db1x0
         uSOHdpaPjIqPYedlQFPR8xYTQZ+T7SrtP0mP5Icq+FqUnYo5+A9ay0xsjeP7ntA4A5gI
         F2QiGLATbMylVdOX8C647gc+grTD+8QaZXEJMCoLonOU5AMgzgu1+cHNENJpVIUzhhV6
         y3iWnAJQCR3F7EJgzx2Urrx5HlROh73GtVGMhsde7wCZ2zr2+CZdATtKYZdERSx8KyQ1
         dUM6qf/8svqrXwY93DAwRX7wHUZNCDG1fafJGUVenAeTnvhNV3O1DiyJXDZKQJrRShVA
         o2vw==
X-Gm-Message-State: APjAAAXBlnFaibOVPKIkQdJSlDbuh8r+fDVZ9KD+rv2wFyj69S8MSIff
	gm+TbgT3EnH7rYWx5PNfz9WH8NZFuMvtLr9HcVx+hojDqT0+PwKAu0kZbNmN6OIW5B92pwHkYiT
	FwTV1HlB3fvtcONEweZPQ6o3/mONCwojIeYO/75RcPOqIJ6MVU0eoVuDmx2yJsoiF+g==
X-Received: by 2002:a24:164d:: with SMTP id a74mr9826339ita.84.1552911497031;
        Mon, 18 Mar 2019 05:18:17 -0700 (PDT)
X-Received: by 2002:a24:164d:: with SMTP id a74mr9826288ita.84.1552911495899;
        Mon, 18 Mar 2019 05:18:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552911495; cv=none;
        d=google.com; s=arc-20160816;
        b=iBSXXAuArKmIwWzdRjW6lMkzyMRB9jEYrOEzcf0edWae+Fc4SF3JfjSDXr5bcQfvWx
         pDMIDHdA1SR302xjj/HLZR28eeHBMZvLYrc4NumvASxX6BtCaKXZ9VFw9hKOQuk/FW0d
         5sMAjVcvm+2879RIDIXJSMp74n0sFcWTEI3o5LHDsKTr/EBaa3xcYewfQCyVNGn6u2WS
         L/z5VC5BqcyQtfbBpMv6mlFMoV3djBCuJKRS55vLZp1NhDg0XsHa9EIOyZypkW2tvsqT
         NpHr0KZ7Pei+g15aPqwhPT8sDfHASbJr6zOhpsvbp7IQGf3962VIFJ5SZbYLRS1jcL/W
         QMOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=vhc34cp7ul6RIl6hg+LkbLQXlFAa0bux2b/Uv9Q+8ds=;
        b=A3RfqMnLsTl3IpHXHg+7GnZo/gsJiONKzRixtJPMiHy7P5w6ETU1Rtr8iDMqmGc6bL
         1KiNy2ziwSg4p8PCC5tBdvDXESMMrW3mg3gWQXICox0ohHOZ11p980Ur+gZgLPDFVFk4
         KJ7DcgsjIgP4EwSuE8oNc/tzScu/9YC2vAZ9Qy0njLyqg8WOrooEjL09tIv1DwUpIWnq
         J29ars+cmuCBV1dGwrsuDzJX5ILxcJz4AEhLDCFEiwKmS1C94nXj708fTDR2u7N/LRfR
         HTi9KVcRjgUTPkkGbBGsVaU88FVuRdMOcIK9CqdWa0uurCGTH2o0qmX9baKad+vGpRs+
         DnCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bCteQWEQ;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b199sor15095502itb.8.2019.03.18.05.18.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 05:18:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bCteQWEQ;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vhc34cp7ul6RIl6hg+LkbLQXlFAa0bux2b/Uv9Q+8ds=;
        b=bCteQWEQ7a/Ce7oIkJ1ujPxTtZS+qerrJQHyfzureR3wkS/5C/gAbvuFtJG6ThrhyO
         C4pX5UA8d9+RGyn6WTHzp6nd2w2c2L7buxUxRipO7Mgn3QFOGn2Y1AI//Lbjti2FQVZy
         0BOyJGm0q5zj2uE9R8LNQQLrMMIuUmJyQkL5wO3Aard9e0FjHdoefmYrNVyyKyEmAv6w
         Hu42TJXs3DEaZ2eJLoZ9KscGeLNW0I+B3ORdCTxRt9G0o4h/B6U5iCJCz10rHua2W9Fj
         KeyKyl7foWVC2Af5T6jTrbhatV2VqrnwnLN/KOGhTlPW6oVV7tJ7g3cpdkwyCkaGC05r
         4bYw==
X-Google-Smtp-Source: APXvYqwQ0AI6IjXA3aCfxfTc3KyOKQxDZ+P2Awfq0baql/7lUUDE4keKZuNVwYzFTm/Uh0NB+GgZM24tiSMcTrYjWx0=
X-Received: by 2002:a05:660c:3d1:: with SMTP id c17mr9678695itl.166.1552911495269;
 Mon, 18 Mar 2019 05:18:15 -0700 (PDT)
MIME-Version: 1.0
References: <0000000000007da94e05827ea99a@google.com> <0000000000009b8d8a058447efc5@google.com>
 <20190317110447.GA3885@kroah.com>
In-Reply-To: <20190317110447.GA3885@kroah.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 18 Mar 2019 13:18:04 +0100
Message-ID: <CACT4Y+YrrTtEAVidT+DiW1Wet0uxEtNP2kjjWN6GYDo8423SCg@mail.gmail.com>
Subject: Re: WARNING in rcu_check_gp_start_stall
To: Greg KH <gregkh@linuxfoundation.org>
Cc: syzbot <syzbot+111bc509cd9740d7e4aa@syzkaller.appspotmail.com>, 
	Borislav Petkov <bp@alien8.de>, "open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>, 
	Dou Liyang <douly.fnst@cn.fujitsu.com>, forest@alittletooquiet.net, 
	"H. Peter Anvin" <hpa@zytor.com>, konrad.wilk@oracle.com, Len Brown <len.brown@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, puwen@hygon.cn, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Thomas Gleixner <tglx@linutronix.de>, tvboxspy@gmail.com, 
	wang.yi59@zte.com.cn, "the arch/x86 maintainers" <x86@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 17, 2019 at 12:04 PM Greg KH <gregkh@linuxfoundation.org> wrote:
>
> On Sun, Mar 17, 2019 at 03:43:01AM -0700, syzbot wrote:
> > syzbot has bisected this bug to:
> >
> > commit f1e3e92135202ff3d95195393ee62808c109208c
> > Author: Malcolm Priestley <tvboxspy@gmail.com>
> > Date:   Wed Jul 22 18:16:42 2015 +0000
> >
> >     staging: vt6655: fix tagSRxDesc -> next_desc type
> >
> > bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=111856cf200000
> > start commit:   f1e3e921 staging: vt6655: fix tagSRxDesc -> next_desc type
> > git tree:       upstream
> > final crash:    https://syzkaller.appspot.com/x/report.txt?x=131856cf200000
> > console output: https://syzkaller.appspot.com/x/log.txt?x=151856cf200000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=7132344728e7ec3f
> > dashboard link: https://syzkaller.appspot.com/bug?extid=111bc509cd9740d7e4aa
> > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=16d4966cc00000
> > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=10c492d0c00000
> >
> > Reported-by: syzbot+111bc509cd9740d7e4aa@syzkaller.appspotmail.com
> > Fixes: f1e3e921 ("staging: vt6655: fix tagSRxDesc -> next_desc type")
>
> I think syzbot is a bit confused here, how can this simple patch, where
> you do not have the hardware for this driver, cause this problem?

Yes, I guess so.
This perf_event_open+sched_setattr combo bug causes problems with
hangs at random places, developers looking at these hangs again and
again, incorrect bisection. I would be useful if somebody
knowledgeable in perf/sched look at it.

