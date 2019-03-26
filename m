Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56B2EC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 08:44:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1126B20857
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 08:44:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="gwEU1KR3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1126B20857
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D31B6B0005; Tue, 26 Mar 2019 04:44:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 983C06B0006; Tue, 26 Mar 2019 04:44:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8717D6B000D; Tue, 26 Mar 2019 04:44:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3936B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 04:44:14 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p5so4948082edh.2
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 01:44:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=fx4bc/xeU2icy5q3tRcX7R5j5vyIwYOf71aPeuGzsbk=;
        b=ZQ6b6/CyUWpOjqTJuNpn5B00gaIiTj4gftNe+IzOyq/z12oz2RzoBHwtf85/MPoLmW
         qGHCOpbJ2DhgIICrabnvLKgaPMB5jriU5/hL6L2oAV4xXFhd1D7V8uOYr+Oa0MlMjXwl
         H62BGy/6PkbS8kImOS3g/D6nJvKBljEXefzKfxmytk3YQ95s1Y/cPUbxGPjkofvGWt/g
         8rgltq+ykPU1/Kuyxc6NGnziXHjHl7d4gy9qvidbuzH1ieQJRkMhR1e2E03k5VcjiBXv
         YUdXTsSqeVkWIQnDUwd8/0wwFaUuG1AWsG/5t9dXw/XRa/qH9VnEVSG981gxV5SPURHD
         xwcA==
X-Gm-Message-State: APjAAAVPk74UzS64GwdBapbkstgSXBXmpsM8VAxfUbt2C9re4+tWf5Kc
	JHflFPoqEt7tJedXJpcgOWlpWjv2y8Iuhuji4kjLAFvggrKkrK8X4e04J/3NUbhofaxmiMY0Kym
	e4NGpp6zeMhriB8f9xSDJcGXKwS/8dNNxtWXgKJgdEJ560g0ufQdnA7dkkEjYm1A2aw==
X-Received: by 2002:aa7:dc4a:: with SMTP id g10mr4859564edu.103.1553589853749;
        Tue, 26 Mar 2019 01:44:13 -0700 (PDT)
X-Received: by 2002:aa7:dc4a:: with SMTP id g10mr4859529edu.103.1553589853006;
        Tue, 26 Mar 2019 01:44:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553589853; cv=none;
        d=google.com; s=arc-20160816;
        b=BmJm97YFWiFeA+5tuuuS55rIyjOXXvM3+cw3AUzGzMRcVGDYG1RrUfcL8rqMvGG00k
         4+yJYwU2zR5Qte2QWyZLZ4/TNlpuoSMwaHNh7wtbUCCd8018GsDMN2ihlnJPl28m0h4v
         ZVxU5WnMxrotkeDw+WkYWkNRYY/odx8Ir8nLhG3JFBRYVe2G63w0yr2whlc4M3i3LxYO
         op3VA75j4gKVYqaEt8zaUtzPnwXcMS9+fEzTKhQZsjHhCyBA7bCyMiwL0rP2LsIPW2AU
         oid2vLvetFOc8Jx8UFDKnoM9y6lZNHit7Lt8ZjyVBvWAzFCdoVisC85bteEoZL0RitTX
         s9/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=fx4bc/xeU2icy5q3tRcX7R5j5vyIwYOf71aPeuGzsbk=;
        b=VY4AtDbZJhfqg++qC5yMWtW79ejDQ3eJWldtuRUH0rPj71mkH3mtkDKlF+PL+GY6u7
         dmFR/rDTt/BKnk0KIZNXhXoJXLWMGkhB+cCa3cLwvkQxFNQEPHLSA3JW3O0R5FHEPdRq
         DkCEgL6e5Uaayk3QClOIAxf1i36FSc0sOhyKRycrNNQovDYwgjklCLVnHF+3D/tccknJ
         tbaySC6W6QXtcmy6VPf/mJhCA1xTR0TfRKqDu48GcdPde8OSTgq2bbaCOi5SYnP/CFXb
         Tikm+Ht6eGyt+sX/6BMBq0kAFf1sFvA6X1Pc3H8+R1ZT2RHdPkzpgrw+jaf7TGUbWM9A
         1q2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gwEU1KR3;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q20sor4886199ejj.0.2019.03.26.01.44.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Mar 2019 01:44:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gwEU1KR3;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=fx4bc/xeU2icy5q3tRcX7R5j5vyIwYOf71aPeuGzsbk=;
        b=gwEU1KR3zxtiCylhKYed0y7glzpT6oBSf5JMV7gKpvSIwOeGslL+XooNG6ZnEyZDYm
         HLUOslro9GUEiPPmD8g1WEp2ryXy9AEUpYaohqTDy34tZXpSqZTxWSkqaHVMnMmrJYIa
         5EYbOP5oLyqyRfki6+LZHCPK2rDoGyCVuZUZVnG6P6RKPKA2GTUpYx4cdi3Q3DTk1icZ
         SHDtEv8sHOsPpCxmwcxsw2kvba+z3KINxWrkWqZMHXlifSz8xD5dIGRqvm4k4CXRJdV0
         XK1cL+UjGVmBn5j5P/OMYbziTj5TateRBW3XPYqzpN6demf3g5IWYUDd8IK5jCY37qnt
         jB9A==
