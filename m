Return-Path: <SRS0=q3d4=PO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10555C43387
	for <linux-mm@archiver.kernel.org>; Sun,  6 Jan 2019 15:44:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F6F320859
	for <linux-mm@archiver.kernel.org>; Sun,  6 Jan 2019 15:44:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="lTW+tCJ2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F6F320859
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B10248E0144; Sun,  6 Jan 2019 10:44:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABFBB8E0001; Sun,  6 Jan 2019 10:44:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D6668E0144; Sun,  6 Jan 2019 10:44:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 766408E0001
	for <linux-mm@kvack.org>; Sun,  6 Jan 2019 10:44:25 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id r65so45726171iod.12
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 07:44:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=jt1Op2qUk5ZeAXlGxnugwXC5LTtag5tIshqbzARd1kc=;
        b=ZGLgRifiAex03qNqj8gy0ItsvySWVse2M9G+yoznH8jhY/T0yzJYYCNuQbEv3tbW7q
         i4WaQ6U+5EJlWYPP/ail4KXHf27V6dwJ+FTyhunRA8Yw6rahsS6sP2DsuWN2e0EhMaq3
         GZmLBh83Lk64O7A2vV3bPJn3XpFRhx+NwO10jBNMjmIwejVH+lXMgKccnTRpaclhsOYl
         BwS0se+o/UvTh2pFAVHSX3F6rs7HKICNPxcRIw2wqskbYZWC/A8D+mH03PatRNwoq5yh
         78nkCVKuXr32af595Sste5/3wQP2CBDHjV55wXUXPTYkapZbm6g87ZaJSBVZ0K6SPMJc
         EPHw==
X-Gm-Message-State: AJcUukeZa+VkeN51jf3IgELnP+paR5Lj6V3jCHrNBOmx7kw8o4zkyScN
	y1Yj1rR6sFB7Wx1YV1duaqvpe+b0ha6S5W6Z8CT/dURWKAijcHr8kt5/oB+85bbfreK+NZkNBiR
	D+xGxYK/hoIVQYYmtQ9S7ER/v1NdXrLJ8Shjnb0wAZ2Zydd1kxDly9N7hT5rEMXkNqL8kMZrwS2
	WQx23ebga+qY9iciFpcY7zJ27lYUiA8YIKibrZtAjuk09ll4qLl7wFSuhaztDqFfHTnnvOrKFe5
	d7qZVfzZx0Xd5iyaaGgK6IkJiuLNI7BTIrQlY7cK6WsqaUB49OAxB8AU0fDDlavA1GGiWXZ66Ji
	a1tct2s5TaG2WXGokMN75W3XzbkNeUusvER6q5Dv+IcN0PtZRxupa43bOoW95YAHqvXLThb7mKK
	x
X-Received: by 2002:a24:74c2:: with SMTP id o185mr5292468itc.100.1546789465202;
        Sun, 06 Jan 2019 07:44:25 -0800 (PST)
X-Received: by 2002:a24:74c2:: with SMTP id o185mr5292453itc.100.1546789464433;
        Sun, 06 Jan 2019 07:44:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546789464; cv=none;
        d=google.com; s=arc-20160816;
        b=csIwOxSGVnTFrqD5o198JVpKyuxXv8LUeXdf6NQfY8wd58gzAsfQXX2NP83RDqjl7u
         ljlVWxWFO0JS9oalTxRbaBOUsED2QID/POhWdxzlKv5Gyu/1v/YQmY5XjG9BaXOkmEnV
         YPAWDdBthz3/j/rVsMhwM//Ucj78HM6yjnybL/38a8JRuSCBVWzmwYerY4XnNsJxjm0V
         FY/WA9Ld88r2/G8QLx/sZpoKJOpl44ubJQqJ975ZhbqvDrjHIj890YefHoNi18dvrZeF
         eOb4M8CrbBrP68rCiyEUyRnNiyQZHe9Q7ssoM/xRDlJR2Vn0Ryf2Hg6hFBXkqzS4toIw
         qxsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=jt1Op2qUk5ZeAXlGxnugwXC5LTtag5tIshqbzARd1kc=;
        b=i/m7OgQBJInXP2brDa8e1goGHPu2T7jRmPqbl3R0FktoDL1/QaAulE9vCKZ0OWNntF
         Cyh0MU1TLmJvDVWJ/dLDOg4yqD/jZik8WxMhOWAES+af9n2q0YbFzpkerli9cc2NzxY5
         qRpsWXSsadp8+ealFkzpSiOCQtcFvy2uI3hB/UaJK26sGfSaMDDG+kl/ZIzbsDTlzK8S
         cRgQ7D6WUqZXkt/THOV7gxXtq9frfyuwjtO3Z5/KbtoSARkDUI1Jm0U/pIindjSieGVp
         XDjZ4MduFbQaJKI8Rf9eF+gnatqPkH7eTemU1G/d8POHEWtNllq+eKB/OmarBtmYtP0Z
         4rUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lTW+tCJ2;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j79sor23528646jad.11.2019.01.06.07.44.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 06 Jan 2019 07:44:24 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lTW+tCJ2;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=jt1Op2qUk5ZeAXlGxnugwXC5LTtag5tIshqbzARd1kc=;
        b=lTW+tCJ2i5S6MzinTMSyp/aHgOQJZQxRb3qwxlvEFNq7Fh1o3oxuAXM0R8tebEp4PW
         RqL/nSn2bv6P+aH1G1HA7t4UT/jsg3i+/lmVF9rgeMJtTBU89cCUTuZFduB3/LLME+R5
         dQJiXB+x49zkuVPuicbwuO2cbeLoSE8Avl27ab4XBbfyzQt1AikPfKzI0re4TVXDJgit
         /KZu10fd3FMeY372KnpXZQ1YnDE/EuZ68hkPhnwRuY4Nb5A7BlywJTVUNw+qw10AvgaS
         Arch87ZqL0awCk5kcx41r5jiT+dnB5t9flsulHTZ7uYNRHru1JezDgJjf6MGIOwBYHXi
         DiRg==
