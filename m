Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C446C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 08:01:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1ADDA20855
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 08:01:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b="WX/hqQzf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1ADDA20855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=szeredi.hu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA2EF6B0005; Thu,  4 Apr 2019 04:01:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B53676B0006; Thu,  4 Apr 2019 04:01:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A418E6B0007; Thu,  4 Apr 2019 04:01:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 85E816B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 04:01:36 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id c17so1294861iot.6
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 01:01:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=tdJDlyHvzmVCG4+t5yoJd2yuhryUSl/550UFcR7PiYk=;
        b=k2h8G6hcF6QQc+kHRjcp2Q3LCj0ItfDa09GdPci1YvrwMpjYUXbef2WQ2dt9Gm8g8/
         qUMKcO30Z3WgQR79BBMcQfdch6/3bAoMyNjWup/LIyKnndY0K3qwqmZcGSQ6Recz1yLM
         QifX591tI0bErQ4txmZuFNOQrOMNZzcHApHAPSmpmmRyej8XpEucDhX+pQ/SGxvqoTYu
         1T6xGMOujgnq2QCHdUrmcBDgWzBfAy2wgqfAeKDZpZBeq92a53Jh7WVjjYWoabjh5z+v
         EuDnKM/tINBXR9SCHp9Y4rCvZeoChvbmeTmQXp+R7B+onusjnm8aO+J2JkV4PD6wq6YK
         7pwA==
X-Gm-Message-State: APjAAAWm8pF43+z6Lt+5s1Yo/Y2eb6i7TmcmI6BX3v5iH3zJS1qR1yBM
	bBu/htGJWMYQ/xmIUvgTZZAgiIYILe2J83N12gTXxrjjBFrqhva3M0gcNSB7wf9MDM9lqYvtD1E
	5Ar5ZtdLUi65gVgX9ui2YWrYWcHUhHARPxj2qXntiN4zdd/64NXiOXx6TvJlOE5ZFOQ==
X-Received: by 2002:a02:5143:: with SMTP id s64mr3891434jaa.54.1554364896110;
        Thu, 04 Apr 2019 01:01:36 -0700 (PDT)
X-Received: by 2002:a02:5143:: with SMTP id s64mr3891389jaa.54.1554364895327;
        Thu, 04 Apr 2019 01:01:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554364895; cv=none;
        d=google.com; s=arc-20160816;
        b=IUtjW6Ee2LnAyMmcRTXu2M1QQ/HzSwZe+X2+65uZdZakLVqxCywiZcupTuYqbVty65
         DSHahetFZZWqRZL/Sjlzm2By65GwBHxgWjRCEpjxjFeFzqh48yfOS4kqU4uAKV2w9MG9
         cfbATvJnpkJm2xJ/aK/aONxUf/qFldhMM/VIYqqGalzHxxdrR2Sy9EwBuXuo/XDRllzG
         BhV1h35krU7ESTAhCwFuSGujvALz5+DF+82RbmVsROetRw3EHeQ+F0tJYYjKAoi97Foi
         Qh03MHhXpZeMRnGM0yPGEl/Ue2QriNvybvrC4DzP6HrKlNo2qiJb9eVTUqkvUdoMf/ij
         Dpyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=tdJDlyHvzmVCG4+t5yoJd2yuhryUSl/550UFcR7PiYk=;
        b=rZlEvBjofsv9kfM/nbAGzmjFGy0TuZIS4p54xg9XD+o/SI46MvIsc1im21fntmgOU4
         d9Ec0wvVagMFVzOQNTx/H6jBpWEMgSSPZRN1pCBQSbYrolLzWuMmMlb8jopajRrb2zqa
         qTuqf1hO3xuyHtvrL/rSGdoJuhia++6hsEC0fWRhniCAkc/nSWaOY9pjOkBkHTBCboCk
         fVozPLp/qSYyKTK+tB8Fp1OzLrdwqae//YMYY9v/PAfI1NGyxfsKr9RVAX/svTHWXec5
         Q485KN13qKfVe5FHzhEupRa2HPEUpz35fjdw8iqoJnsBBiPuN5CSQQJHJRaKbb5yZMKn
         xJfg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=temperror (no key for signature) header.i=@szeredi.hu header.s=google header.b="WX/hqQzf";
       spf=pass (google.com: domain of miklos@szeredi.hu designates 209.85.220.65 as permitted sender) smtp.mailfrom=miklos@szeredi.hu
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c3sor32060684ita.15.2019.04.04.01.01.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Apr 2019 01:01:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of miklos@szeredi.hu designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=temperror (no key for signature) header.i=@szeredi.hu header.s=google header.b="WX/hqQzf";
       spf=pass (google.com: domain of miklos@szeredi.hu designates 209.85.220.65 as permitted sender) smtp.mailfrom=miklos@szeredi.hu
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=szeredi.hu; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=tdJDlyHvzmVCG4+t5yoJd2yuhryUSl/550UFcR7PiYk=;
        b=WX/hqQzfO+mK+nn/esSN14pxXKWwfDchWjNF0ahntG/CwHvSNFCMxSgl0/SCIg3AW0
         BIxbSfjZy/TrWmNZEIB58kTiYlZpKLJWSb7zoHnes2lFMobyu+qFBEkVIFhZYeNlX+vj
         0S35iTUl4uNXIEV4mBe3kXpGBOLo0Q+lbkDvw=
