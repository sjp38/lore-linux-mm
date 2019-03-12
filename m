Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD8A4C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 06:08:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 535AC2147C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 06:08:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="hqE6AUsr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 535AC2147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AF808E0003; Tue, 12 Mar 2019 02:08:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95CE88E0002; Tue, 12 Mar 2019 02:08:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84C048E0003; Tue, 12 Mar 2019 02:08:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 56C708E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 02:08:52 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id i4so1342410itb.1
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 23:08:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=N1JiQ1cf1uHp+tMakySvUAuKGEi8FGoygCN9wkQMXqw=;
        b=FyByUwzZ4sizpJqiLQ1HXK/QKRoxcXbOEXaDIdMz2anYyfL2LtnI1kLv4VfiyDDyd9
         Rxp41bOLMkagndbcvWZ9ZXbNdfCEkjfRFVliMY18SXlOk+NHOAZE5bFlYW6bGap5sFfQ
         xbF7a0F8t2zm+bzz90OQUXKromtsFLNz3piUgS4eIxL2oRKHDO1A6pqO3JkrcQE3KRrX
         acgVOIXdqMZxplHqnLDNQYPjCTnesLyeUZUPp6i9hrqFWOjUZGduoAkEk6/TKCXST3l/
         Ye9G9+tb5o670H8AlV2lTLOGjvciGPB08epSmq2Ee3+1g/1T3sV8/kW6PiEbDnoTPgDq
         nuoA==
X-Gm-Message-State: APjAAAUl2qHqlGjQIjYJs+7k/mnP8F2/AhDAwJCDJSgXopHcH7Y9FnMK
	gUQDc+s9mppDnqCVBQm6RoAdxrGisapS6YNljkWWyRL84oir4vYuxE27RJufV095bsUbYQrbqsh
	HKNSCQ2A/1F0qTqvZ3JKYkkkhMjW4VNDW5tNXYByleyNvVLRX+ISJwO3S0YqJgjisLsGDqC5oHq
	Crof7ojNiVNKW4HTBTNgXjSH35pvoogHcbVLPbmwPL0+oB2bPe61aJnbtZNjq4BG9763uRu9gCk
	5wpYrmpUfObEN8FjjoLJHUQ1ZRNMNw0lRKQaheIMZcPQdVpEJcufyadJF5950L+mGr4Mf55EOrp
	IMjtO4nvqaUc43eZyFSGQfkGT5WJNf13F021tHG+ZxX59xY4Y2C1Wd0eHg4RyM9vDyrvwnCGswM
	s
X-Received: by 2002:a24:b24e:: with SMTP id h14mr1169184iti.38.1552370932080;
        Mon, 11 Mar 2019 23:08:52 -0700 (PDT)
X-Received: by 2002:a24:b24e:: with SMTP id h14mr1169151iti.38.1552370931039;
        Mon, 11 Mar 2019 23:08:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552370931; cv=none;
        d=google.com; s=arc-20160816;
        b=f+ZxEAoi5bXuLPvyXssY/lesBr+281ZS+9lbmiD4aKhD+2f39H8Royf/AIWt3d+Zln
         hgiLvYToAIyCQFBtfnaLocNwpe/0RYwoa1LzUfw8mpXqrpMjuR/frVL3F+VVN3BOWb5Y
         tg51mYpZL2XroFCCcJ/Fd78aowMboYVZp+ixA35S7hDEgGn023/3bejKtWYH4kYO3nDD
         fsH8sGlC9DtxaDpCdPho1TIs8bcyuqRs4fPMAZQ4CKn6TDdYdmp2yJJ6cGmuRFjkl71X
         Iwvh4br25KDnp2fMtNJbu3aX9wxucxx6I4qrow7rFhtgckaOUMNUC/KgsZxC395bKI44
         25AA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=N1JiQ1cf1uHp+tMakySvUAuKGEi8FGoygCN9wkQMXqw=;
        b=jKr66Zl1KQMWCj+fPkRvy8B4AMVLj5X4oR57supE2r4Jf6KjFW44yG2/ct0HXMILFr
         Xz6fuOJyYqyPPfWGQIUYljZPBCFRBygfe07BjfGhOLBpi7ebayfWokG67C+JIEcYmLOu
         41x/Z7qvr54e4U4SAuBo+zJHlBT2rmQSiwEMSiB0S74JFiWxffWxXV9HXHnirzGQD35h
         fwH3l3r+1lJI7t7RyGEeJX1NHeAazWggUkZdwWmGzHq4njXbiKa32hAVxItQaUh+CEW/
         IJHG6jGJJiPSfkOR87adkPdW189lNCuduChknCeZTWDx5bbW7JFArsX4rFn3HQKRObec
         BQug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=hqE6AUsr;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r18sor2328766itb.5.2019.03.11.23.08.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 23:08:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=hqE6AUsr;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=N1JiQ1cf1uHp+tMakySvUAuKGEi8FGoygCN9wkQMXqw=;
        b=hqE6AUsrdIaw8AqgtLspHLAVKb5SxCwC13bRoQ+Z0wXsi36QiN13hYYns2oMwfN6qO
         Pc8GSslcZrTFHx+8t2295LkvYl28Oia+4xOaj0EUqW0xLreRAVcsNOiyvls9FHg5Hitw
         5PARefocPhP7I/YbPrPyxPfC518gAUgj23ET9aaCDOrZxUaVlesbZWpGxRwxd7jaE+5J
         wC0ypf6VGxVCc5XixFadnCaB1n5jJQu6rdgO5eE/wMwWsjUgKM7XGZMcg/8ZXv41k5Oo
         d8WmszRQ+rfKrZay/cpoqmTHKNlZjsJe0pTj6SN32Dv98bDzjmMIkX6VW08aG7bJB3XT
         xLWQ==
