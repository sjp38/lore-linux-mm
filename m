Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D962FC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 08:56:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88EED2183E
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 08:56:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GU83I7/t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88EED2183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27DD06B0266; Fri, 29 Mar 2019 04:56:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22D516B0269; Fri, 29 Mar 2019 04:56:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 143F16B026A; Fri, 29 Mar 2019 04:56:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id EB04B6B0266
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 04:56:33 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id z6so1177597ioh.16
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 01:56:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=mD76T4dAek37Wg0CPxcHTAlVwwpZbdYRx32N/350cVw=;
        b=lTjJrCvzzt3Gh8xjXWEum6npDAN4bhSIzmjJ6vZZXxGoPBT8XwVNzMpubBITGce/Qz
         m9C70ESDAOPkdYKlOhZKNxMgqxjuRpIEpJVROjHzFOmSOXzhLURN6zwK/RUBJy9eZ46/
         3T8ebv5sBvOWeW0/Y4O28PbJZHmf/WogR6ZkYklPqS7JPmSj7MZjP/pXg1IHLbBBSMu9
         kdmlRBMXuzgCACtXWYJAsQaCztI9n2k0Vk9Vo+LMQ5dJpJLqHPOqxcIcFF2m5FGR6ZN4
         2zinLniEJ14lgZzdoc2jqiIYYZOUDaweAy3qld7jYeq3QdSxzJMqveF8iALfv4E895cP
         kT0g==
X-Gm-Message-State: APjAAAXsYZi2wJXx1t2tAD25tYpkFkhx5Njf5DOupCGvjQxJFtXt7v/r
	eX9iB+ZXZNcrzW8A+PjM5fRZlE/rabh+zaXjoGqC8KbxKxIX9nEkt5+abnfWgKmPGUst38cKpKH
	yoiQ/XAXq7XD+UtHbT1ZrG14phzbq00wfUzl2bvSx44vLULTCDCS8BCLCQlfZKvd+tg==
X-Received: by 2002:a24:205:: with SMTP id 5mr3648909itu.150.1553849793699;
        Fri, 29 Mar 2019 01:56:33 -0700 (PDT)
X-Received: by 2002:a24:205:: with SMTP id 5mr3648890itu.150.1553849793153;
        Fri, 29 Mar 2019 01:56:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553849793; cv=none;
        d=google.com; s=arc-20160816;
        b=o99hrIJc3QzPuwTYSguIV6+mojgzUSfPEb/zyG4yBIVhcQ/t9X4yQtOagy72+/2LTP
         kVoM8Ak9kDxkHEpgAtcmr2We4tuWoPhIZP5RN42wSeB8C/KwpgGYPBwQ1fSkqyNQ4hng
         O0YgYpEuzH6+ScKH5XX4KYpNxkdoSLJAouUz4FGZFEOZp55KphwbaBH4B4SDheL224Qm
         hBdERBr2Wi9LMnGpMcXJ1hNtRxCTJvIDuN2uyLKPiAHGMAp8alnVYjY7QxlS0EvNHRFi
         712/WHqsprgw6bXaQfrkNnW66tzShIBYuPpqE1ehUKtnE5uPswLIM48aqfsZx3ETgtmi
         N65g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=mD76T4dAek37Wg0CPxcHTAlVwwpZbdYRx32N/350cVw=;
        b=pWK+F77J3GqbMqUsVqhJoOvSUW7INLv2qPu7jNmxfA1QXY6G4M3BcX5zcPdTv5ANHV
         2lUAB7RikraePtZ6SI7Yo7X/07SlmoCBwE3Wg7zsPw2SLGCHA0RDI+e/kt5UMoWCRapJ
         MPZupka+4bE32dyPCIIJXBG62q/tvrnLTpmsbL2jrKGxgSjBHs/MZJ7UfnUAgWAyjCWK
         Nto7BrQd6L15U11OSaGSBDbl0pRkMHnRc5ppZU4M7qDYGc4XpHPYYS/qOzHSswmOzl+q
         GkMdnEHXvqoFbtTzDlKFWkukgxkDzSJcqtWcvSBdmYGzIHdsE8FV8gkuAAR2uWOEdCcO
         uwdg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="GU83I7/t";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d205sor780482iof.131.2019.03.29.01.56.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Mar 2019 01:56:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="GU83I7/t";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mD76T4dAek37Wg0CPxcHTAlVwwpZbdYRx32N/350cVw=;
        b=GU83I7/tpRYBL9XgbI1EI+GxRw+gV0pHH9Mzf6o9Y8EOkV6WbXbrN9MaQmL18dWjqE
         SNsi/zkLXwN72m0UfYclRR82LPhwQruHEZOA9wcUf2Yl1Lk38c6dkStD/9ZbFciQONfP
         c+Mcex3+6Fh/DR2El6nCzDQvcBnUXZoulmjK2ZRjon2dQysZbUr003vGXh/5yWmLChUU
         RwiFVBcMfPAauJBJmEz9kyA3DYis6IerQtg/JD4eVteAeJchb7nKylG35HqZEcREi3m5
         Jfdw4VvqTb7sd2bv1sDmF1J1XnMXY+l9Q3lDmdt0+hKoQMMYc6nJHS8IAmEPs6YNKTVe
         JcCg==