X-Google-Smtp-Source: APXvYqwqsJj7FYNRGkXzdlqhVlX0qlT8IrNnkVRl6yS81yiZB+Lems7LS7CwDCkeNoEN6Z+Y/am5SZlY2ub3FZWTsqY=
X-Received: by 2002:a24:c2c1:: with SMTP id i184mr3600474itg.82.1554364894463;
 Thu, 04 Apr 2019 01:01:34 -0700 (PDT)
MIME-Version: 1.0
References: <20190403042127.18755-1-tobin@kernel.org> <20190403042127.18755-15-tobin@kernel.org>
 <20190403170811.GR2217@ZenIV.linux.org.uk> <01000169e458534a-3c6a5d6f-3054-4c64-b5f9-7f46c811eeac-000000@email.amazonses.com>
 <20190403182454.GU2217@ZenIV.linux.org.uk> <20190403190520.GW2217@ZenIV.linux.org.uk>
In-Reply-To: <20190403190520.GW2217@ZenIV.linux.org.uk>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 4 Apr 2019 10:01:23 +0200
Message-ID: <CAJfpegsn8trCjTgah5yoPA=QSH-CDngKMu_+pta9aeGQhxxV=g@mail.gmail.com>
Subject: Re: [RFC PATCH v2 14/14] dcache: Implement object migration
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Christopher Lameter <cl@linux.com>, "Tobin C. Harding" <tobin@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
	Alexander Viro <viro@ftp.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, 
	Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthew Wilcox <willy@infradead.org>, 
	Miklos Szeredi <mszeredi@redhat.com>, Andreas Dilger <adilger@dilger.ca>, 
	Waiman Long <longman@redhat.com>, Tycho Andersen <tycho@tycho.ws>, "Theodore Ts'o" <tytso@mit.edu>, 
	Andi Kleen <ak@linux.intel.com>, David Chinner <david@fromorbit.com>, 
	Nick Piggin <npiggin@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, 
	linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 3, 2019 at 9:05 PM Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> On Wed, Apr 03, 2019 at 07:24:54PM +0100, Al Viro wrote:
>
> > If by "how to do it right" you mean "expedit kicking out something with
> > non-zero refcount" - there's no way to do that.  Nothing even remotely
> > sane.
> >
> > If you mean "kick out everything in this page with zero refcount" - that
> > can be done (see further in the thread).
> >
> > Look, dentries and inodes are really, really not relocatable.  If they
> > can be evicted by memory pressure - sure, we can do that for a given
> > set (e.g. "everything in that page").  But that's it - if memory
> > pressure would _not_ get rid of that one, there's nothing to be done.
> > Again, all VM can do is to simulate shrinker hitting hard on given
> > bunch (rather than buggering the entire cache).  If filesystem (or
> > something in VFS) says "it's busy", it bloody well _is_ busy and
> > won't be going away until it ceases to be such.
>
> FWIW, some theory: the only kind of long-term reference that can
> be killed off by memory pressure is that from child to parent.
> Anything else (e.g. an opened file, current directory, mountpoint,
> etc.) is out of limits - it either won't be going away until
> the thing is not pinned anymore (close, chdir, etc.) *or*
> it really shouldn't be ("VM wants this mountpoint dentry freed,
> so just dissolve the mount" is a bloody bad idea for obvious
> reasons).

Well, theoretically we could do two levels of references, where the
long term reference is stable and contains an rcu protected unstable
reference to the real object.   In the likely case when only read-only
access to the object is needed (d_lookup) then the cost is an extra
dereference and the associated additional cache usage.  If read-write
access is needed to object, then extra locking is needed to protect
against concurrent migration.  So there's non-trivial cost in addition
to the added complexity, and I don't see it actually making sense in
practice.   But maybe someone can expand this idea to something
practicable...

Thanks,
Miklos

