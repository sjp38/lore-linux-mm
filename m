Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5CDFC282DD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 08:53:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7EC3620880
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 08:53:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7EC3620880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1EF386B0005; Mon,  8 Apr 2019 04:53:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A3136B0006; Mon,  8 Apr 2019 04:53:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B68C6B0008; Mon,  8 Apr 2019 04:53:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id D5BB96B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 04:53:47 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id s184so5399525oig.19
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 01:53:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=tv3xxipDSLiRgH4b3LyJ9t2U3T11OYsUY8ozdoYoEuE=;
        b=TJqQTETs063aybjgrZaTNSjk6o5sfDrpzslQI94KcQAZkIfBi/h1BCy5F0+Kj0SqYE
         PvDKwdPjOJ5sOck0+SG4UtDlTNG2L/m6vwqWZXLiO7HyNi6JXyuukeKg1mJSV/o7qcsA
         SQitCrtu9JjyTiD4qyYXHb5eFPBEAppZ3/74obHnIN/Ck+7la0xdWteNYPBmDxmiv8GA
         VIB95xpR0zXzDiC/gZrtgvHZdYRMnVtL6jE19HPFo9Ci84df+8Le4SZruHfcZA3e0yY7
         v4PUaC7dP5KWQwutzZKrnsJkuMsB6ahG9dqv8temm6ShZxX+5/ITx85we4fAcJBwpx1f
         GAkA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW8HGf1zJQx6g1aLtTzCPg5oWI4oAMa5wQb50Y+YxJejj/s024m
	N+zndaaD8H3V58tuAnoNAM/ef3biuJWQe0XYZjR1E4oDP/PaljOyywHxDU/aOZne0gncul85Z1s
	KyKAO0oMlSBWPQp/NwJ/fBA7xbLi0n0qKMGben+hiQLabHPGA2CC4bnY8xV1j4DI/Cg==
X-Received: by 2002:a9d:57c4:: with SMTP id q4mr17720592oti.151.1554713627579;
        Mon, 08 Apr 2019 01:53:47 -0700 (PDT)
X-Received: by 2002:a9d:57c4:: with SMTP id q4mr17720549oti.151.1554713626614;
        Mon, 08 Apr 2019 01:53:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554713626; cv=none;
        d=google.com; s=arc-20160816;
        b=WCJXKZ5mvCMHSkS9r5GKOuwTLeED77lqgZwtyzQBpGyy5HkvrEssofT9mD4tyugHaA
         jISvhywUPmm/Q891kbYj20IUvAPPmygkGPrd2yjCJ4HQyW+xkWLVLt7V1qqetddaABJI
         k3xUN3V2ODJTr1sFPi2N/UZzzY98qWyxKKXHurfMCUVWqNUUEz1DBN4x67qdUtRqzgbw
         k2LqEh7uAme9tHbxoQ9cM3dcDkKcy4KTM3HkR92re3AobpyZS+bIXSDqVQy68E/izL2X
         k77ZXWUd49bE1BAF+duP/he8kaurjGNUzjQQtrFHqRpi/6UIWG0b6e7bBF25TGGeUoXt
         +Pbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=tv3xxipDSLiRgH4b3LyJ9t2U3T11OYsUY8ozdoYoEuE=;
        b=qXs8OXurK9btK2Oj9DhYWn+u0iIPvOKFmmJm7OBUQdhEFNYXuaXZSHxoaCCWiQqxQC
         KfSIqt720h56qUvKhwFEiHnUWd49m9LPENGtQrwpUebtrvsw5tgpfT0IR5oUAnhgTVET
         yZNuvXpMp385HXTDSIQE71IHWV9puU/x16Xiru1xme3D90J2dtNWYJemvi96LFVmpf08
         J94S0BNkSAUqfnW3D0NiyX8VbnDR9A1k2rE+doVzTa6AEFeijjupv1qZc/tBGeN4FzYh
         abHxsfznYnPIALpMUdBKyu8A1cpzTi+KlFV7tuHb2UT7F4fwnjVnVCwF3bVZ+mhLbuDl
         fr8g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y201sor16615200oie.29.2019.04.08.01.53.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Apr 2019 01:53:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwePke8F+WzS2PGVoDO7oUGCB0z8kx/GDfFUo+4YpVomYAkx5vq68UtvtvZvMbIHr7aFi4rrvXLl7gn875V/MI=
