Return-Path: <SRS0=+lVK=PP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E869DC43612
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 11:13:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3CB020859
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 11:13:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="jHOvL0HC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3CB020859
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 367AD8E001D; Mon,  7 Jan 2019 06:13:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3167C8E0001; Mon,  7 Jan 2019 06:13:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 205348E001D; Mon,  7 Jan 2019 06:13:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id EC50B8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 06:13:05 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id g7so255407itg.7
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 03:13:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=YEXl1x9KpOBMBz/Mcro2sttBZKacHfsT+62DIcT6XxI=;
        b=BdZC233gexK0vkvOFINgSWruRpJkQEkW87FanLFi7ptMUle/yMYiyJqL6bE/DcqoQc
         EvNlCh+C/sA9HFZLmA5jFlMcv89/iH7RuFLjnuUAzD5syAn4A0IAPB3uYYu+ronobcUo
         iDtMRLjXGSifcNGge4+aLBsZEaCBcZX0GjepUbakSy6D7FxTn9RarDxsbeXFJB1H5HY7
         Pr9u/r6Xa2FP/u5pBg1cVSl89P4wXpN7yHmj3wjYCzcOO6Q/4dSe6NWztZvxmpLOVgVI
         n5Z3mVEEhhorcZSa/mN+rcNaw6qGeQQvOGTjXq8FAHULrg2bpjZT1HPd+rjbQgYZNBPM
         KpIw==
X-Gm-Message-State: AJcUukfVwPI4mPlYtSz5o9Mb4rDCegw4Svf5KlpXjtqQ5aTu1wScn3m4
	qECt/cQwoif7s0af4BJlR9EWUOEUWRcdnqcLu7aC+gXRCp8rJ6qUGL648OZLQfIk/0itwLIFNkr
	xYLhM+ls62/9hLHVqRAafmolr77HkS0yNU2m5B4CFqKh6I2SLevqQAQSVB6kzrxYkM1LqdIjH1I
	dQiUW957I3tJUEcR2ZwZiyZx54adgJAzpZq+7uo8NdR7x7xi3B23T8U0pb7Q1tI9ZDs5iX5bhVQ
	5SHtPqqCpKUEkNEMHBD890hg0o6cXERS9k0eVsr8adCKdgQQFFnyF+Yuru0/FZWKKJbfC5kgQ0T
	Rmr4lm1xkBjHHZuXKeJLRmzGtvaqhKkO4Xp0kU6cpGuqA7mVsDwBXgF7sJna0QstIPoEe2p5kMW
	1
X-Received: by 2002:a24:4a95:: with SMTP id k143mr6717674itb.77.1546859585672;
        Mon, 07 Jan 2019 03:13:05 -0800 (PST)
X-Received: by 2002:a24:4a95:: with SMTP id k143mr6717642itb.77.1546859584914;
        Mon, 07 Jan 2019 03:13:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546859584; cv=none;
        d=google.com; s=arc-20160816;
        b=lLHiJrpEoV1bTwycHvX5wSVOa/bJPnmmrPp7njc40or+IeW9ljcySM0ZeN5XXli2XS
         m4eJAArtr/x0FhlgLlomEYpEt93QlanGjixNSVH2yvu4odoTtz6OmGcsa3YnpwLMUP5a
         e3G8Sw6xhUxIFc8SF2UEVpSVrADx+i973kLbmvpbfOSoJqa55T6+1KjYsRF6g4Fk1z6D
         p+sY2gqKK0qUPn0LZUuxDAxBOhtYxFMadwhTn2VD6zTMmEmhZUdbQ17EwHszKOgnBb7q
         oTGkR3jgqeZVQvRN6JWEjEY+klys5c7HBE/09+coNhR0dlt173kOmoFAUrGFP1ZLe7x+
         Jqkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=YEXl1x9KpOBMBz/Mcro2sttBZKacHfsT+62DIcT6XxI=;
        b=d1nZiDRvTMFsJMTKMrk8y7dPb9bL0Eevt0OIMovk/b17pQBZa8NQXmhk/62YZ54uZf
         8bV3BaEhNPTVNdtJLUoGzKSMpoFQnjR+aa975K0AvMmWVMCuMJmD61lKFI9AcrQMcGGO
         Pj8F3lR7xtl0ANe9a9mwiKvy/tiZ+l2LkewpZ1zKiub0615nLyoAr+2o8G9g9iCmMHlw
         roR+MBt4O5D0fi/chN2BWq0r+FSAZwp+zALrIWtqNFe1vX/ZVvtYOqGFAiOfR4mB50R7
         U+uMwgo1srHXNk6eqQwP1xNmNubR/7ixs2btueLNfV4eJAeQ755iy88HUXXDUSH+Desf
         LJ3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jHOvL0HC;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z2sor32195697ioi.114.2019.01.07.03.13.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 03:13:04 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jHOvL0HC;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YEXl1x9KpOBMBz/Mcro2sttBZKacHfsT+62DIcT6XxI=;
        b=jHOvL0HC5tw9iRHiGzuJNo+PJg2hcXjv+4+Y5OOVtKunPL7RkQh4hLSexqMUxeWdLi
         ozUs2Vl1neEPXEmAiD9XBadB5jDzTs0ppFC9Us4D5zcfxVu9qVqkI62w6wZpRtzTjg6B
         0rA6KR6Cbm14Nb91dkdVDj3Jid0/ZkqrCLvhZM+yxvm/0QsLURaIqxXXhxSvqOJ6OpzA
         1Rpx7yol2hLzgVX++h48UzkgNMT8FnTo7uOQ6ePKM2aJHjOgnuLPbJcEJg3FImOuoddd
         y5CL4R6WMAyPaMP+MGjdfztfGt1it66bU8xViaAiW2Q0UQAzG/RBGvGzNwTsfxftnLLW
         14eg==
