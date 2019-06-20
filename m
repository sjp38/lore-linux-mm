Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83F93C48BE1
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 21:29:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4AAD02070B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 21:29:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="KvOr4Sp+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AAD02070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B94146B0005; Thu, 20 Jun 2019 17:29:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1CA08E0002; Thu, 20 Jun 2019 17:29:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9964A8E0001; Thu, 20 Jun 2019 17:29:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4AC016B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 17:29:40 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i9so6015042edr.13
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 14:29:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to;
        bh=v3IpD3zOAyT/o3jFLveqYdHxVLapPS/YFt6LidFqVKU=;
        b=SdJ5zvQm5a8M6EFHI9Olx2ntAA7q8rGeGnszq2QemnBKJo+vkP4Qzg2XTpUw1trv2r
         2l0q+qtvwAHFvrqQCcLryzyZM4u1B0qZDeizP7ADINrtQsOTQAHHzkZpANds1yx7Bmww
         Lz6adhdP5GpKlHUJ8thVdKDt4rf+gpZf3cPGFWhwM0s3FOEbwA4czG1RMo4oMr8Xqe14
         GIoPseyYvJY0K1/TYG9my6BhT6yK6JAXneIZRYd4+2Twdnuc7tjRl6sd0og2cCqx0kpL
         xvbOMClKF4yoEPhfHr1fI49+QdOZoPcISI0xS1YSXFdUAL+DFjdnnMXYEdWHrHiDyjip
         ITkQ==
X-Gm-Message-State: APjAAAX9mWSDAeVcXdO/tf0ppN2ms3GP4DhwVqAaZCH6KTgazatYdTOV
	MJA95YJgAsmXG/Zbm9hBu0KMSc3OII6SmsUr6PUoKKlqjvKsxReK+aLOTxs7pCf8LFu9G8mZXkm
	tfBV2e8i8lyopq9RoOm7Jo1/qdeHdrZiIx78WK1abm/mXgsLR+dbI6WItYa5P4WRTxQ==
X-Received: by 2002:a17:906:2605:: with SMTP id h5mr86965592ejc.178.1561066179863;
        Thu, 20 Jun 2019 14:29:39 -0700 (PDT)
X-Received: by 2002:a17:906:2605:: with SMTP id h5mr86965565ejc.178.1561066179215;
        Thu, 20 Jun 2019 14:29:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561066179; cv=none;
        d=google.com; s=arc-20160816;
        b=yLwpWN9Bj/l7M5ICLpq7IqitgHTEKmxKh3N8A7dDcbklYYje/e0jnpbjdX34jIRYz3
         LSy37E6JOH/k5IQs9u2L0f6W88ICWOFftHSs8EYIFGLtmzIe3G7gNf7sJg9sxtg445LB
         pdw0ihv5XkH2QWv3how39gy/VNeZSas9k2sStF9vGtxDE4Skw0771W2PRGf1T+6aETGX
         ujKsz99T6fPYQoCCJIXYCMfP6ZRS06C0Wup2lrfz5Yac8TmI09ob8jC00AA0XaHO1cnE
         7smhdrJAa69FJJtcheTi/IxeLsi28qGMtxt57qythIz67eVq2tQM85lXWL9EyKq/jidY
         q3+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:in-reply-to:references:mime-version
         :dkim-signature;
        bh=v3IpD3zOAyT/o3jFLveqYdHxVLapPS/YFt6LidFqVKU=;
        b=SKwaa30GYV8Qd6ziD5MDFQztxJLmPAZeiwrUWHE4WB5iGD7hlhCyVQCmQ5v39mYHC/
         Gyn+9A4juMP+Eki+Atl7BbqR8LUFji1GNl3OlEpfyVSZOS9Q96JvDAajBA3B7I92Prf2
         kSx+C823/noDvJ/9yKSeBXYq+zSLIHY1uVY+o7Wp4AZF2q11eUVgjmxrc6NCw0yZmvzh
         1yV05SAllt23uzfqlNULigwFJ36+cF/vfP0NADMEslTDyX3oeCVnY8xJzHVA3bSMYgcn
         KZTqSYKJevrwd/jbCjh5NIMwaO/doc4jObXhthfdUzK734Ks5k9UM6KqC2Ih5R1R8nJe
         Ja6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=KvOr4Sp+;
       spf=pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p15sor313327ejr.10.2019.06.20.14.29.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 14:29:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=KvOr4Sp+;
       spf=pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to;
        bh=v3IpD3zOAyT/o3jFLveqYdHxVLapPS/YFt6LidFqVKU=;
        b=KvOr4Sp+Id3A6XKZfDq0jaToh9hTpDvR4uHERHTmM5jYRInzJr41kiC9SoOmmDJhky
         oWXqPY/lKaIz9THmlD7IH7YFcmC3tZDq/MG8PgXKGCf9XHFgOdbfcOfRn1VFfw/TeOoP
         bFK/Xo6W9HJHbqyCJAlgYtMGuDNKG7dFjc43Q=
