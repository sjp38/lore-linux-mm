Return-Path: <SRS0=Ztt1=P3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1610CC61CE4
	for <linux-mm@archiver.kernel.org>; Sat, 19 Jan 2019 12:16:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B40A320821
	for <linux-mm@archiver.kernel.org>; Sat, 19 Jan 2019 12:16:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ac7DfttB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B40A320821
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E4D68E0003; Sat, 19 Jan 2019 07:16:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 494368E0002; Sat, 19 Jan 2019 07:16:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 382DE8E0003; Sat, 19 Jan 2019 07:16:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E3698E0002
	for <linux-mm@kvack.org>; Sat, 19 Jan 2019 07:16:27 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id o22so12909893iob.13
        for <linux-mm@kvack.org>; Sat, 19 Jan 2019 04:16:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=FehSnhRcoGzYgkbOlV+6a3jQTpyj4YjPYsy8gPL/1Dk=;
        b=oPnBCsomC/PNF0pinji/HAY9HQDOAjoBHlGdN6AHht5I2tXZj+ycTZaUg/jPHpWiHy
         hLgtugz4etMPdTUdffYwYvAGyssplKAlRizij0z8ER+aRtOTNwqhJbmuwFlfJcqaOX83
         6Ti+DtGVVX2mgvO+JzKwElgmmMfJ+IVUcOCRM3pr2QgN39E21lGTTsrbNFvIGx2v21EP
         rS+mqIYqTaXVXGjto4+6nG9VC6eseoyqq3Rb70AqmSa+B0J0h4u8uYTZEHG1aqFfk7u1
         nnr2Db7wrIg7Xj0rwNRaBUzmxwIi23mWT7H5A11iSm1W/oFIYNYm0qQ+f/BcTQl5hDZ7
         fSSg==
X-Gm-Message-State: AJcUukcipj70RQSKNksPjrSTp/BktwGPD1ylDNM+dKDhYWCTTHhAfReb
	xpPOcQXFbk18spRDDa/BGjaOhQRXJ3pys7Esu2xfYYkwyyevtMogbJCFEhwT8moUk8SZI2D3/tA
	FFZgl2bpyrIXHi894B9lYIwEiKTzbobJ0vpMkuBuNEtZYKC2lICKdNwOletotU9gsxt4pOZf7Zp
	NwXTZ/pJl1VERyq+Lf/PQv1dtUFe+gE287/lro+A6ZL5QkPPw66RK7yOVWD/gV+DZPLGMCwHCd9
	rdly2D7zCGkIyzBT0CZ8Cvvop8bu89oQQ41FJEfL1ckXopQ2Rqqws+TQF/DMbHWk4dtiuEl4Nvb
	xgrG3hNOQ+gVvIeuOsSNRaFf5L9WgfcrjIqodp4ZhxZFj7UNRfmrISmv+wcrA4BMGxoR3g7Ysqs
	g
X-Received: by 2002:a6b:8e16:: with SMTP id q22mr12395902iod.84.1547900186769;
        Sat, 19 Jan 2019 04:16:26 -0800 (PST)
