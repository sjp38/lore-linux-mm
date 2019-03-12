Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A201DC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 17:10:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 334902083D
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 17:10:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="hSBUd/eG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 334902083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7918F8E0003; Tue, 12 Mar 2019 13:10:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71A4D8E0002; Tue, 12 Mar 2019 13:10:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E3168E0003; Tue, 12 Mar 2019 13:10:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 393988E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 13:10:51 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id n15so2317957ioc.0
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 10:10:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=q63ookcgnvhAqs3Sfl5pVKDmKu933OB0+OqZ26Ou1RY=;
        b=bNHauiMGMQZ0pCEdu2n41fES4XcQLLBJYTc/oPzPa8jGnTBnWtPNZwyuUz4FGbDN0M
         oVSNjAdrGopINS+c6M9XpWnntOjf306LxEkLzJyS9uhPrUTAv6lw38MPtMwxRKWhNQrn
         oE+5Pfwm8yhu7Mx9q20YbO9KWkKwIWexiJSKBhTauWd2prtdvSufiieBITP7m0f19aE6
         O+b7tpSQr2KbGj+VRc+oD2V5YUXcHwuuAKGoEq4uJXTSViwH2yoJMTB+x6esM4nLXDQV
         hRRly0A5eihebC5GIsfLcJPtsj08B0vy01BJZuPquIy/TQugcw188tOjyg7nQZ18CuL/
         wGEw==
X-Gm-Message-State: APjAAAUCXGtKKeWtSIN95N8ieYozoD8S+I1KBbni2Chzx3dU8IBPJ7rW
	tpTfPb822oExjx1eBc1xNQVQ9ODdTlV325fzndZ3WjeLjFOJ4NeW5KlF6ZnmOqYgxuFxIF8X621
	wGOL2yu6nZLPp2UIoObCA50NTtCkOnNcElu5p/q9utPak1e2BxBdLjHmSDjKymYOx067WbbLYBd
	gBz1pvFl+9zWfzz2OGh+3PAQEWu7a6yqaousvtoad1lZfexz/Le3Z7ByL6Pv1KWyvysLg+myhJg
	SAUaDcthwu/oOPTyFyIK82GbGjYZLdMNFgYSN8TIiohUrPBYrqVMdRCm5LZJpm8lFv0uA71OJLw
	WoCQ7PyOHRGSpkfc0e1RMbjjkcKxhGe57MVfxp12UnVV9qiWSEj40Iu4kQ+9XHSBBPOz+FIp/cK
	1
X-Received: by 2002:a24:2812:: with SMTP id h18mr2733502ith.173.1552410650978;
        Tue, 12 Mar 2019 10:10:50 -0700 (PDT)
X-Received: by 2002:a24:2812:: with SMTP id h18mr2733449ith.173.1552410649906;
        Tue, 12 Mar 2019 10:10:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552410649; cv=none;
        d=google.com; s=arc-20160816;
        b=BUJHNtyyksl8VZMBsDPDWyiz4f+6K42ovLc6Xp/4AN+5FMqlbw3Al3FEHbDJTONHRy
         7CHPCP7VlZf45N20Z+1RdswQfpcJ+ACIfSkm/5GC1wrl6Siv6C+2jNIwYDpUJ0W4nRDq
         EW+BQt+5rhEDHVEZdM6+R7FMKZb0VdNq7KdwkdoN8mO21IvNQWXSfj+iBZksw8YTrxdD
         Wx0edDVJl/V5EqCpnKK7j5fSCCG5CUpH4eTxp56/TwgW7TcMRZjsjAsKI6nHu+QFgQ+E
         6uStddu7RFqmNLiUTKhNp/VtdIL02T3ZAJ3R4ihbxQO1F7dNcCBFQiSjbqxRLe1whIEY
         dhMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=q63ookcgnvhAqs3Sfl5pVKDmKu933OB0+OqZ26Ou1RY=;
        b=fCJ6/a1MFi1ABut4Yv9nepXHb7H9sw0l3NjMHu51H27R1zKXc1OlnjqwPmECXgTPBD
         p7FQ2ZGvq7+2BY6zG4i8TVe01Qy2sKrtJd5RuLhGIcR1LV5ZDputviK3BUY1uZ9oSFGK
         8brqNcjUSqWooIPV7HUkIC6GhlJN77YfY5oxUXD29hEBoysOTxZmO/8Hos/+dQYd3b55
         z+mU+NZ2fSNHHUY+hPX3BrQi154ZUzCV+a6sJR3LU5CZ7OE6kzCc7AiHfEIQu/EOd2W6
         nv9WU/Q/ZzPTs1PP6zKYCZw0PTAqJT0cI80B5ViRZPcj9bgwKJjt9NmugViSQN8oOVG1
         uxCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="hSBUd/eG";
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m200sor4853185itm.33.2019.03.12.10.10.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 10:10:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="hSBUd/eG";
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=q63ookcgnvhAqs3Sfl5pVKDmKu933OB0+OqZ26Ou1RY=;
        b=hSBUd/eG9bU9hkcXf07Vnzfvi70ZPJSBcBfruaCjFYM14tdDKN1568MVLHVkp1/rzg
         +6Kvr4CytIiREYS1zYlJHoH0flAM+XoTrGW0QCnwrTFi8ah/X4azfw5jprA37easCbb6
         WWKnUm+2oRUpKiOdwawihqIoCdbHuur985R5Kkka3cKAsMMJZbuwhwEvkcBX7iQcpmff
         Ltj6D7ENtQA15Jtc0daYUa/UPPmEAq+7Q7HYNkrp8zPyXJl1seIegJbM0EEuiUPKUWsi
         h6I5mMiXJmk0x9sKsteaUVj7+VdBvxAvjIcz+jlPIwTaTcR9NVX/luULEMgqgAncsgAa
         nynw==
