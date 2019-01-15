Return-Path: <SRS0=hkLx=PX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49321C43387
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 07:26:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00B8520656
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 07:26:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ravfEcEV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00B8520656
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E42F8E0004; Tue, 15 Jan 2019 02:26:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 893F08E0002; Tue, 15 Jan 2019 02:26:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AA6A8E0004; Tue, 15 Jan 2019 02:26:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 55DD88E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 02:26:04 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id x12so1365138ioj.2
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 23:26:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=XJlg7UDv823W51FZR5L9hQOxxuEOpYTa3DBA12ck1aU=;
        b=X7t+X3OUxNP51R95VTldzT0/mw7gy5i2MnaFVeKAfdikqa6hpo7HDcVko0kSGzdCVR
         NlwS/8upYga40tTfkA7X6fTqUnZKFAO1qvyCwU2D/O+l4af0sRizx63fiVdFsplSdGHD
         Z+xR4C/GTaYtrRPpCC+lBFOoDD/cDhUdn4mDXggxjHID70fOSuh4WoavlqDanG4KvtlK
         uFBb7mvQcWIhkQ553HLbR6woYNlPzmf1d1MchCYLeajoC4XGYL5rGB0y2kHR6kmxbW8I
         5vz2tK/QnDw0VQAQ4NF3HkeN3Fttee0m+kiWUrwSBFGKPFDOfVb2eZB48pAfC9YFns2r
         cSgw==
X-Gm-Message-State: AJcUukeLbEaHehA12PcfD0G5Rd1e3gdnftoFe3ZVciUExQH2kV/FtL7G
	TsTre5NZ8CCGB36jiri8ZBhkCCOKafrB7XvzAU4jHVw6bXtNFdpAYYEkkaLjSf2lWRKEyjyYZl3
	sx2BW+aEgQ7LjutZJY9DOFAhAIitnmVEQxFbU27ufc90PvRFeuuSqtzBXwRG9rOnbqEVZkVRChi
	EP1vil+i9fKYyLGRWZYccsTHILafkCGEAfTvZ9bH8lK3Q+z3YliLR9UFhEpeGJNvMWP+PS6LBAw
	3qXBktUcyLtqNuhjxI3pbvF3ZRzWbkRl7lkrRT47jTPWu/me7iUG8RPIu1R8m7pexPXjc2w2y7x
	slFwZTQPEG+NhIDMbziSgCDSo80sa+/ojwpEAh3ZJlLGaPAoe1pIpvm2eyBOXr9SF2QHNvVpEpc
	U
X-Received: by 2002:a24:4843:: with SMTP id p64mr1723328ita.119.1547537164048;
        Mon, 14 Jan 2019 23:26:04 -0800 (PST)
X-Received: by 2002:a24:4843:: with SMTP id p64mr1723310ita.119.1547537163022;
        Mon, 14 Jan 2019 23:26:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547537163; cv=none;
        d=google.com; s=arc-20160816;
        b=iVyong9Am34eZ17nHh3ndW7CJmN8aa+8keW3PJ5V04ZpoS9rWS1JqQqkgwj/sdtBxq
         Eh6irrv6fu0smdTESoTg8yBb0VbzsiyZSGd6IffTx+E/sB2pNwbE+uw8Rmi3mxjbOmwE
         x9lca5mXtfCTYu0VewainchWMbOZYFu7Q9mPVDrs8q52pm04DnLuLvsXyBpBWSXS1Aue
         RuxxlejaUw9vvgnoINex1+0+vb/0xhbALdej/EjUQVLQZ1gmvARPsavuFK2Y6QN53s0J
         FxpvKri/6svxsjD79NL2UiguXNnDA7WIt03Wsq6uupho2XvIsTquSXFP6RmJHs02qroq
         0ZSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=XJlg7UDv823W51FZR5L9hQOxxuEOpYTa3DBA12ck1aU=;
        b=RtUq8IzqDG52nNQ+OTHd0ew7pCkefyCqcRPvb6ZBXoem8CcGbxQUQkz1aa8UOCOZFR
         dEiBTwhwUfkQp/mivOj+K5nhMzbxCIUUUXTrY0+ff9GXpCCXZyae/gD3FQfLUEVDoVD1
         4JWj0bKUMVnbYmZJ615g4IJnBPnDhnroF/rgLTFMPtmumall29jObtGseAyZsE13AvL0
         XhLb4Imwc3A6lF4S7ecKlc/egeD39L63Tt51KnVbXBwCAyWYAUyto0rSb3QAzqishNbB
         Sk6d1MxAsN/NEQRp4WkcMhFNXZr66kpPuCRt9LVHH4skTq06JrJwJTEtnmRKijhA1+Dg
         VvAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ravfEcEV;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j79sor5854057jad.11.2019.01.14.23.26.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 23:26:03 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ravfEcEV;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=XJlg7UDv823W51FZR5L9hQOxxuEOpYTa3DBA12ck1aU=;
        b=ravfEcEVjc1PWtNHe5JFNQpvrDPHkP7/913XlgPu4Lo65Qpi7M4y+0Hx3zbCAuRd5c
         gljum53+MwHk9zKIYmQK0HswGkN2GpeEbz6rtYRyXOW49f7BvDuoKRsDFYhoqCCmtwH/
         YYuAwOpTXEt1nJhXZJEQu7XFyvXtBLPXhEiRDtXbIEFlQaNDt5glkBT1a6GqwWyV7SFf
         4f8/u4z1IHe9LslaLQZtxWuToviE2IWbrktRxtDs47zq8oEqrcYq5jxsm0uKuFA5dL7z
         zrA8b2uoDFGiTEIXhQHFNSGSXgYtyscjVtrFuhLiehdFZTbyrpSbIyi+Y3SFhvdDWOTD
         qs2g==