X-Google-Smtp-Source: APXvYqxlHm5sV8mBsA6ucD/xdolGp/3FxzBgnNEMIXmdME8cQBF5f18wkyJdCm73dxbfO5fVzwAEXPFjdzDnxUf65DU=
X-Received: by 2002:a6b:e50d:: with SMTP id y13mr29863307ioc.142.1553849792889;
 Fri, 29 Mar 2019 01:56:32 -0700 (PDT)
MIME-Version: 1.0
References: <1553848599-6124-1-git-send-email-laoar.shao@gmail.com>
 <60f6a5fd-e4d3-b615-6f41-cc7dd16d183c@suse.cz> <CALOAHbC7PqQ7UMm5Az=BAz9_hppYMWgNvxhq7EhqOkX0rWuQCA@mail.gmail.com>
 <e328008c-7a05-5d0e-77d7-363d21a045ed@suse.cz>
In-Reply-To: <e328008c-7a05-5d0e-77d7-363d21a045ed@suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Fri, 29 Mar 2019 16:55:56 +0800
Message-ID: <CALOAHbBUgqcZA_gPNqtky6E9CwktJPer+dv+zp=1zrZa24YNVg@mail.gmail.com>
Subject: Re: [PATCH] mm/compaction: fix missed direct_compaction setting for
 non-direct compaction
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>, mgorman@techsingularity.net, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 4:54 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 3/29/19 9:48 AM, Yafang Shao wrote:
> > On Fri, Mar 29, 2019 at 4:45 PM Vlastimil Babka <vbabka@suse.cz> wrote:
> >>
> >> On 3/29/19 9:36 AM, Yafang Shao wrote:
> >>> direct_compaction is not initialized for kcompactd or manually triggered
> >>> compaction (via /proc or /sys).
> >>
> >> It doesn't need to, this style of initialization does guarantee that any
> >> field not explicitly mentioned is initialized to 0/NULL/false... and
> >> this pattern is used all over the kernel.
> >>
> >
> > Hmm.
> > You mean the gcc will set the local variable to 0 ?
>
> Not local variable, but fields omitted in this "designated initializers"
> scenario.
>
> > Are there any reference to this behavior ?
>
> https://gcc.gnu.org/onlinedocs/gcc/Designated-Inits.html
>
> "Omitted fields are implicitly initialized the same as for objects that
> have static storage duration. "
> and static objects are implicitly 0
>

Got it!
Many thanks for your help.

Thanks
Yafang

