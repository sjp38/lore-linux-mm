Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B45AEC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 17:04:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 670712173C
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 17:04:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="f7IPdWVv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 670712173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02E826B0005; Thu,  8 Aug 2019 13:04:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F21B96B0006; Thu,  8 Aug 2019 13:04:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE7F56B0007; Thu,  8 Aug 2019 13:04:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id B76196B0005
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 13:04:39 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id p7so62992104otk.22
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 10:04:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ElTMuNeoHI+HHYYsxCZw6Aps3F3VALIwkdZIOhALrxA=;
        b=ILBaYuMpcH8s1YlKuCU6DiBXWAszwI5AQFtHGuTBj+DwqNocgTcl3A1EATzJNCsOWD
         +ibB5LXVtDZA1DSW+Ry092K8aAaz7It83ywQfEuKOMvUqCJA3SywSIW418r2GJ0QtV2I
         VmC9iX65CraIOBiccoN0ASIB01W7NsnDQ5bIY6JlYHigm3TL5ATcPzOgx3+RpXXjEYNr
         o9/anbYh4+j3sMceb3HxTHNgWJHecMk7CY6RgdTtpz67qKyoqhj28Un6bxL2yNkoCsiG
         OI7p7+LyA9I6T6xlIc3/8bP85DQC6USlT7Ts9p8OTejnNy34b23opGOABMMEp5/doIts
         yDIw==
X-Gm-Message-State: APjAAAWGZxYAkoOGdxUyNxtKF3abtRxA3Ldv54ahxccQue5uhxWoETrC
	YFtCsR0353kUCieI6oZnLUGjgTXYKxRYGZmaxR1MVnxV9vWmL4B4XhtAGExYNLVVGyFh/L33TEK
	plAKZRILUm+U39cIoQJr6/VlkFTyW67QXlZSEbmRbUeIzK88TU6R1MdMq2p8bEnF9xQ==
X-Received: by 2002:a5d:9448:: with SMTP id x8mr17462895ior.102.1565283879418;
        Thu, 08 Aug 2019 10:04:39 -0700 (PDT)
X-Received: by 2002:a5d:9448:: with SMTP id x8mr17462832ior.102.1565283878618;
        Thu, 08 Aug 2019 10:04:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565283878; cv=none;
        d=google.com; s=arc-20160816;
        b=PSvA0usHfJqnvr/quM+tsC36AP7ppY/Bb/+xa6JDDZd6oO9Y2l/8VS8SMWbMTM8ZU8
         1njtHsfd3FOqQ0IVayP2PkxYpxbk44b/9LMyAijndRAklVvUpplkZrLhnNN1Rh3cdpC2
         zLHemtQc2oVvL+wXtID9uM3921dJFp2HyBlj9E6g2OeZlWH0AhfUIVlSyb/xmz0OkgvM
         aiVAbaVYhNyrEZXY50m8PEa6B75+edGosXuATVOuR1LqioQlFm/T3QiboZl8YZV7G42w
         psgi9s83CzVA3KKYgU0Ohhwq3decOA0dffSolTepJTRdR0C3LLTN3Jvpo8BWjASYEbi+
         XljQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ElTMuNeoHI+HHYYsxCZw6Aps3F3VALIwkdZIOhALrxA=;
        b=pZGZPRNxDdTeKxCoo/CfXP2R9jb9LfvwE0C0z5OT6Soa/IoQ7uQoyWXimWN7XCF3DP
         502xsf7fTJfV3PGAtf72IURBOFdOiBOnln0tDwQQaRk3736Cb5JXrIgo2TxepWPgJNt4
         G5q6dORTZ8KXjtvF4WnxT6ShAp8Wme6o7KHX2HPrCocxX6cQOsru5gPQiiRx38VdTRHm
         xrDOX/Rb+6TAGKkmwRewNgPFug4Jn/Wgt+Za2mzsmhkY0Byh3r91DiyyWoaV8rbRm2uM
         Q5y5oVYYIPRyPSXPH2ack6xclRqgYrLmfumoxtOdIORaKYF3IWb7iZls+RwNexAzAAx5
         0zOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=f7IPdWVv;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f7sor3503838ioc.84.2019.08.08.10.04.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Aug 2019 10:04:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=f7IPdWVv;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ElTMuNeoHI+HHYYsxCZw6Aps3F3VALIwkdZIOhALrxA=;
        b=f7IPdWVvvQMrIFT5y6nMX9j1ZB6ZXkOLJIJ/Aq5Npp3ljgbC8uD1wTUVb1YGYqPbuz
         2Rzw23yxRRYVZsgsnaQGiqh94Fj/NWZBilmwBU+klcpKW3+RuKKJv9ppHnq2b+e6xWbH
         MDzXtNYeTk7otDrS+3VsOYB6WIej4R7njmXKmAYYDXeDdwxfJ0YwuNtBz/CAyqvm9GJN
         FvFHIHEnjvkyILnV7hJTjPFqxljPzGr2S+gE+YqEiUsX2oVcmrByhzE8PblD09YU5CzF
         S9rzKRPbV3v7sewdRDTeVVN78AVthP8aLdWbboRhtFiZsenQ7fbxqTsNDHlIK8CvidEr
         dCEA==