X-Google-Smtp-Source: ALg8bN4qW4aH3LNlHDvqE9PZrmRjfkCJd9owY2xcF4nOthC1M8heMo2neE4rb1M2HzD5htTBcmbcJtET0i/MPsRsV6g=
X-Received: by 2002:a02:97a2:: with SMTP id s31mr25771613jaj.82.1546789463911;
 Sun, 06 Jan 2019 07:44:23 -0800 (PST)
MIME-Version: 1.0
References: <000000000000ae2357057eca1fa5@google.com> <CACT4Y+Y+dph0wyKOLffXMPFPsvbviYzfn1nrJJgOL1ngkQLtVw@mail.gmail.com>
 <40577a65-3947-aec9-3b82-ac71f150e586@I-love.SAKURA.ne.jp>
In-Reply-To: <40577a65-3947-aec9-3b82-ac71f150e586@I-love.SAKURA.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 6 Jan 2019 16:44:13 +0100
Message-ID:
 <CACT4Y+YLi95s04V0gNS1Vg15M0ey2eAQ4j6ADW3E30XfxAekoA@mail.gmail.com>
Subject: Re: KASAN: stack-out-of-bounds Read in check_stack_object
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <syzbot+05fc3a636f5ee8830a99@syzkaller.appspotmail.com>, 
	Chris von Recklinghausen <crecklin@redhat.com>, Kees Cook <keescook@chromium.org>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190106154413.2dlAofxV9dT9o2gKt1nUndZFe4WMN69MTohGqFUQ4SA@z>

On Sun, Jan 6, 2019 at 3:37 PM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> On 2019/01/06 22:48, Dmitry Vyukov wrote:
> > On Sun, Jan 6, 2019 at 2:31 PM syzbot
> > <syzbot+05fc3a636f5ee8830a99@syzkaller.appspotmail.com> wrote:
> >>
> >> Hello,
> >>
> >> syzbot found the following crash on:
> >>
> >> HEAD commit:    3fed6ae4b027 ia64: fix compile without swiotlb
> >> git tree:       upstream
> >> console output: https://syzkaller.appspot.com/x/log.txt?x=161ce1d7400000
> >> kernel config:  https://syzkaller.appspot.com/x/.config?x=7308e68273924137
> >> dashboard link: https://syzkaller.appspot.com/bug?extid=05fc3a636f5ee8830a99
> >> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> >> userspace arch: i386
> >> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=10b3769f400000
> >>
> >> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> >> Reported-by: syzbot+05fc3a636f5ee8830a99@syzkaller.appspotmail.com
> >
> > I suspect this is another incarnation of:
> > https://syzkaller.appspot.com/bug?id=4821de869e3d78a255a034bf212a4e009f6125a7
> > Any other ideas?
>
>
>
> >> CPU: 0 PID: -1455013312 Comm:  Not tainted 4.20.0+ #10
>
> "current->pid < 0" suggests that "struct task_struct" was overwritten.
>
> >> #PF error: [normal kernel read fault]
>
> >> Thread overran stack, or stack corrupted
>
> And "struct task_struct" might be overwritten by stack overrun?
>
> The cause of overrun is unknown, but given that
> "fou6: Prevent unbounded recursion in GUE error handler" is not yet
> applied to linux.git tree, this might be a dup of that bug.


#syz dup: kernel panic: stack is corrupted in udp4_lib_lookup2

