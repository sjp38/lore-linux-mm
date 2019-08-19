Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33CB9C3A5A1
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 22:22:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E0AE62087E
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 22:22:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="CZPNWD6Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0AE62087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B0146B000A; Mon, 19 Aug 2019 18:22:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85FDD6B000C; Mon, 19 Aug 2019 18:22:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7761A6B000D; Mon, 19 Aug 2019 18:22:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0235.hostedemail.com [216.40.44.235])
	by kanga.kvack.org (Postfix) with ESMTP id 53EAB6B000A
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 18:22:17 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id EFE52180AD7C3
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 22:22:16 +0000 (UTC)
X-FDA: 75840601872.21.bath53_30fbaf32a3629
X-HE-Tag: bath53_30fbaf32a3629
X-Filterd-Recvd-Size: 4625
Received: from mail-pl1-f194.google.com (mail-pl1-f194.google.com [209.85.214.194])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 22:22:16 +0000 (UTC)
Received: by mail-pl1-f194.google.com with SMTP id f19so1233532plr.3
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 15:22:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=Lcaalc+Y1kuv7I/RlswVoXefElZgsvwmbyr3DFrYUyY=;
        b=CZPNWD6YetEikyGkoDCuZkI0MKeRxm3tHLA/tkADRiT8Ty/2bRhrQZVHG6kx2C8Erl
         FyYb2HZW0wqwcR3x2ql2AfH9hEdmKB/QcZkntsUOX7YwQObxP5H7OjhroPhwPh272vBu
         DtoEC3CHyhAZKbeoXxBiwNnzaIZ85lxuKWYayTQU1n4EKAZTva7s5i27mNbkWRfWqeTu
         MC2ZX2nbO9U39lHvxeCW9dQfeCgAV1mlgzqkfY4YefTedsSaE/+xfYRdcKqyQpzNgYYm
         7DsLdXzpQ1i5TxpkO6RMyY5vIzvk0F0aTw660rKdvKaxrx11+0rKap8kyxX3NTF14mGG
         JR5Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=Lcaalc+Y1kuv7I/RlswVoXefElZgsvwmbyr3DFrYUyY=;
        b=rZFQoFZk0z1Jfb8r5HTuXfLN9ehbvWXg6LE16uamAsYVvkkNmcGebuoqZqYEoKtgfe
         RI/oXTyl3UfLJVFZJl3ZlyHJSK/VVWQSvFIfBDKvouPCkkTAIqRaHj7Yknt982ota+LH
         vLkbMBMqel1BTyo/A0l8NJEOxsfxKNZ7DkaJHSgSBLJh6KIqIFwU6zaAD39LKist9Dji
         AqMeld/g7M7PCq3bU1kDC4+FdsI68Hd9oZ8FcPwA5QE889OEn9T7oldyCMTNOTHv8O2K
         N311wS177+jx1cutNCcJ0a719snh+jJHuDjJPo29Mq7trpnhEJK/ol6/2gclKZ7dJkGk
         +idw==
X-Gm-Message-State: APjAAAUVe3v1QJB4lPTHEBT3QG2J1XuXIjpout1MKaFoC9kI29lq4buL
	TQhHI+OBRsN2XDXnMkzZajVouw==
X-Google-Smtp-Source: APXvYqyiGoWx93ACPN8pVo/ovNAO+ev/S6tQS4IypxdIbiocT+IvsE3qq6CHW88HuF2pH/t68NQX7A==
X-Received: by 2002:a17:902:2bc7:: with SMTP id l65mr12691612plb.119.1566253334806;
        Mon, 19 Aug 2019 15:22:14 -0700 (PDT)
Received: from [100.112.91.228] ([104.133.8.100])
        by smtp.gmail.com with ESMTPSA id p90sm15926451pjp.7.2019.08.19.15.22.13
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 19 Aug 2019 15:22:14 -0700 (PDT)
Date: Mon, 19 Aug 2019 15:21:57 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Andrew Morton <akpm@linux-foundation.org>
cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, 
    Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: tmpfs: fixups to use of the new mount API
In-Reply-To: <20190819151347.ecbd915060278a70ddeebc91@linux-foundation.org>
Message-ID: <alpine.LSU.2.11.1908191518070.1091@eggly.anvils>
References: <alpine.LSU.2.11.1908191503290.1253@eggly.anvils> <20190819151347.ecbd915060278a70ddeebc91@linux-foundation.org>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 19 Aug 2019, Andrew Morton wrote:
> On Mon, 19 Aug 2019 15:09:14 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
> 
> > Several fixups to shmem_parse_param() and tmpfs use of new mount API:
> > 
> > mm/shmem.c manages filesystem named "tmpfs": revert "shmem" to "tmpfs"
> > in its mount error messages.
> > 
> > /sys/kernel/mm/transparent_hugepage/shmem_enabled has valid options
> > "deny" and "force", but they are not valid as tmpfs "huge" options.
> > 
> > The "size" param is an alternative to "nr_blocks", and needs to be
> > recognized as changing max_blocks.  And where there's ambiguity, it's
> > better to mention "size" than "nr_blocks" in messages, since "size" is
> > the variant shown in /proc/mounts.
> > 
> > shmem_apply_options() left ctx->mpol as the new mpol, so then it was
> > freed in shmem_free_fc(), and the filesystem went on to use-after-free.
> > 
> > shmem_parse_param() issue "tmpfs: Bad value for '%s'" messages just
> > like fs_parse() would, instead of a different wording.  Where config
> > disables "mpol" or "huge", say "tmpfs: Unsupported parameter '%s'".
> 
> Is this
> 
> Fixes: 144df3b288c41 ("vfs: Convert ramfs, shmem, tmpfs, devtmpfs, rootfs to use the new mount API")?

That's the patch and the SHA1 I saw when I looked it up in linux-next
yesterday: I don't know if the SHA1 will change before it reaches Linus.

> 
> and a Cc:stable is appropriate?

No: this is just a fix for linux-next and mmotm at present.

Hugh

