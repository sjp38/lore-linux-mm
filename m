Return-Path: <SRS0=hkLx=PX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2831C43387
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 17:17:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DDE120657
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 17:17:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lixom-net.20150623.gappssmtp.com header.i=@lixom-net.20150623.gappssmtp.com header.b="Lz8/VpBQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DDE120657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lixom.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3CA68E0005; Tue, 15 Jan 2019 12:17:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEC518E0002; Tue, 15 Jan 2019 12:17:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDC378E0005; Tue, 15 Jan 2019 12:17:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id B3B5B8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 12:17:42 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id f24so2490027ioh.21
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 09:17:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=OyTWDGjB04njMwsJJg++MJFclcQB0WwiuSGTWP72bao=;
        b=rT24fcqKXIwbMdCKLPlQQk/yYw0KY0tzKj3D8DA5AHuUoOfFE3B4ZDI4O6nkiHs++t
         d4dYoS6BVgefvdVxmPgGmZxskVa/yHPwdf6+hdCwGR+1t6oROuQkwmSdefiPWCKQ+Qfs
         D5uJxytKowFiDnzquoFzkYM4qswUAHvLOYnNuf7AcuOcTd4RYsogdbmroYzG89e0/4aA
         M/W+UQpSgjC0AVjMPCnNM1g7bEbNAaT1ixvVBbFoN/YseEG/8mLMMgrte9wrokr5KnpK
         f7QeF9x/R2aYwuoPSR9/61WPPnmDIFz7LRufZogx/2Q0a/0GDQZHRZj9DQy5bv6TBJOk
         RRxA==
X-Gm-Message-State: AJcUukdclCcewBVyvjflKsjgo7oZBiFOntmKCpmCzbrpiaFuMHLexZbC
	CnLjAFzxXser4ik8kKPetAeN00gj/F7RFeE/zHL5cifrRJZGLfs5YH0Iq+qaU7FJiSPOcNo5D5t
	VfYuy1gJbaSLnVVZPzG2O/yZKQICdJ7Asvybn1sLmblrGwbXMOGNSAMcHmGzRrBGyGq43M1dnTS
	8g4V9grkxJWiGdtDZWkN19624NtAV1MyMq/xoQ8EcRfkW5s6g6tVn8gUSoLUpaEyEKQECE6L49w
	lVsR7ByUwdbfLernpQ3FsH8ydf0fuWf0H7ag5olZIwZlN8lN7yw8SXcaWX1pjRJhdB908Tpqhiw
	Ai+A18rTOnn73ls7HzbTHh5mrZ2xOXk1SYrV5zrsQIdJl/YcpqZHPoK6IRB37N3NAAFckyd5PiG
	x
X-Received: by 2002:a5e:a708:: with SMTP id b8mr2577752iod.126.1547572662519;
        Tue, 15 Jan 2019 09:17:42 -0800 (PST)