X-Google-Smtp-Source: ALg8bN6YwqPFj4vZ8gQa/IMFGLXOomw5FoQoxDAjYLZwlX4XMCYOudW9/yWBmkcSKEQtLmarYinnVvK17onysjZsjuk=
X-Received: by 2002:a02:ac8c:: with SMTP id x12mr1237735jan.72.1547537162534;
 Mon, 14 Jan 2019 23:26:02 -0800 (PST)
MIME-Version: 1.0
References: <000000000000f49537057f77cb00@google.com>
In-Reply-To: <000000000000f49537057f77cb00@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 15 Jan 2019 08:25:51 +0100
Message-ID:
 <CACT4Y+Zj0h69KdTKD8N7bcpJF4AMyDK0WGEQ8uueL5Nf3DC1YQ@mail.gmail.com>
Subject: Re: KASAN: use-after-scope Read in corrupted
To: syzbot <syzbot+bd36b7dd9330f67037ab@syzkaller.appspotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Qian Cai <cai@lca.pw>, 
	Chris von Recklinghausen <crecklin@redhat.com>, Kees Cook <keescook@chromium.org>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190115072551.jgLungiMMW_Wc2EuqewqLxf66gYKzGIZmKdRvnxuLwA@z>

On Tue, Jan 15, 2019 at 5:43 AM syzbot
<syzbot+bd36b7dd9330f67037ab@syzkaller.appspotmail.com> wrote:
>
> Hello,
>
> syzbot found the following crash on:
>
> HEAD commit:    1bdbe2274920 Merge tag 'vfio-v5.0-rc2' of git://github.co=
m..
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=3D1519d39f40000=
0
> kernel config:  https://syzkaller.appspot.com/x/.config?x=3Dedf1c3031097c=
304
> dashboard link: https://syzkaller.appspot.com/bug?extid=3Dbd36b7dd9330f67=
037ab
> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=3D10fce14f400=
000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=3D110b201740000=
0

Based on the reproducer this is:

#syz dup: kernel panic: stack is corrupted in udp4_lib_lookup2


> IMPORTANT: if you fix the bug, please add the following tag to the commit=
:
> Reported-by: syzbot+bd36b7dd9330f67037ab@syzkaller.appspotmail.com
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> BUG: KASAN: use-after-scope in debug_lockdep_rcu_enabled.part.0+0x50/0x60
> kernel/rcu/update.c:249
> Read of size 4 at addr ffff8880a945eabc by task
> `9=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD#=EF=BF=BD(  =EF=
=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD<=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=
=BF=BD=EF=BF=BD  k=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=
=BF=BDE=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD>9h=EF=BF=BD=EF=BF=BD=
=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDA/-2122188634
>
> CPU: 0 PID: -2122188634 Comm: =EF=BF=BD=EF=BF=BDE=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=
=EF=BF=BD=EF=BF=BDO2=EF=BF=BD Not tainted 5.0.0-rc1+
> #19
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> ------------[ cut here ]------------
> Bad or missing usercopy whitelist? Kernel memory overwrite attempt detect=
ed
> to SLAB object 'task_struct' (offset 1344, size 8)!
> WARNING: CPU: 0 PID: -1455036288 at mm/usercopy.c:78
> usercopy_warn+0xeb/0x110 mm/usercopy.c:78
> Kernel panic - not syncing: panic_on_warn set ...
> CPU: 0 PID: -1455036288 Comm: =EF=BF=BD=EF=BF=BDE=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=
=EF=BF=BD=EF=BF=BDO2=EF=BF=BD Not tainted 5.0.0-rc1+
> #19
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
> Kernel Offset: disabled
> Rebooting in 86400 seconds..
>
>
> ---
> This bug is generated by a bot. It may contain errors.
> See https://goo.gl/tpsmEJ for more information about syzbot.
> syzbot engineers can be reached at syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report. See:
> https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with
> syzbot.
> syzbot can test patches for this bug, for details see:
> https://goo.gl/tpsmEJ#testing-patches
>
> --
> You received this message because you are subscribed to the Google Groups=
 "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an=
 email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgi=
d/syzkaller-bugs/000000000000f49537057f77cb00%40google.com.
> For more options, visit https://groups.google.com/d/optout.

