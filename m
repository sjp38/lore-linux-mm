Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E4AEC74A5E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 16:23:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02F5120838
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 16:23:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="o/LUmCZW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02F5120838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DC258E00EC; Thu, 11 Jul 2019 12:23:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 88CFE8E00DB; Thu, 11 Jul 2019 12:23:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77B8B8E00EC; Thu, 11 Jul 2019 12:23:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5371B8E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 12:23:45 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id h198so4354332qke.1
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 09:23:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=NgX19u0heI/R9GWSrmSZNT4oXJAtelbkkimiVF3UJzg=;
        b=fLP/4yZCJHcE76pwmfNDEg2jAPRHxKv6Q91EtpTKYb3a7Am/UqlGXcjjkrPmZXpyA1
         8sc+vxT3PCDZ1MXHnES5jVhQ6mCx2mw+bRHfGxTxsG3ofCDYmJDr2Mhrc6oRwDnhG5eC
         y5mA3WOgfqwvmXiKCPTN1vMTmmC6tSyuF7dO2pOCQEGnrsspmEbRuHmYbsw/Qbn3x/vI
         GzaiLham6WMrEzIoUDiE14iyBbmE4p90XE19hf/dta6RjgWM1NRcTV8PKdo0PNxzf9PG
         pOy8B5589DzqgnpWFCegXdxFnjXxgmXug42dZJjt5kXNX0SPssmthwk3xHK26NcUkSYz
         j8Ow==
X-Gm-Message-State: APjAAAU3R9EKZLi8GcMnVQuIElWrAyiUlGL/td+fzFECW+RNgP28acOm
	n/puyy+B6e7bhas+CJKiu8FXIsJ0/250dtc+4VI+l1JjTX0O8flvCgYiINGeQKDESAypiCGh3Z+
	oh1uo6YEKv1nLPSqymymUIH8XVBpdfTpDu8+kMzBzMJYPAWOa2+iWvB0AHnTZrgmmlQ==
X-Received: by 2002:a37:4887:: with SMTP id v129mr2510656qka.17.1562862224997;
        Thu, 11 Jul 2019 09:23:44 -0700 (PDT)
X-Received: by 2002:a37:4887:: with SMTP id v129mr2510638qka.17.1562862224463;
        Thu, 11 Jul 2019 09:23:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562862224; cv=none;
        d=google.com; s=arc-20160816;
        b=GI+TDy/OMdt98vpPfH/HNzj2yE4k7qTsl7nac4+CRxtLbNqB5PmBFqzDgC4IY/N9Sd
         cEsHwKONlWxwAs6+SNZPkbGxXD42jN/RiV5dqWKb17/gcmNj0cBu9tEaBcqjIz0UZdnk
         ejzOTlZZD4TOvMSbeR+z8ecUjFlW6JcDXMR/L2sXnrS4vF+k48bSgd8nCF8kjWG31NI6
         k+r6f6SoYuWswBkCO0ZsMMqqWWABpfInMer74gxhjhd6RmDP8v+oST3trVtdoyg4JprB
         QaZKrAQXlFHUj6FPNSfQb/SUGOD5bXw3OVAHEWRqJrBHK5qzJbNyF3AWN2J1ogZMAKgB
         tsuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=NgX19u0heI/R9GWSrmSZNT4oXJAtelbkkimiVF3UJzg=;
        b=Age6UM9Iqnv51qhPk6rR0AdABwS4dyUKBH/2/uzxrrVkdiQl9oZxmWeiEZ+E//Kh2t
         9wd9y/JkHUx68NNTFlAIzD2uTCpu7+PAc4xaWEP9sR+hfwecvTnzpMm1exa/SpaLlv60
         UqOZbvdmkB/NG9zJebOWJSfYz+KJnqJZMP/d6GwUYZ57sRGOifS7sISruh47Kr05i5yh
         6Y0wuzTtPX2r81TKnyBdM/g4uDn6NKeo0PsV1xM9c99pzEbATDU2ZmfQaNOEeuSJDRfV
         dY3S2CD37JRe9iKsHJwn+jUJ1nfEuTOQcFPefaxSA5MArbeB9UA0E7jGfgjsy8tJE1ex
         fxiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="o/LUmCZW";
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g184sor3620290qkd.150.2019.07.11.09.23.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jul 2019 09:23:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="o/LUmCZW";
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=NgX19u0heI/R9GWSrmSZNT4oXJAtelbkkimiVF3UJzg=;
        b=o/LUmCZWkgTrcmhPKv8NkFW78o92UlJzuBXusnFMwkh7utqZW2QGe2OexZjtL3Nhxg
         CuJlJwVYc0Ppan7qHJFg0lMTlVKAAMD/vnxeyK1xZx3DfvJK3DJ3Te9gFRF6f3JCYmDU
         oNFrn2mMh2w66PT6BPmvpbt9Y/5AL1rsLk9GhrsK/BhVxlp5th2/JigoiA3beLqCokHW
         I+4kuwEba+WFqG4JM9pLtFQsKqYuhzBP2oyChTMI4TxCK+DiUGSXHpSxf9l5xXkqVoBm
         aLJ3XGyvSR3nDaUUeg3shiB994CzxjaiVml2cNCDwRQAmPPezCw+juvoaMQJn9BoKC6h
         9Gvw==
X-Google-Smtp-Source: APXvYqwey4uPl4IaE9JFBv32+4j1YHIKEWpv3x5NtBhnHzyKEWNSgbxrfRXCyxtrZKLOyIsBZxsaa8ddLeaeW1pvSas=
X-Received: by 2002:a37:4ad7:: with SMTP id x206mr2695437qka.85.1562862224235;
 Thu, 11 Jul 2019 09:23:44 -0700 (PDT)
MIME-Version: 1.0
References: <20190710144138.qyn4tuttdq6h7kqx@linutronix.de>
 <CAHbLzkpME1oT2=-TNPm9S_iZ2nkGsY6AXo7iVgDUhg8WysDpZw@mail.gmail.com> <20190711094324.ninnmarx5r3amz4p@linutronix.de>
In-Reply-To: <20190711094324.ninnmarx5r3amz4p@linutronix.de>
From: Yang Shi <shy828301@gmail.com>
Date: Thu, 11 Jul 2019 09:23:31 -0700
Message-ID: <CAHbLzkr5fJ-eEhAtbubLyoEvHzjfJ3hkwbGmbiUaOVrPH_uDtw@mail.gmail.com>
Subject: Re: Memory compaction and mlockall()
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Linux MM <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 11, 2019 at 2:43 AM Sebastian Andrzej Siewior
<bigeasy@linutronix.de> wrote:
>
> On 2019-07-10 11:21:19 [-0700], Yang Shi wrote:
> >
> > compaction should not isolate unevictable pages unless you have
> > /proc/sys/vm/compact_unevictable_allowed set.
>
> Thank you. This is enabled by default. The documentation for this says
> | =E2=80=A6 compaction is allowed to examine the unevictable lru (mlocked=
 pages) for
> | pages to compact.=E2=80=A6
>
> so it is actually clear once you know where to look.
> If I read this correct, the default behavior was to ignore mlock()ed
> pages for compaction then commit
>   5bbe3547aa3ba ("mm: allow compaction of unevictable pages")

Yes, before this commit compaction doesn't migrate unevictable pages.
But, other types of migration always do.

>
> came along in v4.1-rc1 and changed that behaviour. Is it too late to
> flip it back?

Disabling it via proc knob isn't fine?

>
> Sebastian