X-Received: by 2002:a5e:a708:: with SMTP id b8mr2577726iod.126.1547572661876;
        Tue, 15 Jan 2019 09:17:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547572661; cv=none;
        d=google.com; s=arc-20160816;
        b=YkZ4GZaG933bUVuZMccX8pc563ZJkQFZLT84GG85Fxn/bbIHkZ27A55Pmilz/qo45O
         ZS253i9fLh4jv3OYm+kB/JKtEo6K79fpcrauGrxlT7CWJrAzk/msaepyREBKO344S6m2
         deJAg3WcCLJnJWhPJYMsZS0L7BZ2coqzhdXtms/HdpDl0kAvLW6LGHhn2By9JINqd/2Q
         B/Lq2mPTyequl0XexAtriOVE2UpJ2ZYu8ofu5A05WP5Qrmosa0KAEj3IxVGtKXkroJ9d
         KO52GtSrAlPp1eKlG2Er3FsaKTqh+0+kbgJAemCgRySCcmorfskALJLWwLsBsUzm7jOX
         9Ceg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=OyTWDGjB04njMwsJJg++MJFclcQB0WwiuSGTWP72bao=;
        b=rWU6wG5zuqeUQUiWdu7VV9/cYW+HxRKECrs/3MCB++F1fLDmPLloCy0tz/QpczREQ6
         nxKCMeaZ3me4TS/Lp1+Utq1fBlrco/h093qe0Jli9oPjvczWm/UzDs2d65vlVc+DH14X
         ag1u20+4OEkvxdydKWlZxNKlYd2yKyd1wenmomcQWzMAadc6sHQzxTHP6UTatnaO02LV
         y6ZjPMbS1LcoqqkYvymZxk132vR1ayIyuBapvMQKV7irQpWWHXCW3DM908oieC2sfJtY
         7qzaSSmTUyxKWKewDUbTLfB2GNE2F4nD5QG/fiTwBq8rKzsMMfLH9IoPxMug7CMmrxOD
         Jc9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lixom-net.20150623.gappssmtp.com header.s=20150623 header.b="Lz8/VpBQ";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of olof@lixom.net) smtp.mailfrom=olof@lixom.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x16sor2000402iol.120.2019.01.15.09.17.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 09:17:41 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of olof@lixom.net) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lixom-net.20150623.gappssmtp.com header.s=20150623 header.b="Lz8/VpBQ";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of olof@lixom.net) smtp.mailfrom=olof@lixom.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lixom-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=OyTWDGjB04njMwsJJg++MJFclcQB0WwiuSGTWP72bao=;
        b=Lz8/VpBQBg9euPlPuE3cH1KxMTOGd5Rv1KU30bRzWfQOgpwAWL4UmW9ioOyUm22N6P
         ZLjksmvypvb0QuQe5TlvppW0ws6ereoHPJm3+CtmmFBo2hygTe3M+fOS7fYixDal8+wB
         g8HPWZtWJwsTKKPb+eO5tKXi+1AtJD1Tq+7tIoJrNNEZH6auJ4QmIhrcxHJBPIFg8Qk2
         n942cAdmSPaZZTIU0PJMVLWTNDVjAjrVWXKbqU1LowvHfhzmeOCa8W9YIDUqHlEgG0k9
         mM4BCog/mblnuF2+BFAnWtIrHaptDAi123wS2RG+phIi+h7/TQNiOqFTbsESuR+rUNVh
         3G5Q==
X-Google-Smtp-Source: ALg8bN6+NkI4MSEtHcJA5JExc6UAEsP+8T2ckmtM7ADijpiq1c3056xWHNsqJfLW60/Xd6baPbF/C8nYFc88HBLV04I=
X-Received: by 2002:a5e:c107:: with SMTP id v7mr2805592iol.155.1547572661412;
 Tue, 15 Jan 2019 09:17:41 -0800 (PST)
MIME-Version: 1.0
References: <20190115164435.8423-1-olof@lixom.net> <20190115170510.GA4274@infradead.org>
In-Reply-To: <20190115170510.GA4274@infradead.org>
From: Olof Johansson <olof@lixom.net>
Date: Tue, 15 Jan 2019 09:17:30 -0800
Message-ID:
 <CAOesGMg4hd8z=2FVDTYMiuKzHnobNLnncV37j77BA+gQGg=heg@mail.gmail.com>
Subject: Re: [PATCH] mm: Make CONFIG_FRAME_VECTOR a visible option
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190115171730.bem8DZ6oRqZLGZFdqsN8sqR7WUZ7F5apN0CiuROg5zo@z>

On Tue, Jan 15, 2019 at 9:05 AM Christoph Hellwig <hch@infradead.org> wrote:
>
> On Tue, Jan 15, 2019 at 08:44:35AM -0800, Olof Johansson wrote:
> > CONFIG_FRAME_VECTOR was made an option to avoid including the bloat on
> > platforms that try to keep footprint down, which makes sense.
> >
> > The problem with this is external modules that aren't built in-tree.
> > Since they don't have in-tree Kconfig, whether they can be loaded now
> > depends on whether your kernel config enabled some completely unrelated
> > driver that happened to select it. That's a weird and unpredictable
> > situation, and makes for some awkward requirements for the standalone
> > modules.
> >
> > For these reasons, give someone the option to manually enable this when
> > configuring the kernel.
>
> NAK, we should not confuse kernel users for stuff that is out of tree.

I'd argue it's *more* confusing to expect users to know about and
enable some random V4L driver to get this exported kernel API included
or not. Happy to add "If in doubt, say 'n' here" help text, like we do
for many many other kernel config options.

In this particular case, a module (under early development and not yet
ready to upstream, but will be) worked with a random distro kernel
that enables the kitchen sink of drivers, but not with a more slimmed
down kernel config. Having to enable a driver you'll never use, just
to enable some generic exported helpers, is just backwards.


-Olof