X-Google-Smtp-Source: APXvYqyGVfLO8IDDKcuLbTRKF4EtuCmDmbW+nv0Lr7fhNsh5xW2c4ofCD5NvzPVms8Z8NNhvxTSRgMO4g/zqfJ0oumY=
X-Received: by 2002:a17:906:1942:: with SMTP id b2mr16877237eje.5.1553589852412;
 Tue, 26 Mar 2019 01:44:12 -0700 (PDT)
MIME-Version: 1.0
References: <0000000000000e2b4e057c80822f@google.com> <000000000000bc42080584db9121@google.com>
In-Reply-To: <000000000000bc42080584db9121@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 26 Mar 2019 09:43:59 +0100
Message-ID: <CACT4Y+ZMfkB5kHnF5erCHtuEENLVdWGJtEME2-nx0_1+2ywe0A@mail.gmail.com>
Subject: Re: general protection fault in freeary
To: syzbot <syzbot+9d8b6fa6ee7636f350c1@syzkaller.appspotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, 
	Davidlohr Bueso <dave@stgolabs.net>, "Eric W. Biederman" <ebiederm@xmission.com>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, linux@dominikbrodowski.net, 
	manfred <manfred@colorfullife.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 24, 2019 at 7:51 PM syzbot
<syzbot+9d8b6fa6ee7636f350c1@syzkaller.appspotmail.com> wrote:
>
> syzbot has bisected this bug to:
>
> commit 86f690e8bfd124c38940e7ad58875ef383003348
> Author: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Date:   Thu Mar 29 12:15:13 2018 +0000
>
>      Merge tag 'stm-intel_th-for-greg-20180329' of
> git://git.kernel.org/pub/scm/linux/kernel/git/ash/stm into char-misc-next
>
> bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=17d653a3200000
> start commit:   74c4a24d Add linux-next specific files for 20181207
> git tree:       linux-next
> final crash:    https://syzkaller.appspot.com/x/report.txt?x=143653a3200000
> console output: https://syzkaller.appspot.com/x/log.txt?x=103653a3200000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=6e9413388bf37bed
> dashboard link: https://syzkaller.appspot.com/bug?extid=9d8b6fa6ee7636f350c1
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=16e19da3400000
>
> Reported-by: syzbot+9d8b6fa6ee7636f350c1@syzkaller.appspotmail.com
> Fixes: 86f690e8bfd1 ("Merge tag 'stm-intel_th-for-greg-20180329' of
> git://git.kernel.org/pub/scm/linux/kernel/git/ash/stm into char-misc-next")
>
> For information about bisection process see: https://goo.gl/tpsmEJ#bisection

Looking at the crash patterns in the bisection log it seems that this
is a stack overflow/corruption in wb_workfn. There are other reports
that suggest that simply causing OOM randomly corrupts kernel memory.
The semget is only an easy way to cause OOMs.
But since we now sandbox tests processes with sem sysctl and friends,
I think we can close this report.

#syz invalid

Though the kernel memory corruption on OOMs is still there.