X-Google-Smtp-Source: APXvYqyGXtnMS2ogIjE5olP/bMefqZZmG86bf7yTmNWT6Oi2bSZlY5OSUGoDZnJnkjBP5bwMQsCr5Os3poCp9xG8Zic=
X-Received: by 2002:a05:660c:3d1:: with SMTP id c17mr966026itl.166.1552370930231;
 Mon, 11 Mar 2019 23:08:50 -0700 (PDT)
MIME-Version: 1.0
References: <0000000000001fd5780583d1433f@google.com> <20190311163747.f56cceebd9c2661e4519bdfc@linux-foundation.org>
In-Reply-To: <20190311163747.f56cceebd9c2661e4519bdfc@linux-foundation.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 12 Mar 2019 07:08:38 +0100
Message-ID: <CACT4Y+byKQSOCte3JS9XOnyr+aVSEFtBvLxG2-HUrZX3-82Hcg@mail.gmail.com>
Subject: Re: KASAN: null-ptr-deref Read in reclaim_high
To: Andrew Morton <akpm@linux-foundation.org>
Cc: syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com>, 
	cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>, 
	Stephen Rothwell <sfr@canb.auug.org.au>, Shakeel Butt <shakeelb@google.com>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Vladimir Davydov <vdavydov.dev@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 12:37 AM Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> On Mon, 11 Mar 2019 06:08:01 -0700 syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com> wrote:
>
> > syzbot has bisected this bug to:
> >
> > commit 29a4b8e275d1f10c51c7891362877ef6cffae9e7
> > Author: Shakeel Butt <shakeelb@google.com>
> > Date:   Wed Jan 9 22:02:21 2019 +0000
> >
> >      memcg: schedule high reclaim for remote memcgs on high_work
> >
> > bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=155bf5db200000
> > start commit:   29a4b8e2 memcg: schedule high reclaim for remote memcgs on..
> > git tree:       linux-next
> > final crash:    https://syzkaller.appspot.com/x/report.txt?x=175bf5db200000
> > console output: https://syzkaller.appspot.com/x/log.txt?x=135bf5db200000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=611f89e5b6868db
> > dashboard link: https://syzkaller.appspot.com/bug?extid=fa11f9da42b46cea3b4a
> > userspace arch: amd64
> > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=14259017400000
> > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=141630a0c00000
> >
> > Reported-by: syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com
> > Fixes: 29a4b8e2 ("memcg: schedule high reclaim for remote memcgs on
> > high_work")
>
> The following patch
> memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
> might have fixed this.  Was it applied?

Hi Andrew,

You mean if the patch was applied during the bisection?
No, it wasn't. Bisection is very specifically done on the same tree
where the bug was hit. There are already too many factors that make
the result flaky/wrong/inconclusive without changing the tree state.
Now, if syzbot would know about any pending fix for this bug, then it
would not do the bisection at all. But it have not seen any patch in
upstream/linux-next with the Reported-by tag, nor it received any syz
fix commands for this bugs. Should have been it aware of the fix? How?

Thanks

