Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E341DC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 06:03:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D8FD218E2
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 06:03:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GXl55vVe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D8FD218E2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3AA928E0003; Wed, 27 Feb 2019 01:03:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 359D38E0001; Wed, 27 Feb 2019 01:03:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 249428E0003; Wed, 27 Feb 2019 01:03:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D49F28E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 01:03:34 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id x23so8918858pfm.0
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 22:03:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=dC81/tfMHSIiyYmi1ZIAKt+KaUI2p4AW9giNPqc3Nbo=;
        b=faZ0+X8UIiHHu1JD4SAbwzOGsDndzQebnCa0+Mzf6FpyMdCLS5hKY+wF4yo7RzRDnj
         RiCK3uZsPfrjrcsWH/l8bmcE+LwU9LPvYFDMINRVlJvVZUPGbGMY4uH3FPcCkND/5AOn
         jagpmww1zNPWMXzIAKD4M0Bhix38I7NZidKnePwOcQx7aX8S41ynjhVxpf9Ey+DsGbM/
         a+yzHFpOEwxSiEx3H1b/KMqJwJFsNIyR+4pBN0enBJVugJZGvrFxsrOm57xXkkYqMDD0
         7eC/etZWiChNT0utas7lJDS2Sn9JUrcSjEp/7nhiYNMClPYesne2yaCUOluFrxv7+F7O
         F1xA==
X-Gm-Message-State: AHQUAuZ/rfpJWRfDhsqmQbR5OsDDSw056lunA8q668GwklzOhPhamR+q
	MRlvq4aybDX3aQOHyUCDxzw4iuZv58KVYXKPA1Ptw5BFRPQE3zzZnA9pmBi10MuaCaLp3/Rl3YN
	vej5IVojzK/djJHQ9oVbdx7u+2v1zdgv51j0AEqZs16gcDHso37LjN8P7FrEgQ538g1j9WJ8Ac9
	WjOCFIkriZNkQAu4qQYXqlsCccNSFXmSBMxSYdNO2mRFZ8HajgR/VvatdZEYLNXRcd0hYCEVbZN
	U+WVp7htJypp835NcB0BVh9dhYD7yfbPQS9Mofy8IsQQ/sWz9KJjusSCCfy8lvL5/VR3HkVO88S
	0jbQMXQrKaMMkuBZdnmONkqhTYNjO7b8kPIk5dMBJuXNtv0TXIP9DdzkK7xfLRo41bmcN7VU+TF
	k
X-Received: by 2002:a17:902:7007:: with SMTP id y7mr403296plk.167.1551247414321;
        Tue, 26 Feb 2019 22:03:34 -0800 (PST)
X-Received: by 2002:a17:902:7007:: with SMTP id y7mr403183plk.167.1551247412717;
        Tue, 26 Feb 2019 22:03:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551247412; cv=none;
        d=google.com; s=arc-20160816;
        b=sWnYR2moPm2nMo/dOF2smo/zir4WvTYQYjUMBdOgk+yfR3moOVVptqVWULKkiIYdGq
         qCXaGzUlwxH1LBjRIgyJ4ahCs7sPL7HwXFOrcTfT+wFgT4VT2YHC/vK7KGeCWl4m29FF
         2Q/07KJI/C8OhXp+jWXZjjCZ6nSnMDps6Yri39hWbzh2Q318HnE3bzJhdb9oVlBGipV5
         k985qwcoe9gUlW7uTdv8PnKXK2SVJcIgiz7kZvsB+tSkf8xg565gFMIptDrojVgyiwCy
         AmiPOUn8N0L11mKibmFVq1SlU/GDL9FfGwbLai2i+UViy+bZZhAU3FxywfwuqzTFBGMP
         AttQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=dC81/tfMHSIiyYmi1ZIAKt+KaUI2p4AW9giNPqc3Nbo=;
        b=YSzg4jXWokunsFGDq8LAP5ndE4jB3Ot2Eu7TT8KXMxv3gkPO8nPDFzMCIZ/lcNFEBi
         Swf2ScHm2s8nFMlYXaICYSm2NhFjS4t/s+gvuJd88QjQLzSL6vKPS2vhv3oojztl1XSv
         k0twXuaIgFYjmBRKXuSxKN4FFpSVKss9AdY36ASQMzpT3VuJiEBYI6H2Twp3FWiYUi6U
         EcgRnRK84DqwGQoaa+l46ZlGdjC8PpeSTkUCf40F3jEnfdknWaOrJQ+zdr87e1Y+u44c
         kPt0uOcSrA1DiqjlO2v/LguRNb7X38BkEbxszA+CGIcUihR1/vNibS5miB6F2F9T/A5K
         0+KA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GXl55vVe;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id bg2sor9707007plb.20.2019.02.26.22.03.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Feb 2019 22:03:32 -0800 (PST)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GXl55vVe;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=dC81/tfMHSIiyYmi1ZIAKt+KaUI2p4AW9giNPqc3Nbo=;
        b=GXl55vVeiXH39b2yTcANxwtpEtCsVSG8FUq2AJ42Z6qtHEyKa+twKfJp5ydGKda3zk
         3hQueAHBSWmABNV1J5qqW7kphBskk8uccQLajQOpn43WvnXfeI4lncnRx3XebMN9CznO
         lC8a7kzZ7WqIa8t+cI7tTKniddC3GI2Vbejqklp0z5A7lkuGmS7yIv/Xqkxzpnwv/Fgf
         XzbXXa9eRja1CI1SPApgQwTKhPT6RUJ1coHTMNe3FyO+Jj/XZNXCqvDadn/A4vqSPBYV
         fMkWxy7/e0BtG2glRpZdttfc+7LWXdthuck5oV2mrZICQ5go+YORxMZL6vtaGUUcG5sC
         4ybg==
