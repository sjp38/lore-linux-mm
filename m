Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCE21C04AA8
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 15:39:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8607221734
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 15:39:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8607221734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 214716B0006; Tue, 30 Apr 2019 11:39:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C4396B0008; Tue, 30 Apr 2019 11:39:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B3ED6B000A; Tue, 30 Apr 2019 11:39:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id D68246B0006
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 11:39:41 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id h26so3137075otm.19
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 08:39:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=jDm6QOW6C+ywZne3LW7Ypw7lAdQTfas17MrrXq3ecwo=;
        b=agGChrnimuc/JGBrFuXbWg749nUPX5EOQp2zmh+giH0/b4YwIeVPUCeqHNkb6BFvFa
         Lupe7rK9zs0TdPcLvfGPEJmidYDYU4oIZfvYO7c9qUC9a4Z+N9sgk5lXlnEbKbfiDPgE
         Bt8bw8efYV2FIg6q0mspqrY8N9aLuwyVjGmZzSAeGGGdTSSIUErFqoHSuikUpkx2f8vW
         OD3RJ9keXLRVenqh/CZVaN+/E62vr8nY5gyO1mAlMDy1zegAzI9oenLuGTH24Ohuwd8H
         GhaYAaAzG/SgBS8RVXd5p9+CRZtrHRfuvb5n2RFBLPtLNn2F5XIOsI9nr50BOWi+vaOf
         Lh3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVSKWbnOCLySUsmbfF7kPvjYNVfD+wdCP9M8s1EE0A5uezeEHoz
	VLW70V1UHXEu9UOR6/3vuEjVy59i937NM/rJBUhD6xt0PAhikwgFsqvRg7sEU76VTnmDcqtQBzx
	n+6LoQs2nRjXjThTBJnePV251EL/KtztPJ+tiLXtMnpCiV2L9twrp/GRArLzSWAx5uw==
X-Received: by 2002:aca:de45:: with SMTP id v66mr3235766oig.84.1556638781489;
        Tue, 30 Apr 2019 08:39:41 -0700 (PDT)
X-Received: by 2002:aca:de45:: with SMTP id v66mr3235738oig.84.1556638780793;
        Tue, 30 Apr 2019 08:39:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556638780; cv=none;
        d=google.com; s=arc-20160816;
        b=G7KzhBZ4cD0wvqdfcy3xOKVqnpiAFXtuLOFzpLAEqOwsBeHR8vuCvxmVHI3Gl2xhAv
         Pec3EJc6BwTf+EeSwASAD8fh+sx6w6xFGY2GNnl6QjGFmElRHUPAWMpq4v6nXTPmItnD
         2YNObZPkwJJMoOZDLPIGOlhR4ptg8V6l/7ImdWmAn8gOyghMjYh/QIzqg4pDbD//z9KP
         fMj6/D1yapQ6bTgKXcZkmSm0+rL5g0mytXbjemj/Kcx46ius6Rtvc5FebbKeQhKyFh56
         dTrnoFb3Ge/kXygcEx3okApoVA12JVfpaV83gOGiLFqTKuujWzkjn2PlRzz39eBo4+XC
         hHmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=jDm6QOW6C+ywZne3LW7Ypw7lAdQTfas17MrrXq3ecwo=;
        b=cg0TJGrXh78pWdkhjneFyUnHeO+5bGmGAYTrrB2EHxjbPcH9tasUW7wrAPAjLeQII6
         1RcABaiZmK2FVzQrD1tSAd0FlpapVg1UlnUinHiKUeYxvaJU0jqVq1NO12QbM5CbYXKp
         A5P163+KgbX0ydMH03MOuyme2BpYDD6z5xKjChFtCUgyrg/ju9F2TbfUBUxar1RkAwpz
         /elKJqMlaBycow+FX2UedNxeJITsNjw4lfa2yTrzZp1v6LPTNzkJzS7it/+0DezgbZM0
         iYBxQ6qAVhdYtEo2lndK0WPn1nMaFQlfqbK9NMbqXbgxbErgPXsj08zpZMYY8zsBPqln
         /YnA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p16sor4157389oto.172.2019.04.30.08.39.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 08:39:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqw8N8JoFFbtJVwle+z88rtJCuTvvxvCdMMXpDMhyN036qx9KAapBJJNOssCOcuQfUZoHwNGv9RcjuZWCQxY7v4=
X-Received: by 2002:a9d:7d06:: with SMTP id v6mr15700460otn.187.1556638779909;
 Tue, 30 Apr 2019 08:39:39 -0700 (PDT)
MIME-Version: 1.0
References: <20190429220934.10415-1-agruenba@redhat.com> <20190429220934.10415-6-agruenba@redhat.com>
 <20190430153256.GF5200@magnolia>
In-Reply-To: <20190430153256.GF5200@magnolia>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 30 Apr 2019 17:39:28 +0200
Message-ID: <CAHc6FU5hHFWeGM8+fhfaNs22cSG+wtuTKZcMMKbfeetg1CK4BQ@mail.gmail.com>
Subject: Re: [PATCH v7 5/5] gfs2: Fix iomap write page reclaim deadlock
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: cluster-devel <cluster-devel@redhat.com>, Christoph Hellwig <hch@lst.de>, 
	Bob Peterson <rpeterso@redhat.com>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, 
	Ross Lagerwall <ross.lagerwall@citrix.com>, Mark Syms <Mark.Syms@citrix.com>, 
	=?UTF-8?B?RWR3aW4gVMO2csO2aw==?= <edvin.torok@citrix.com>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Apr 2019 at 17:33, Darrick J. Wong <darrick.wong@oracle.com> wrote:
> On Tue, Apr 30, 2019 at 12:09:34AM +0200, Andreas Gruenbacher wrote:
> > Since commit 64bc06bb32ee ("gfs2: iomap buffered write support"), gfs2 is doing
> > buffered writes by starting a transaction in iomap_begin, writing a range of
> > pages, and ending that transaction in iomap_end.  This approach suffers from
> > two problems:
> >
> >   (1) Any allocations necessary for the write are done in iomap_begin, so when
> >   the data aren't journaled, there is no need for keeping the transaction open
> >   until iomap_end.
> >
> >   (2) Transactions keep the gfs2 log flush lock held.  When
> >   iomap_file_buffered_write calls balance_dirty_pages, this can end up calling
> >   gfs2_write_inode, which will try to flush the log.  This requires taking the
> >   log flush lock which is already held, resulting in a deadlock.
>
> /me wonders how holding the log flush lock doesn't seriously limit
> performance, but gfs2 isn't my fight so I'll set that aside and assume
> that a patch S-o-B'd by both maintainers is ok. :)

This only affects inline and journaled data, not standard writes, so
it's not quite as bad as it looks.

> How should we merge this patch #5?  It doesn't touch fs/iomap.c itself,
> so do you want me to pull it into the iomap branch along with the
> previous four patches?  That would be fine with me (and easier than a
> multi-tree merge mess)...

I'd prefer to get this merged via the gfs2 tree once the iomap fixes
have been pulled.

Thanks,
Andreas

