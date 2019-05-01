Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D258AC004C9
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 17:00:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91B4C20835
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 17:00:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="c9cRJ1QZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91B4C20835
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16F796B0003; Wed,  1 May 2019 13:00:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FA3E6B0005; Wed,  1 May 2019 13:00:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDB9F6B0006; Wed,  1 May 2019 13:00:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id C48736B0003
	for <linux-mm@kvack.org>; Wed,  1 May 2019 13:00:23 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id 2so3222192vsp.23
        for <linux-mm@kvack.org>; Wed, 01 May 2019 10:00:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=fKeHm+YnMFQhnE5COYYd2wTHTYE5yGwHo3lDdnebjM4=;
        b=fFbOF36+RjKhFUAf1id/dhGmxyzzSgAAYUBOND5CaTHAoOPrkdh1ilxfdJAidZc8Vh
         HPYPUHjc6uw38sEl5x6MTiyYPKnQY9U15tyufZVYl6ct1L2p8Cb6nHGW9v+l3smLWk7C
         h0ZnB1U5vNs6EGFN5BT7tIsqZ8vwCgXp0tbKp9fgegB0a2ygaUhvA2gy73IemhO0mNM3
         EeYFPy6v8wXEjABLbooYUBieYfLWWqlVYJ+idK1iuTUa63VWyNQJNniaXMQpwElkXPPF
         gb089zX9qDVTFeinpdhjT5Bd2f8T8GcYxx06nPGW91vj91nZHMAxbLImJSv9wceH+lyh
         FSLw==
X-Gm-Message-State: APjAAAUlBlFeZDzGLsVsogLC+c7zt5WkVgMPM6wc8Uzrg8brDKypMANF
	AJOAN//fuptTP8e3Gua6rBFW+rNUKtmofo71Ms0bzBb8Bb20K2ywMtUU1/9iOoFNAil/Y7Fopa1
	cI7DAzR+juOli+OumtB4+hP97cTTWHMg/Mg/aKp+cIj71EZEb+KDB06LsSsvAr+Se+g==
X-Received: by 2002:ab0:6309:: with SMTP id a9mr1365142uap.35.1556730023415;
        Wed, 01 May 2019 10:00:23 -0700 (PDT)
X-Received: by 2002:ab0:6309:: with SMTP id a9mr1365081uap.35.1556730022593;
        Wed, 01 May 2019 10:00:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556730022; cv=none;
        d=google.com; s=arc-20160816;
        b=D1EUkWb4dU/mt81/vG8/AvEVVNyt0Rl8GDOG46151ktrUQDfBRNZgkRKOweVlZddr+
         R2MlxS1bqMe9ya4bR1UhWLLHfW3m6HkV9YJybZmcQ21eo7dqI8Sflt9Jk+TsiCDyOW9+
         S7xqiZ6FM9tYULv4RiDQyr7Udu3mTW5GYHR7j/qyFmgJwUwPcGbYVYswzDNPNuhpXiBQ
         dZk1/jjw6QlZg0AxxodBD7nrE1zVwyqvmH+MqqhO1kGHhGBiFRaw0S6ZojRx2JKsQvYG
         HgKJAeBi0J6KvOnGOr2UWMp3vlVUZO8JPH5x8teNYnKsGU2wjky8BeGaGpgvxEsleHBy
         qiJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=fKeHm+YnMFQhnE5COYYd2wTHTYE5yGwHo3lDdnebjM4=;
        b=Jww1aNXySX1Y2otsjM5ULyOkfZUU6ZCnKMo3uPIOZIrgoeN6WKotSHYrJHgTUA+CtT
         C9jrqV2hI8QuTovUmXjAZYas6qvNE/rVnCyUScqZ5OOjxCYedSs/zGi+XiRQelg5CWCp
         t+ebT27NopoN6EZqGuR79rY4AjWGjUpqyOxow/Bv9oXW00xfFNnc5csHvJ14coxgsCAa
         aPj58D4nKphWQT1ihgyS8kr9U2YwdtzBxVeegwoNHTG4GgA38PhA1VooH3WnbTfst97i
         010zvao1mi+ST4StZHEGWvx6EeECKI9ggVn6M8i/qOOzk0Dzjy59ZroNr7mkti/CLW41
         fxZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=c9cRJ1QZ;
       spf=pass (google.com: domain of samitolvanen@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=samitolvanen@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i25sor4115658vsk.59.2019.05.01.10.00.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 May 2019 10:00:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of samitolvanen@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=c9cRJ1QZ;
       spf=pass (google.com: domain of samitolvanen@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=samitolvanen@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=fKeHm+YnMFQhnE5COYYd2wTHTYE5yGwHo3lDdnebjM4=;
        b=c9cRJ1QZQtCO0/mYbd0/5i4CUar4BNukWTS+G7jpwqDiNzZNV1I2edB+dOMbqXzfQN
         mhW68V4DfHLuHMdUGgFuw3BtCW6wAMRLTGARVl9g24jKKOObBPLzumTeE6Ku3J/zC/Rs
         3kKoRtXLz+OH40U9zaDIKNjnYtAm3sAsF9MfgJr3YB/1AReKlm/skRORZDQ9HVlkxL+f
         zJz1f4+jYMAYy/PU6bHdIuWRtCw1kB8ks9BemTUwcrrGzu34XCiyKAqYhPCuMUja77PS
         L1YKR17HUUy1neMNs0cNdR37rpUDpDaPudaVB9kgFJZXXZ1cWQBxdLvqV5CVr3BdlKhF
         liLw==
X-Google-Smtp-Source: APXvYqyUqlL9jpVL90DkvvlHC4IlULAcsEjfbXtupVrOhb+mGnoHYGwhZSQ0zSjaCUnEraTNpHXEENzrDsXLSmJMKA0=
X-Received: by 2002:a67:7444:: with SMTP id p65mr38135332vsc.104.1556730021507;
 Wed, 01 May 2019 10:00:21 -0700 (PDT)
MIME-Version: 1.0
References: <20190501160636.30841-1-hch@lst.de>
In-Reply-To: <20190501160636.30841-1-hch@lst.de>
From: Sami Tolvanen <samitolvanen@google.com>
Date: Wed, 1 May 2019 10:00:10 -0700
Message-ID: <CABCJKudfkFB4QGp4J6E5r2Td+Wqw0dTYfMZkxVh9DgR7N=JwyA@mail.gmail.com>
Subject: Re: fix filler_t callback type mismatches
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, 
	Nick Desaulniers <ndesaulniers@google.com>, linux-mtd@lists.infradead.org, 
	linux-nfs@vger.kernel.org, linux-mm@kvack.org, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 1, 2019 at 9:07 AM Christoph Hellwig <hch@lst.de> wrote:
>
> Casting mapping->a_ops->readpage to filler_t causes an indirect call
> type mismatch with Control-Flow Integrity checking. This change fixes
> the mismatch in read_cache_page_gfp and read_mapping_page by adding
> using a NULL filler argument as an indication to call ->readpage
> directly, and by passing the right parameter callbacks in nfs and jffs2.
>

Thanks, Christoph! This looks much cleaner.

I tested the patches on a kernel compiled with clang's -fsanitize=cfi
and the fixes look good to me. However, you missed one more type
mismatch in v9fs_vfs_readpages (fs/9p/vfs_addr.c). Could you please
add that one to the series too?

Sami