X-Google-Smtp-Source: APXvYqzxBjBYPr3wPY34IaD0DcbIQJtetwQGaIiLDFAooByqTCVN6/j1974v7EFlnwsdK9dVBWgHIWVrxKUZGxtpblE=
X-Received: by 2002:a5e:de0d:: with SMTP id e13mr6746503iok.144.1565283877966;
 Thu, 08 Aug 2019 10:04:37 -0700 (PDT)
MIME-Version: 1.0
References: <000000000000edcb3c058e6143d5@google.com> <00000000000083ffc4058e9dddf0@google.com>
 <CAHk-=why-PdP_HNbskRADMp1bnj+FwUDYpUZSYoNLNHMRPtoVA@mail.gmail.com>
In-Reply-To: <CAHk-=why-PdP_HNbskRADMp1bnj+FwUDYpUZSYoNLNHMRPtoVA@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 8 Aug 2019 19:04:26 +0200
Message-ID: <CACT4Y+bgH9f090N6G0H0zpPBrM-pW7aXXqt9kMxLjFk2jmpAEw@mail.gmail.com>
Subject: Re: memory leak in kobject_set_name_vargs (2)
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: syzbot <syzbot+ad8ca40ecd77896d51e2@syzkaller.appspotmail.com>, 
	Catalin Marinas <catalin.marinas@arm.com>, David Miller <davem@davemloft.net>, 
	Herbert Xu <herbert@gondor.apana.org.au>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, 
	Kalle Valo <kvalo@codeaurora.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	luciano.coelho@intel.com, Netdev <netdev@vger.kernel.org>, 
	Steffen Klassert <steffen.klassert@secunet.com>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, 
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 27, 2019 at 4:29 AM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Fri, Jul 26, 2019 at 4:26 PM syzbot
> <syzbot+ad8ca40ecd77896d51e2@syzkaller.appspotmail.com> wrote:
> >
> > syzbot has bisected this bug to:
> >
> > commit 0e034f5c4bc408c943f9c4a06244415d75d7108c
> > Author: Linus Torvalds <torvalds@linux-foundation.org>
> > Date:   Wed May 18 18:51:25 2016 +0000
> >
> >      iwlwifi: fix mis-merge that breaks the driver
>
> While this bisection looks more likely than the other syzbot entry
> that bisected to a version change, I don't think it is correct eitger.
>
> The bisection ended up doing a lot of "git bisect skip" because of the
>
>     undefined reference to `nf_nat_icmp_reply_translation'
>
> issue. Also, the memory leak doesn't seem to be entirely reliable:
> when the bisect does 10 runs to verify that some test kernel is bad,
> there are a couple of cases where only one or two of the ten run
> failed.
>
> Which makes me wonder if one or two of the "everything OK" runs were
> actually buggy, but just happened to have all ten pass...


I agree this is unrelated.

Bisection of memory leaks is now turned off completely after a
week-long experiment (details:
https://groups.google.com/d/msg/syzkaller/sR8aAXaWEF4/k34t365JBgAJ)

FWIW 'git bisect skip' is not a problem in itself. If the bisection
will end up being inconclusive due to this, then syzbot will not
attribute it to any commit (won't send an email at all), it will just
show the commit range in the web UI for the bug.

Low probability wasn't the root cause as well, first runs ended with
10/10 precision:

bisecting cause commit starting from 3bfe1fc46794631366faa3ef075e1b0ff7ba120a
building syzkaller on 1656845f45f284c574eb4f8bfe85dd7916a47a3a
testing commit 3bfe1fc46794631366faa3ef075e1b0ff7ba120a with gcc (GCC) 8.1.0
all runs: crashed: memory leak in kobject_set_name_vargs
testing release v5.2
testing commit 0ecfebd2b52404ae0c54a878c872bb93363ada36 with gcc (GCC) 8.1.0
all runs: crashed: memory leak in kobject_set_name_vargs
testing release v5.1
testing commit e93c9c99a629c61837d5a7fc2120cd2b6c70dbdd with gcc (GCC) 8.1.0
all runs: crashed: memory leak in kobject_set_name_vargs
testing release v5.0
testing commit 1c163f4c7b3f621efff9b28a47abb36f7378d783 with gcc (GCC) 8.1.0
all runs: crashed: memory leak in kobject_set_name_vargs
testing release v4.20
testing commit 8fe28cb58bcb235034b64cbbb7550a8a43fd88be with gcc (GCC) 8.1.0
all runs: crashed: memory leak in kobject_set_name_vargs
testing release v4.19
testing commit 84df9525b0c27f3ebc2ebb1864fa62a97fdedb7d with gcc (GCC) 8.1.0
all runs: crashed: memory leak in kobject_set_name_vargs

But it was distracted by other bugs and other memory leaks (which
reproduce with lower probability) and then the process went random
(which confirms the bisection analysis results).

