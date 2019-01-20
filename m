Return-Path: <SRS0=a6Xk=P4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6170C6369F
	for <linux-mm@archiver.kernel.org>; Sun, 20 Jan 2019 13:30:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6186220861
	for <linux-mm@archiver.kernel.org>; Sun, 20 Jan 2019 13:30:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ovui++He"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6186220861
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AADAB8E0003; Sun, 20 Jan 2019 08:30:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5CEE8E0001; Sun, 20 Jan 2019 08:30:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94D9E8E0003; Sun, 20 Jan 2019 08:30:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6E5CE8E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 08:30:42 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id b14so8491986itd.1
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 05:30:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=kvPxZxbejLIRpkWpPkQpCpqx55TaTGMUbFyDQUcQOH4=;
        b=Vt4sMaSkoePAHcIe8jCvfgWh6ukLuaTYc9IKBE2CzadJw82Dr+UfX9rujgTQx+dYlP
         C7O2aweZrOP+YX1mLk6njkdiqOeASKLqsZT2uDxCs1DgQNkLNswunS3schl7tO74gNhp
         gi45isl9V6Ee44eJbHmucp83egnXBGvKCF/LG3rIp0T8X/DX3lFjRhDh0LBk4JtkhfNO
         ++/l46nTQLDmgFTusjRJ3Ipws8PO+bHeOitRX4j2+kd2RDjBjnkOu9h+1dQI0BRFiZJI
         mwcr6qc7s1YylRbMh2PzoFuGI25gjti3pjKsIYYz3Qf7y1NQJMQP3eMOFc/h4Q5MxC55
         +KEQ==
X-Gm-Message-State: AJcUukeinlQ9Y3XtAEDPONrRFhPlUZj7UoTTfRdX5J0DLpGx8nQsHtVl
	rC2Yn18XBjGP4hkxHEMc1rQ6sinl+t/WnlmYnHLN+3yoqRzykB8hb5g4QZjhZsg/ZLd6vYpEazB
	+6pY5n1o6NjKkrGZr5IOcu7InNoUuLQfC/EoeIsZyO/E14QUKgyIRFceMCnkWXpi316akO+adN+
	rsQojKvrmWX3ZySxB70Fv752O0TjzFq/Bz5FN3hxt6SMZ8YevW6gs2tZc3gyzyfoyBG6U6KjOa4
	zfvV/vqJtVrBVTsOEyzqhfL0MN/gAXquQttyqnnTH2HhGecE3g5ZNYd6BEd/tQdshfmdNhSvRP/
	4FtcPPTgk4GgL9hpkr83/STcWSGt3+3GDpubus1+5nVcOp8IG3pdQalSTJLOVkgympwTfZkuZ+e
	S
X-Received: by 2002:a24:9307:: with SMTP id y7mr15374926itd.38.1547991042144;
        Sun, 20 Jan 2019 05:30:42 -0800 (PST)
X-Received: by 2002:a24:9307:: with SMTP id y7mr15374888itd.38.1547991040974;
        Sun, 20 Jan 2019 05:30:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547991040; cv=none;
        d=google.com; s=arc-20160816;
        b=cKBeyRT9gmWQKtZdBf6DyqUjEH0FQFVH+Cr1xeAus2XXVit1op/yGlmNjh/H9FUEpo
         CW/dWrmYMNDhmyK+XQQzE7AmKV49ZXQvcf6xeY4WIewGgXAf6g6dLGPN0i31k/aRkdAr
         Yy7XMYOG2KbSpov6qT7fTbZNsMz280t2Gvb2j4uQbxEhJCmk66Aq+vJXYl8RRK+FyMRE
         iv20OzY9aS/hKBC0eU6IdiIA64i1BYHCmFILCyfB4p3ERg4qMjGvK20VhgNrB10tQeiL
         8dF/ngCn4M4f724JO2dn3TdfLWT2U5bR2eSPKWYRCO6+q5DITvKjpqI3nIHJJBvveYcL
         szyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=kvPxZxbejLIRpkWpPkQpCpqx55TaTGMUbFyDQUcQOH4=;
        b=s4zYk46S0dCmCUOj/GwDBxNfMASq1m9k8LyGFL23JOrZLlgMmoTIaKsaEOwDVmN1Wj
         1K965msX4oYhr1s3U+cE5QBrLDk2mFU+F0YODVhhP1jwz6wBGNqftWeRWTZv8nkEXZnl
         jCrpT4nZqtxFty3jYjjDn+QTc6C68WDV2f+OExZEs8d6OXAcN63fTGbXmSpx1HlZED5Y
         0R+EP5HzZMf9LMzsD+vkcuq1edLgezM8QB3FeBo2JiMRwCQK0gSGe7e4s+2LQYzKvqMb
         /tSHmWED2V5vDYv6hQM9uu/UVyVUW9OShRCbwVj6vcwfAJDTKpCnH7Z7pJd/RoTDru/Z
         3idQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ovui++He;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 23sor24563116jal.5.2019.01.20.05.30.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 Jan 2019 05:30:40 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ovui++He;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=kvPxZxbejLIRpkWpPkQpCpqx55TaTGMUbFyDQUcQOH4=;
        b=ovui++HeQkza1NtzXxbxEEAuR9Kl+GYoJUXLn6Pkezrl/6olxG0GM9Emt9KnAMstkh
         m0mPlxWguzJ9f5G8d2dFTHSmm4eiWCItwxFYnaKj9DWy2UUBbNPS8feoqCI29CMaMmKD
         ZV7/XOXDTcd4pruN7Kj6IgSETHHYqCS3/SYmC1pDYTVz9yY1RnWg/mjThwG7G6D++LkC
         Q2xuRx/A5p94WPyY219D3+J4yl1qKgJJSryZSo4HoqK9YnIgWpiKLyuvSkbouA1oIFHf
         WQ4yrQZ12I+Lq57gScP1Fou22oHFv+c3pxtPeLbxhjAYZceYyXBQsHqT+c+kO23+KGkz
         srjw==
