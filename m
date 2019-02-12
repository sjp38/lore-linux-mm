Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8994CC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 21:33:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4184A222BE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 21:33:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="i8VcmaYs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4184A222BE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D42238E0002; Tue, 12 Feb 2019 16:33:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF1998E0001; Tue, 12 Feb 2019 16:33:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C06C68E0002; Tue, 12 Feb 2019 16:33:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 80CD88E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 16:33:10 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id j32so147838pgm.5
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 13:33:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=2EB2mSUQYkL+xTBpqNZsXnjirCmnpjUHujzlNdBQPfo=;
        b=feoaazih3PXA1zQJW8bScE0VyYk/WWNDzXR0Hc1gnkqUcpRcWujVRHQlqA7eOH9JWe
         rRoDbP03woCOFRGZcWzshcthEdbe2L++LXcBTntlchV4si6IoKTw+MzjRM9S70YTt54K
         YvrFk5HLWTlqMoZUEQT+5MNoIxYFax7YrE+I/eeoBn7ZmTO/C+Nz+XiWFDFAmRHZiXOS
         EKeoCLQkhuBhnMXXSM63sGkxC03TqbpYCzSEmHfGzL+zB2dGxDqeLlG9Pa80WMHaTnB+
         SUXonlGGiOMfuO5OUbjZOUV1ArWpyoxNliZ/nx2HElGrVjxhy9XEJcTzLbCzxek4mhgK
         pRnw==
X-Gm-Message-State: AHQUAuYms1BJ0KBoBnq8S8I7MtIvqOOmRCUxTUYiVlcFksGmnN0XgPus
	r6WHiQtESsnetuS2ood82J2XD8O4pPldNHPzd2SR7McQtaana7N8C6dZZs3ijuin2+G1ts1bsDr
	cryES/CYZ3wwgdWvnVI9tUadsIqjf1IrQQn2k6D0pOcjGXeRhSeGZ47+qLng+U3T3lVPYn/A3qN
	cLddqvKoysk8uppq1A8sLum8z/PbzHAcB5WnANF6AV411pCPjrfiMqQt52O104iY6Z9h5Av8PK7
	uHpy1QE+UfMAFPCWAcbL+clR1YAj8T4d0zRUaHDgjKxOw5eLu5D4Coigw64MrxmJib1AaBXSJAA
	JcsOKnueGgqsCC/h2by9+/TO9N0g4VFqRlfqBjOI3eUB+5/0vYwRJIv9h9tR2v7MSBDys6YL+xf
	h
X-Received: by 2002:a17:902:346:: with SMTP id 64mr6154749pld.337.1550007190189;
        Tue, 12 Feb 2019 13:33:10 -0800 (PST)