X-Received: by 2002:a6b:8e16:: with SMTP id q22mr12395875iod.84.1547900185975;
        Sat, 19 Jan 2019 04:16:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547900185; cv=none;
        d=google.com; s=arc-20160816;
        b=P9PDJezxWpFDFuTqpwK6yhjj9Z/E734VX2Cpy33lLbqxeSEMcM9OzZ9i2U5ibCaK+Y
         EKJQYWBRqA78NHj+zQS25F2lDdZ2E5DmUSWupPoX+nkPtptH3e/lVMt6prmeNevaSZLr
         sn/OhD3NDOVDJJ5bxJgb+y2zcC5CIKLm7CetnqhY5E3m/V8DVXzBNkPDoGCrcuWgUFNS
         DZEfI6W/EHlNzGcAq6KCV+VBUYrTaQls+OsvkPEStrrLW9EdqHHnbjatWdSVcFO/LaZl
         H4vMtZkeW3QsVZNai/3D/fp53JGiUI4eXNvYqIyBr7kDfZaV5rIAJry5qk6uyj3as+Zg
         XBvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=FehSnhRcoGzYgkbOlV+6a3jQTpyj4YjPYsy8gPL/1Dk=;
        b=YaaHW5/9Iir9Rxpy062I1A5U66LPaP7KZFWa17rvp/7N+E1AiUExnK708EkMwARLqr
         qvAsbSd2csZns8BbsB7A278hPnEsUkKRB9eVLi7l1J+u9sfuilXue7Rv2PUFnBP45aUt
         MTppr1jnLczX8A80FxQzEcopJ740IkiGNXBc1mW0EMCM1PIOcF4hukIwIVAeX17xe4E/
         sGaT3ERLTeTTF2Wbc3zWcvs3IcfmwwRgJlbST5N2C4Ykz+D4KCXfYDEVD5hrFez8ZTif
         ps5udNE/XcuSQj9DEIe0g5hU401fwAPIjnFUMRtvcHtf5uOd/1wMd8w+OMXXyLNvjUzy
         myJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ac7DfttB;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l17sor3997010iob.121.2019.01.19.04.16.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 19 Jan 2019 04:16:25 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ac7DfttB;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=FehSnhRcoGzYgkbOlV+6a3jQTpyj4YjPYsy8gPL/1Dk=;
        b=ac7DfttBovy+AIoFaHFGZX2ZzvPJXtM/oVwsSTuDktywKbLSh8T0EuVbvJxxSeJ+sa
         w6NPALC8dXy566sVdj7p3/Zj3ZE/PfqnfPAvFCdG6VE7Fj/NPSIT+KJ06GqC07iGXcKm
         i3+1HZ8G86KfCnKuLpAAdQnMM3/rJdSt1wGY3Wh+JdkuQVBOT21IS7MmzSxlosFoIqj/
         Qxl8mSpvAcUYaLKPUZdOfZNJRe5fBpU6cawVv7XccRCLMWqCd43/0DxxSybX5jXLyzqb
         PwQI8tJqsUHUynVyIM9Dn/n5jU02Cjbn6PiIZVIsJq+SsuF0g2QWuuVGCe5wF/H3QGgw
         uvgg==
X-Google-Smtp-Source: ALg8bN73whMCEbc9WCZ+iapzHnbBXafy2GekP8bIeHtmJNp1swxJZUXRjkhv3uFmFbNafeGfsLcjibNIJf3JdYFooQ4=
X-Received: by 2002:a6b:fa01:: with SMTP id p1mr11714146ioh.271.1547900185316;
 Sat, 19 Jan 2019 04:16:25 -0800 (PST)
MIME-Version: 1.0
References: <ea2bc542-38b2-8218-9eb7-4c4a05da36ea@i-love.sakura.ne.jp>
 <CACT4Y+Yy-bF07F7F8DoFY8=4LtLURRn1WsZzNZ9LN+N=vn7Tpw@mail.gmail.com> <201901180520.x0I5KYTi096127@www262.sakura.ne.jp>
In-Reply-To: <201901180520.x0I5KYTi096127@www262.sakura.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sat, 19 Jan 2019 13:16:13 +0100
Message-ID:
 <CACT4Y+acvQXPLHFSbNYAEma6Rqx6QCp_kqjsbAF8M9og4KA3CA@mail.gmail.com>
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
Message-ID: <20190119121613.yNyrHcjjO_cn8jUnGnXlsIt6eq-CpjjfIw_2SFYnpIE@z>