X-Google-Smtp-Source: APXvYqwqCfJYHXCtfsLZSl2M8UsGhzjYvPKuIRwXqEZvL3LVq/MLO/l88WdygX5M9kEtHiE4/PMhCh92IpnBJ8mAObU=
X-Received: by 2002:a24:3b01:: with SMTP id c1mr2440750ita.144.1552410649381;
 Tue, 12 Mar 2019 10:10:49 -0700 (PDT)
MIME-Version: 1.0
References: <00000000000010b2fc057fcdfaba@google.com> <0000000000008c75b50583ddb5f8@google.com>
 <20190312040829.GQ2217@ZenIV.linux.org.uk>
In-Reply-To: <20190312040829.GQ2217@ZenIV.linux.org.uk>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 12 Mar 2019 18:10:37 +0100
Message-ID: <CACT4Y+atEoMK8GFHTyH-L617-Qbsds5OkqcU1ibc2NR7DUKK3Q@mail.gmail.com>
Subject: Re: INFO: rcu detected stall in sys_sendfile64 (2)
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: syzbot <syzbot+1505c80c74256c6118a5@syzkaller.appspotmail.com>, 
	David Airlie <airlied@linux.ie>, Andrew Morton <akpm@linux-foundation.org>, 
	Amir Goldstein <amir73il@gmail.com>, Chris Wilson <chris@chris-wilson.co.uk>, 
	"Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, 
	DRI <dri-devel@lists.freedesktop.org>, eparis@redhat.com, 
	Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, 
	intel-gfx <intel-gfx@lists.freedesktop.org>, Jan Kara <jack@suse.cz>, 
	Jani Nikula <jani.nikula@linux.intel.com>, 
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Ingo Molnar <mingo@redhat.com>, mszeredi@redhat.com, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Peter Zijlstra <peterz@infradead.org>, 
	Rodrigo Vivi <rodrigo.vivi@intel.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, 
	Matthew Wilcox <willy@infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 5:08 AM Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> On Mon, Mar 11, 2019 at 08:59:00PM -0700, syzbot wrote:
> > syzbot has bisected this bug to:
> >
> > commit 34e07e42c55aeaa78e93b057a6664e2ecde3fadb
> > Author: Chris Wilson <chris@chris-wilson.co.uk>
> > Date:   Thu Feb 8 10:54:48 2018 +0000
> >
> >     drm/i915: Add missing kerneldoc for 'ent' in i915_driver_init_early
> >
> > bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=13220283200000
> > start commit:   34e07e42 drm/i915: Add missing kerneldoc for 'ent' in i915..
> > git tree:       upstream
> > final crash:    https://syzkaller.appspot.com/x/report.txt?x=10a20283200000
> > console output: https://syzkaller.appspot.com/x/log.txt?x=17220283200000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=abc3dc9b7a900258
> > dashboard link: https://syzkaller.appspot.com/bug?extid=1505c80c74256c6118a5
> > userspace arch: amd64
> > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=12c4dc28c00000
> > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=15df4108c00000
> >
> > Reported-by: syzbot+1505c80c74256c6118a5@syzkaller.appspotmail.com
> > Fixes: 34e07e42 ("drm/i915: Add missing kerneldoc for 'ent' in
> > i915_driver_init_early")
>
> Umm...  Might be a good idea to add some plausibility filters - it is,
> in theory, possible that adding a line in a comment changes behaviour
> (without compiler bugs, even - playing with __LINE__ is all it would
> take), but the odds that it's _not_ a false positive are very low.

Thanks for pointing this out.

I've started collecting all such cases, so that we are able to draw
broader conclusions later:
https://github.com/google/syzkaller/issues/1051

added for this one:
=========
A mix of problems: unrelated bug triggered by the same repro
("WARNING: ODEBUG bug in netdev_freemem"); lots of infrastructure
failures ("failed to copy test binary to VM"); also the original
failure seems to be flaky. All this contributed to pointing to a
random commit.
Al Viro points out that the commit only touches comments, so we could
mark the end result as suspicious.
=========

The infrastructure problems is definitely something we need to fix
("failed to copy test binary to VM") (currently the machine hangs
periodically with lots of time consumed by dmcrypt, but I don't know
if it's related or not yet).

Re the comment-only changes, I would like to see more cases where it
would help before we start creating new universes for this. We could
parse sources with clang to understand that a change was comment-only,
but I guess kernel is mostly broken with clang throughout history....