X-Received: by 2002:a17:902:346:: with SMTP id 64mr6154699pld.337.1550007189461;
        Tue, 12 Feb 2019 13:33:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550007189; cv=none;
        d=google.com; s=arc-20160816;
        b=YYlaJcKbrbKwD+0r1sWkv2UPODGES6ueukPK+VDos6X8iYVy7lAj4RkJc5LKw+MIM7
         j+dACZgGhuaLo4BkGDSW958pzika1LFlg9O09MMqNNHF+cBH4CZbuTpyA+OyyArwMBe4
         oJOLa6/aPDh7mG3K5wRUL4sXsVrXZyuIVfqN6U4T3YOd204mPdlwbHKfxqZ4TGAc8SPF
         zoJ6CUW27WguPnp/L+U4fHqsVrLDhi/g6r/MPvo9sVyDpp3K1i+HHrdrtfujqdJESFpN
         70+La1pU7fGiSTo30P9fILrzm1hg2qcOK4MxiPGxYtVh+46S2YThEMJzT+U4vdKU5KEt
         1YAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=2EB2mSUQYkL+xTBpqNZsXnjirCmnpjUHujzlNdBQPfo=;
        b=Lbd5B7zPOg0E3G6/UKXSYAuCgUE3BKzLt+qDl1Sv+0S8Fsb20KrQ/PkXeB6nhEjPre
         kcQhcKTJLq5xhSAk3IcPVSEw5H+h2I43H2R26b9LYxDNry5oZkocW4HRs/eNxrWEk0cv
         DDHoFxpjlZ+YLUS5q4BUkCz84Zq93l1QhkU5wBJahHtAfDkM4MKbGpBMSN5sc0ElC7k6
         Qjh4SIDU2YAGGk6yOYpdsZfLiGKbDIX9ZMVdPxBs/iK78sjY+6UNv1d4S/MAQkx0EbBs
         IJ8sNod416wVlzXVb6/Cft9vv5JVgcvhSvILxG3a9GlSfCXrBCo0nNy4U6x+0NnKvf6a
         nxGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=i8VcmaYs;
       spf=pass (google.com: domain of smfrench@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=smfrench@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q22sor20466637pll.36.2019.02.12.13.33.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 13:33:09 -0800 (PST)
Received-SPF: pass (google.com: domain of smfrench@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=i8VcmaYs;
       spf=pass (google.com: domain of smfrench@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=smfrench@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2EB2mSUQYkL+xTBpqNZsXnjirCmnpjUHujzlNdBQPfo=;
        b=i8VcmaYsUJ7gdyey42wbhhhZFGwy9JR9hYCv0ohHCTNA46c3mpo4weoJnqOZnDc648
         Nb6/pVvvgkqdl4e8J6VDOFmLNiQ23V6rPJb+HtcOUGCLc5RJsov6Wv0JcWfbmAmq/uiu
         U2jej8vmmlEn+bfG9v5BtvknfvmkoTGL3V5WJ4CI957hKlsNJFp0ihT7AZKNb+vO8IR2
         Vx+AYHBv2kAHw5svuMuYgKNUOwZ0e43Ro8fJrCs2d8OfBynQXQuNACLWkBuNU9gMdJa3
         Mm3lmux7mnJI4GnrMkOFZ8zYJ3nePuMgtd+U77evnhwTDUgdIN+UKvzOklvescMkWYiE
         jaRg==
X-Google-Smtp-Source: AHgI3IZ61oRMp3wvcNj11SD6LMJQTsDcVhL0BvowT+uVrsfEdUpyoZmeJEgRx8r1isKkm+Yb9mFsKB3sRdIDNRIqrcs=
X-Received: by 2002:a17:902:e090:: with SMTP id cb16mr5895952plb.32.1550007188974;
 Tue, 12 Feb 2019 13:33:08 -0800 (PST)
MIME-Version: 1.0
References: <20190212170012.GF69686@sasha-vm>
In-Reply-To: <20190212170012.GF69686@sasha-vm>
From: Steve French <smfrench@gmail.com>
Date: Tue, 12 Feb 2019 13:32:58 -0800
Message-ID: <CAH2r5mviqHxaXg5mtVe30s2OTiPW2ZYa9+wPajjzz3VOarAUfw@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] FS, MM, and stable trees
To: Sasha Levin <sashal@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Makes sense - e.g. I would like to have a process to make automation
of the xfstests for proposed patches for stable for cifs.ko easier and
part of the process (as we already do for cifs/smb3 related checkins
to for-next ie linux next before sending to mainline for cifs.ko).
Each filesystem has a different set of xfstests (and perhaps other
mechanisms) to run so might be very specific to each file system, but
would be helpful to discuss

On Tue, Feb 12, 2019 at 9:32 AM Sasha Levin <sashal@kernel.org> wrote:
>
> Hi all,
>
> I'd like to propose a discussion about the workflow of the stable trees
> when it comes to fs/ and mm/. In the past year we had some friction with
> regards to the policies and the procedures around picking patches for
> stable tree, and I feel it would be very useful to establish better flow
> with the folks who might be attending LSF/MM.
>
> I feel that fs/ and mm/ are in very different places with regards to
> which patches go in -stable, what tests are expected, and the timeline
> of patches from the point they are proposed on a mailing list to the
> point they are released in a stable tree. Therefore, I'd like to propose
> two different sessions on this (one for fs/ and one for mm/), as a
> common session might be less conductive to agreeing on a path forward as
> the starting point for both subsystems are somewhat different.
>
> We can go through the existing processes, automation, and testing
> mechanisms we employ when building stable trees, and see how we can
> improve these to address the concerns of fs/ and mm/ folks.
>
> --
> Thanks,
> Sasha



-- 
Thanks,

Steve