On Fri, Jan 18, 2019 at 6:20 AM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> Dmitry Vyukov wrote:
> > On Sun, Jan 6, 2019 at 2:47 PM Tetsuo Handa
> > <penguin-kernel@i-love.sakura.ne.jp> wrote:
> > >
> > > On 2019/01/06 22:24, Dmitry Vyukov wrote:
> > > >> A report at 2019/01/05 10:08 from "no output from test machine (2)"
> > > >> ( https://syzkaller.appspot.com/text?tag=CrashLog&x=1700726f400000 )
> > > >> says that there are flood of memory allocation failure messages.
> > > >> Since continuous memory allocation failure messages itself is not
> > > >> recognized as a crash, we might be misunderstanding that this problem
> > > >> is not occurring recently. It will be nice if we can run testcases
> > > >> which are executed on bpf-next tree.
> > > >
> > > > What exactly do you mean by running test cases on bpf-next tree?
> > > > syzbot tests bpf-next, so it executes lots of test cases on that tree.
> > > > One can also ask for patch testing on bpf-next tree to test a specific
> > > > test case.
> > >
> > > syzbot ran "some tests" before getting this report, but we can't find from
> > > this report what the "some tests" are. If we could record all tests executed
> > > in syzbot environments before getting this report, we could rerun the tests
> > > (with manually examining where the source of memory consumption is) in local
> > > environments.
> >
> > Filed https://github.com/google/syzkaller/issues/917 for this.
>
> Thanks. Here is what I would suggest.
>
> Let syz-fuzzer write to /dev/kmsg . But don't directly write syz-program lines.
> Instead, just write the hash value of syz-program lines, and allow downloading
> syz-program lines from external URL. Also, use the first 12 characters of the
> hash value as comm name executing that syz-program lines. An example of console
> output would look something like below.
>
>
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
>
> Then, we can build CrashLog by picking up all "executing program #" lines and
> "latest lines up to available space" from console output like below.
>
>   [$(uptime)][$(caller_info)] executing program #0123456789abcdef0123456789abcdef
>   [$(uptime)][$(caller_info)] executing program #456789abcdef0123456789abcdef0123
>   [$(uptime)][$(caller_info)] executing program #89abcdef0123456789abcdef01234567
>   [$(uptime)][$(caller_info)] $(kernel_messages_caused_by_89abcdef0123456789abcdef01234567_456789abcdef0123456789abcdef0123_and_0123456789abcdef0123456789abcdef_are_here)
>   [$(uptime)][$(caller_info)] BUG: unable to handle kernel paging request at $(address)
>   [$(uptime)][$(caller_info)] CPU: $(cpu) PID: $(pid) Comm: syz89abcdef0123 Not tainted $(version) #$(build)
>   [$(uptime)][$(caller_info)] $(backtrace_of_caller_info_is_here)
>   [$(uptime)][$(caller_info)] Kernel panic - not syncing: Fatal exception
>
> Then, we can understand that a crash happened when executing 89abcdef0123 and
> download 89abcdef0123456789abcdef01234567 for analysis. Also, we can download
> 0123456789abcdef0123456789abcdef and 456789abcdef0123456789abcdef0123 as needed.
>
> Honestly, since lines which follows "$(date) executing program $(num):" line can
> become so long, it is difficult to find where previous/next kernel messages are.
> If only one-liner "executing program #" output is used, it is easy to find
> previous/next kernel messages.
>
> The program referenced by "executing program #" would be made downloadable via
> Web server or git repository. Maybe "executing program https://$server/$hash"
> for the former case. But repeating "https://$server/" part would be redundant.
>
> The question for me is, whether sysbot can detect hash collision with different
> syz-program lines before writing the hash value to /dev/kmsg, and retry by modifying
> syz-program lines in order to get a new hash value until collision is avoided.
> If it is difficult, simpler choice like current Unix time and PID could be used
> instead...

Hummm, say, if you run syz-manager locally and report a bug, where
will the webserver and database that allows to download all satellite
info work? How long you need to keep this info and provide the web
service? You will also need to pay and maintain the server for... how
long? I don't see how this can work and how we can ask people to do
this. This frankly looks like overly complex solution to a problem
were simpler solutions will work. Keeping all info in a self-contained
file looks like the only option to make it work reliably.
It's also not possible to attribute kernel output to individual programs.