X-Google-Smtp-Source: APXvYqxH8N7gZu/J+S62Ravhdxjgpq9+ykbmaOmCuTGIRirwxuf5ibuiv2SvStR/J1qvrYRS2BOpzA==
X-Received: by 2002:a17:906:e994:: with SMTP id ka20mr3905136ejb.264.1561066178511;
        Thu, 20 Jun 2019 14:29:38 -0700 (PDT)
Received: from mail-ed1-f42.google.com (mail-ed1-f42.google.com. [209.85.208.42])
        by smtp.gmail.com with ESMTPSA id j30sm208722edb.8.2019.06.20.14.29.36
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 14:29:37 -0700 (PDT)
Received: by mail-ed1-f42.google.com with SMTP id a14so6683411edv.12
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 14:29:36 -0700 (PDT)
X-Received: by 2002:a17:906:b315:: with SMTP id n21mr8174762ejz.312.1561066175899;
 Thu, 20 Jun 2019 14:29:35 -0700 (PDT)
MIME-Version: 1.0
References: <20190620151839.195506-1-zwisler@google.com> <20190620151839.195506-3-zwisler@google.com>
 <20190620212517.GC4650@mit.edu>
In-Reply-To: <20190620212517.GC4650@mit.edu>
From: Ross Zwisler <zwisler@chromium.org>
Date: Thu, 20 Jun 2019 15:29:24 -0600
X-Gmail-Original-Message-ID: <CAGRrVHw8LuMT7eTnJ4VV9OpnetSSYaLh5nLkN4Anevz6r8KmZA@mail.gmail.com>
Message-ID: <CAGRrVHw8LuMT7eTnJ4VV9OpnetSSYaLh5nLkN4Anevz6r8KmZA@mail.gmail.com>
Subject: Re: [PATCH v2 2/3] jbd2: introduce jbd2_inode dirty range scoping
To: "Theodore Ts'o" <tytso@mit.edu>, Ross Zwisler <zwisler@chromium.org>, linux-kernel@vger.kernel.org, 
	Ross Zwisler <zwisler@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, 
	Fletcher Woodruff <fletcherw@google.com>, Justin TerAvest <teravest@google.com>, Jan Kara <jack@suse.cz>, 
	stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 3:25 PM Theodore Ts'o <tytso@mit.edu> wrote:
> On Thu, Jun 20, 2019 at 09:18:38AM -0600, Ross Zwisler wrote:
> > diff --git a/include/linux/jbd2.h b/include/linux/jbd2.h
> > index 5c04181b7c6d8..0e0393e7f41a4 100644
> > --- a/include/linux/jbd2.h
> > +++ b/include/linux/jbd2.h
> > @@ -1397,6 +1413,12 @@ extern int        jbd2_journal_force_commit(journal_t *);
> >  extern int      jbd2_journal_force_commit_nested(journal_t *);
> >  extern int      jbd2_journal_inode_add_write(handle_t *handle, struct jbd2_inode *inode);
> >  extern int      jbd2_journal_inode_add_wait(handle_t *handle, struct jbd2_inode *inode);
> > +extern int      jbd2_journal_inode_ranged_write(handle_t *handle,
> > +                     struct jbd2_inode *inode, loff_t start_byte,
> > +                     loff_t length);
> > +extern int      jbd2_journal_inode_ranged_wait(handle_t *handle,
> > +                     struct jbd2_inode *inode, loff_t start_byte,
> > +                     loff_t length);
> >  extern int      jbd2_journal_begin_ordered_truncate(journal_t *journal,
> >                               struct jbd2_inode *inode, loff_t new_size);
> >  extern void     jbd2_journal_init_jbd_inode(struct jbd2_inode *jinode, struct inode *inode);
>
> You're adding two new functions that are called from outside the jbd2
> subsystem.  To support compiling jbd2 as a module, we also need to add
> EXPORT_SYMBOL declarations for these two functions.
>
> I'll take care of this when applying this change.

Ah, yep, great catch.  Thanks!