X-Google-Smtp-Source: AHgI3Ib/d6tqB2jN/7ERCp/e0BY00EMn04/NKfUG7AVB9igevJjqFjc1fHx61v8H7QXq0irPhtpuSw==
X-Received: by 2002:a17:902:8d89:: with SMTP id v9mr448442plo.90.1551247412377;
        Tue, 26 Feb 2019 22:03:32 -0800 (PST)
Received: from localhost (193-116-71-51.tpgi.com.au. [193.116.71.51])
        by smtp.gmail.com with ESMTPSA id l5sm9436433pfi.97.2019.02.26.22.03.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Feb 2019 22:03:31 -0800 (PST)
Date: Wed, 27 Feb 2019 16:03:25 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: Truncate regression due to commit 69b6c1319b6
To: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, mgorman@suse.de
References: <20190226165628.GB24711@quack2.suse.cz>
	<20190226172744.GH11592@bombadil.infradead.org>
In-Reply-To: <20190226172744.GH11592@bombadil.infradead.org>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1551246328.xx85zsmomm.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Matthew Wilcox's on February 27, 2019 3:27 am:
> On Tue, Feb 26, 2019 at 05:56:28PM +0100, Jan Kara wrote:
>> after some peripeties, I was able to bisect down to a regression in
>> truncate performance caused by commit 69b6c1319b6 "mm: Convert truncate =
to
>> XArray".
>=20
> [...]
>=20
>> I've gathered also perf profiles but from the first look they don't show
>> anything surprising besides xas_load() and xas_store() taking up more ti=
me
>> than original counterparts did. I'll try to dig more into this but any i=
dea
>> is appreciated.
>=20
> Well, that's a short and sweet little commit.  Stripped of comment
> changes, it's just:
>=20
> -       struct radix_tree_node *node;
> -       void **slot;
> +       XA_STATE(xas, &mapping->i_pages, index);
> =20
> -       if (!__radix_tree_lookup(&mapping->i_pages, index, &node, &slot))
> +       xas_set_update(&xas, workingset_update_node);
> +       if (xas_load(&xas) !=3D entry)
>                 return;
> -       if (*slot !=3D entry)
> -               return;
> -       __radix_tree_replace(&mapping->i_pages, node, slot, NULL,
> -                            workingset_update_node);
> +       xas_store(&xas, NULL);
>=20
> I have a few reactions to this:
>=20
> 1. I'm concerned that the XArray may generally be slower than the radix
> tree was.  I didn't notice that in my testing, but maybe I didn't do
> the right tests.
>=20
> 2. The setup overhead of the XA_STATE might be a problem.
> If so, we can do some batching in order to improve things.
> I suspect your test is calling __clear_shadow_entry through the
> truncate_exceptional_pvec_entries() path, which is already a batch.
> Maybe something like patch [1] at the end of this mail.

One nasty thing about the XA_STATE stack object as opposed to just
passing the parameters (in the same order) down to children is that=20
you get the same memory accessed nearby, but in different ways
(different base register, offset, addressing mode etc). Which can
reduce effectiveness of memory disambiguation prediction, at least
in cold predictor case.

I've seen (on some POWER CPUs at least) flushes due to aliasing
access in some of these xarray call chains, although no idea if
that actually makes a noticable difference in microbenchmark like
this.

But it's not the greatest pattern to use for passing to low level
performance critical functions :( Ideally the compiler could just
do a big LTO pass right at the end and unwind it all back into
registers and fix everything, but that will never happen.

Thanks,
Nick
=