X-Google-Smtp-Source: ALg8bN4bWZnCL6g6U983BH4+/H9w3bVz56GfXr2rJC0l1ba5raWLVl+4L+8v0yBdktJI7sLvapvg8B4gQTklvsUMXmY=
X-Received: by 2002:a5d:9456:: with SMTP id x22mr14869399ior.282.1546859584353;
 Mon, 07 Jan 2019 03:13:04 -0800 (PST)
MIME-Version: 1.0
References: <0000000000007beca9057e4c8c14@google.com> <CACT4Y+Yx4BJw=F_PMx9a8AjPKzEwhzLnzt9K-dgkBoNkKQj2+g@mail.gmail.com>
 <ef2508c9-d069-2143-09a6-a90b9ef12568@I-love.SAKURA.ne.jp>
 <CACT4Y+YYwYDnqFmMwfSg6UNXnrbh46bo0jp7ijbej8nkDDmBXQ@mail.gmail.com>
 <eeb95c52-5bf8-d3ce-d32b-269aa86bcd93@i-love.sakura.ne.jp>
 <8cdbcb63-d2f7-cace-0eda-d73255fd47e7@i-love.sakura.ne.jp>
 <CACT4Y+Y5cdD=optF2k4a0W7vriVnzmzLU0SPGEJoOHRMi_bsZA@mail.gmail.com> <ea2bc542-38b2-8218-9eb7-4c4a05da36ea@i-love.sakura.ne.jp>
In-Reply-To: <ea2bc542-38b2-8218-9eb7-4c4a05da36ea@i-love.sakura.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 7 Jan 2019 12:12:53 +0100
Message-ID:
 <CACT4Y+Yy-bF07F7F8DoFY8=4LtLURRn1WsZzNZ9LN+N=vn7Tpw@mail.gmail.com>
Subject: Re: INFO: rcu detected stall in ndisc_alloc_skb
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com>, 
	David Miller <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, 
	LKML <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, 
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Linux-MM <linux-mm@kvack.org>, 
	Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190107111253.1HdgcboN6kkOTlcD3jgVIPCnrYJzoZS0E4UGep5uaiY@z>

On Sun, Jan 6, 2019 at 2:47 PM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> On 2019/01/06 22:24, Dmitry Vyukov wrote:
> >> A report at 2019/01/05 10:08 from "no output from test machine (2)"
> >> ( https://syzkaller.appspot.com/text?tag=CrashLog&x=1700726f400000 )
> >> says that there are flood of memory allocation failure messages.
> >> Since continuous memory allocation failure messages itself is not
> >> recognized as a crash, we might be misunderstanding that this problem
> >> is not occurring recently. It will be nice if we can run testcases
> >> which are executed on bpf-next tree.
> >
> > What exactly do you mean by running test cases on bpf-next tree?
> > syzbot tests bpf-next, so it executes lots of test cases on that tree.
> > One can also ask for patch testing on bpf-next tree to test a specific
> > test case.
>
> syzbot ran "some tests" before getting this report, but we can't find from
> this report what the "some tests" are. If we could record all tests executed
> in syzbot environments before getting this report, we could rerun the tests
> (with manually examining where the source of memory consumption is) in local
> environments.

Filed https://github.com/google/syzkaller/issues/917 for this.

> Since syzbot is now using memcg, maybe we can test with sysctl_panic_on_oom == 1.
> Any memory consumption that triggers global OOM killer could be considered as
> a problem (e.g. memory leak or uncontrolled memory allocation).

Interesting idea. This will also alleviate the previous problem as I
think only a stream of OOMs currently produces 1+MB of output.

+Shakeel who was interested in catching more memcg-escaping allocations.

To do this we need a buy-in from kernel community to consider this as
a bug/something to fix in kernel. Systematic testing can't work gray
checks requiring humans to look at each case and some cases left as
being working-as-intended.

There are also 2 interesting points:
 - testing of kernel without memcg-enabled (some kernel users
obviously do this); it's doable, but currently syzkaller have no
precedents/infrastructure to consider some output patterns as bugs or
not depending on kernel features
 - false positives for minimized C reproducers that have memcg code
stripped off (people complain that reproducers are too large/complex
otherwise)