X-Received: by 2002:aca:f2c2:: with SMTP id q185mr16011157oih.147.1554713626054;
 Mon, 08 Apr 2019 01:53:46 -0700 (PDT)
MIME-Version: 1.0
References: <20190321131304.21618-1-agruenba@redhat.com> <20190328165104.GA21552@lst.de>
 <CAHc6FU49oBdo8mAq7hb1greR+B1C_Fpy5JU7RBHfRYACt1S4wA@mail.gmail.com> <20190407073213.GA9509@lst.de>
In-Reply-To: <20190407073213.GA9509@lst.de>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Mon, 8 Apr 2019 10:53:34 +0200
Message-ID: <CAHc6FU7kgm4OyrY-KRb8H2w6LDrWDSJ2p=UgZeeJ8YrHynKU2w@mail.gmail.com>
Subject: Re: gfs2 iomap dealock, IOMAP_F_UNBALANCED
To: Christoph Hellwig <hch@lst.de>
Cc: cluster-devel <cluster-devel@redhat.com>, Dave Chinner <david@fromorbit.com>, 
	Ross Lagerwall <ross.lagerwall@citrix.com>, Mark Syms <Mark.Syms@citrix.com>, 
	=?UTF-8?B?RWR3aW4gVMO2csO2aw==?= <edvin.torok@citrix.com>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 7 Apr 2019 at 09:32, Christoph Hellwig <hch@lst.de> wrote:
>
> [adding Jan and linux-mm]
>
> On Fri, Mar 29, 2019 at 11:13:00PM +0100, Andreas Gruenbacher wrote:
> > > But what is the requirement to do this in writeback context?  Can't
> > > we move it out into another context instead?
> >
> > Indeed, this isn't for data integrity in this case but because the
> > dirty limit is exceeded. What other context would you suggest to move
> > this to?
> >
> > (The iomap flag I've proposed would save us from getting into this
> > situation in the first place.)
>
> Your patch does two things:
>
>  - it only calls balance_dirty_pages_ratelimited once per write
>    operation instead of once per page.  In the past btrfs did
>    hacks like that, but IIRC they caused VM balancing issues.
>    That is why everyone now calls balance_dirty_pages_ratelimited
>    one per page.  If calling it at a coarse granularity would
>    be fine we should do it everywhere instead of just in gfs2
>    in journaled mode
>  - it artifically reduces the size of writes to a low value,
>    which I suspect is going to break real life application

Not quite, balance_dirty_pages_ratelimited is called from iomap_end,
so once per iomap mapping returned, not per write. (The first version
of this patch got that wrong by accident, but not the second.)

We can limit the size of the mappings returned just in that case. I'm
aware that there is a risk of balancing problems, I just don't have
any better ideas.

This is a problem all filesystems with data-journaling will have with
iomap, it's not that gfs2 is doing anything particularly stupid.

> So I really think we need to fix this properly.  And if that means
> that you can't make use of the iomap batching for gfs2 in journaled
> mode that is still a better option.

That would mean using the old-style, page-size allocations, and a
completely separate write path in that case. That would be quite a
nightmare.

> But I really think you need
> to look into the scope of your flush_log and figure out a good way
> to reduce that as solve the root cause.

We won't be able to do a log flush while another transaction is
active, but that's what's needed to clean dirty pages. iomap doesn't
allow us to put the block allocation into a separate transaction from
the page writes; for that, the opposite to the page_done hook would
probably be needed.

Thanks,
Andreas

