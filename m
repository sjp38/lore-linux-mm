Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3135EC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 17:50:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF1B02067D
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 17:50:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lWngceu5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF1B02067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73E7C8E0005; Wed, 31 Jul 2019 13:50:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6EEFB8E0001; Wed, 31 Jul 2019 13:50:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DFF08E0005; Wed, 31 Jul 2019 13:50:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4256D8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 13:50:52 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id s9so62293033qtn.14
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:50:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8H1qmZWnyPRY1VP8ewZtm5ftowSE/cfi+74EH6RJgIU=;
        b=B6dQEGrS4SFOARjsmXrX4/jV0IoP5jA3KQwPa0kAear1RswdNOErJsKthEdr2mx3J6
         dRtHc1gak+VmUZ6rVKgPZnTFfaJ2PdFOS2/1ZOJBDq/zMKJLMMlLlOA6+2v2u3vivjI3
         68Re2D52XTFxc+9/4k4PMienQmADmTS33rnBtDj2JCbjBRhD4U4oy20EZXS+DsxMNT1b
         T10uIW9OpXO554RiQFktXerVRBQgvVDDEnLNBUi/wA3iIsjoQ3XJ434RiSwXqLNJ4ezH
         sOfti+/X5g8xDGrgx0935vaqxC72l/e2tArpl51xol9p70wCDOHtoNYrpooNGvv6a0km
         h2QQ==
X-Gm-Message-State: APjAAAWc2VZrUXhjdDtkr20lmf8gdwHlrptHCOd5B7yYDJusPtgrJqYt
	afQcAhk/Fb3vXXCxyObUyTikqGuU7gfXlsS2GIOYJNon6nKOFLQbGh8Gojjz/oirN53i2gSoEVM
	CuGHtDMz7dNkXorQHGQCIydEroMRJ/5ePRKoP5L01ch2jdpH6poxTZp6B90gZS/9Svg==
X-Received: by 2002:ac8:1ba9:: with SMTP id z38mr88156487qtj.176.1564595451975;
        Wed, 31 Jul 2019 10:50:51 -0700 (PDT)
X-Received: by 2002:ac8:1ba9:: with SMTP id z38mr88156472qtj.176.1564595451506;
        Wed, 31 Jul 2019 10:50:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564595451; cv=none;
        d=google.com; s=arc-20160816;
        b=HX/KX6AK7BjHv4i+wvtHE2TD0duoMbwtqPf1z2kCXYgOZoZFuuBtv2TeUOaF/d/LYA
         iowq7DcsMUwVHj7fNh+TSBANC2H1aCfBLWL4VdSsLa03W/Y6OP9vq4LaFe0i+LBmFMgv
         uXpZ3y7FdBc/HX0cGrqKaRnDRBIpBm+ux70avBkFTn2kdXvFz5OxHxuhBnov/TujOndD
         Sf6xqlUqK+jJGsj0UJE3O6QmPHMrZrJVKsz4HLTe6Bp0nCAG8zlzIjNNCzkKXdpNINXJ
         0rQQWfz7Y1OuS27ZzEATbNDGrqH8BFWKHH1YvYy3e7Mak5OA0B230T76ET4UVoqQGp8o
         4z1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8H1qmZWnyPRY1VP8ewZtm5ftowSE/cfi+74EH6RJgIU=;
        b=z+yoICa7hX+M1AcicqYorZmlxI6AlKKuLLbUgoj/kW91gKT+66WMGoaHNf4HXZpjn/
         LoIL2ly0AWaHffJ6On3yo74l7Q1ikYq5BMP8LJGeUJbHYaPNccvyCJtQPnPK1gppIxO8
         VY832iRG8/hO4krKMUA4OwaVBwAI7lGkuNs905qcJTNsolkDbrCKiGf3YZvvp021s9lc
         /gpl9qWF/aAWIxKMsWdxd6XRHx4lXNXOuux5ryQlKuNKGqjiCYMZK6LcZ9UWPs1PKFp+
         NvVCRSxud5sODB3NWHPy27NfOh+VINo/8x0c16pN1r22E2WdpdNVmEAIRQyuUhaLJKHS
         ZpyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lWngceu5;
       spf=pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liu.song.a23@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w84sor39096883qkb.44.2019.07.31.10.50.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 10:50:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lWngceu5;
       spf=pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liu.song.a23@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8H1qmZWnyPRY1VP8ewZtm5ftowSE/cfi+74EH6RJgIU=;
        b=lWngceu52u6EsMIytANCj8jbbUIjRuFtqtH35VoHpcMzbcUQhwb2HrkU+q0Py520fw
         +aoc6Hl03liHWCq4/TPU7obfd0ky5jqklVnQ3YKO+ysumg2xfTr8b8Qk9LsLrhTBxRVi
         Xq8qF+8r6xB25OpFWkep5ToA9kmXNHIAVYJOj5giCO6iXz6MByx0K0FOgqvc7gE7lbrA
         AmMw4sO+KQ0DeBBcCTqBVy9lyhNVkOsnPjxPMZ2NuQvJ9OBLdLtC+TqonTq7sVdG3oRE
         ZJ/f8/2V36jG2uGESFH3VcNUJokeiZsFa8ZWgzcG4KhmTWRAVHbsSDKYa2K+T//pDUO6
         isrg==
X-Google-Smtp-Source: APXvYqx1vdp6YaEEtVMI7ZbVbZcRwnEweHxRBRbt4MX2JVrJxeici/yUQ1j9FXzOgHJZd/Br9Zv7MLoRACzXLUpuwEc=
X-Received: by 2002:a37:a854:: with SMTP id r81mr82915593qke.378.1564595451187;
 Wed, 31 Jul 2019 10:50:51 -0700 (PDT)
MIME-Version: 1.0
References: <20190731171734.21601-1-willy@infradead.org>
In-Reply-To: <20190731171734.21601-1-willy@infradead.org>
From: Song Liu <liu.song.a23@gmail.com>
Date: Wed, 31 Jul 2019 10:50:40 -0700
Message-ID: <CAPhsuW66e=7g+rPhi3NU8jQRGqQEz0oQ5XJerg6ds=oxMz8U1g@mail.gmail.com>
Subject: Re: [RFC 0/2] iomap & xfs support for large pages
To: Matthew Wilcox <willy@infradead.org>, William Kucharski <william.kucharski@oracle.com>
Cc: Linux-Fsdevel <linux-fsdevel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 10:17 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
>
> Christoph sent me a patch a few months ago called "XFS THP wip".
> I've redone it based on current linus tree, plus the page_size() /
> compound_nr() / page_shift() patches currently found in -mm.  I fixed
> the logic bugs that I noticed in his patch and may have introduced some
> of my own.  I have only compile tested this code.

Would Bill's set work on XFS with this set?

Thanks,
Song

>
> Matthew Wilcox (Oracle) (2):
>   iomap: Support large pages
>   xfs: Support large pages
>
>  fs/iomap/buffered-io.c | 82 ++++++++++++++++++++++++++----------------
>  fs/xfs/xfs_aops.c      | 37 +++++++++----------
>  include/linux/iomap.h  |  2 +-
>  3 files changed, 72 insertions(+), 49 deletions(-)
>
> --
> 2.20.1
>