X-Google-Smtp-Source: ALg8bN4Y567V5el6qPj6tMuVjN9+Yf2lTkOzSiNd3H/zVUMmXK/cv9wDbxp2/voSuypeGaZjJ0OMecXqt6RgliDFKL0=
X-Received: by 2002:a02:97a2:: with SMTP id s31mr14655398jaj.82.1547991040336;
 Sun, 20 Jan 2019 05:30:40 -0800 (PST)
MIME-Version: 1.0
References: <ea2bc542-38b2-8218-9eb7-4c4a05da36ea@i-love.sakura.ne.jp>
 <CACT4Y+Yy-bF07F7F8DoFY8=4LtLURRn1WsZzNZ9LN+N=vn7Tpw@mail.gmail.com>
 <201901180520.x0I5KYTi096127@www262.sakura.ne.jp> <CACT4Y+acvQXPLHFSbNYAEma6Rqx6QCp_kqjsbAF8M9og4KA3CA@mail.gmail.com>
 <d90cc533-607e-fe40-9b02-a6cac7b7b534@i-love.sakura.ne.jp>
In-Reply-To: <d90cc533-607e-fe40-9b02-a6cac7b7b534@i-love.sakura.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 20 Jan 2019 14:30:29 +0100
Message-ID:
 <CACT4Y+b=5_p=eTgKobApkZZTAVeRxrn3dEempFHampFjrGX0Pw@mail.gmail.com>
Subject: Re: INFO: rcu detected stall in ndisc_alloc_skb
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com>, 
	David Miller <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, 
	LKML <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, 
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Linux-MM <linux-mm@kvack.org>, 
	Shakeel Butt <shakeelb@google.com>, syzkaller <syzkaller@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190120133029.wv1FRjIKJI1WniMZ8awYuYKB7YZ-SHEgGcxpSfI_9tg@z>

On Sat, Jan 19, 2019 at 2:10 PM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> On 2019/01/19 21:16, Dmitry Vyukov wrote:
> >> The question for me is, whether sysbot can detect hash collision with different
> >> syz-program lines before writing the hash value to /dev/kmsg, and retry by modifying
> >> syz-program lines in order to get a new hash value until collision is avoided.
> >> If it is difficult, simpler choice like current Unix time and PID could be used
> >> instead...
> >
> > Hummm, say, if you run syz-manager locally and report a bug, where
> > will the webserver and database that allows to download all satellite
> > info work? How long you need to keep this info and provide the web
> > service? You will also need to pay and maintain the server for... how
> > long? I don't see how this can work and how we can ask people to do
> > this. This frankly looks like overly complex solution to a problem
> > were simpler solutions will work. Keeping all info in a self-contained
> > file looks like the only option to make it work reliably.
> > It's also not possible to attribute kernel output to individual programs.
>
> The first messages I want to look at is kernel output. Then, I look at
> syz-program lines as needed. But current "a self-contained file" is
> hard to find kernel output.

I think everybody looks at kernel crash first, that's why we provide
kernel crash inline in the email so it's super easy to find. One does
not need to look at console output at all to read the crash message.
Console output is meant for more complex cases when a developer needs
to extract some long tail of custom information. We don't know what
exactly information a developer is looking for and it is different in
each case, so it's not possible to optimize for this. We preserve
console output intact to not destroy some potentially important
information. Say, if we start reordering messages, we lose timing
information and timing/interleaving information is important in some
cases.

> Even if we keep both kernel output and
> syz-program lines in a single file, we can improve readability by
> splitting into kernel output section and syz-program section.
>
>   # Kernel output section start
>   [$(uptime)][$(caller_info)] executing program #0123456789abcdef0123456789abcdef
>   [$(uptime)][$(caller_info)] $(kernel_messages_caused_by_0123456789abcdef0123456789abcdef_are_here)
>   [$(uptime)][$(caller_info)] executing program #456789abcdef0123456789abcdef0123
>   [$(uptime)][$(caller_info)] $(kernel_messages_caused_by_456789abcdef0123456789abcdef0123_and_0123456789abcdef0123456789abcdef_are_here)
>   [$(uptime)][$(caller_info)] executing program #89abcdef0123456789abcdef01234567
>   [$(uptime)][$(caller_info)] $(kernel_messages_caused_by_89abcdef0123456789abcdef01234567_456789abcdef0123456789abcdef0123_and_0123456789abcdef0123456789abcdef_are_here)
>   [$(uptime)][$(caller_info)] BUG: unable to handle kernel paging request at $(address)
>   [$(uptime)][$(caller_info)] CPU: $(cpu) PID: $(pid) Comm: syz#89abcdef0123 Not tainted $(version) #$(build)
>   [$(uptime)][$(caller_info)] $(backtrace_of_caller_info_is_here)
>   [$(uptime)][$(caller_info)] Kernel panic - not syncing: Fatal exception
>   # Kernel output section end
>   # syzbot code section start
>   Program for #0123456789abcdef0123456789abcdef
>   $(program_lines_for_0123456789abcdef0123456789abcdef_is_here)
>   Program for #456789abcdef0123456789abcdef0123
>   $(program_lines_for_456789abcdef0123456789abcdef0123_is_here)
>   Program for #89abcdef0123456789abcdef01234567
>   $(program_lines_for_89abcdef0123456789abcdef01234567_is_here)
>   # syzbot code section end
>

