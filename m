Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 331CDC31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 05:26:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E363C208E4
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 05:26:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="Y3HKJITK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E363C208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E06F8E0003; Tue, 18 Jun 2019 01:26:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 790EA8E0001; Tue, 18 Jun 2019 01:26:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6801D8E0003; Tue, 18 Jun 2019 01:26:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 320D88E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 01:26:58 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e16so9198258pga.4
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 22:26:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=KBk0vI4RQMrq25uWSdJ+2ep8omPhMVPkB3j/qaHLhoE=;
        b=jDD90gLAzP5mT2J6KLUVfwHcga3YadyHJq2Drku78r40UzDlnqAVtPJnRRwRqfasb/
         FJE2Y2trWv+7xTGcsHO3kW/+BT2zOjvgtnkn5H1IPZ2602jizUfvWLWju4YLzQDBPi74
         N1eiSbEM8k2uebpiBn+Ucbep+RrAbBHr6L7VH3DCicTfRF7ia2NjeRWGj6BT9wUpQ5AO
         2zOZnieUmzW9ecaXtQfiK+OZ5sJShG9KqoDfrRBkIsjmiOGeUVlH8A9fwi1U+EJx5pS0
         QVHqJOegGcQm8MM+JGc25OanjU30ElOcJKZS6Cbv5cBMZsrj6LzjQDmiMEzh3EAYozvY
         c+0g==
X-Gm-Message-State: APjAAAW9K5AOD5j4Lk/HcEsOOhrQW9A96F0nKY2WGBHRMIBp7ioRbuEh
	+D3w/FpxUEhFRVytFaoRIbrbx2gz9NeiyzHtng3dYG4ApvtASj+0lVl+voITlpBZ63tb8kDYzHu
	vXjZUc9NKNRAP6O2GSmb80CW6gmobGy8EiRjtHYac9yUNncrj4Q4jR8OUEYKhT89UUg==
X-Received: by 2002:a17:902:b091:: with SMTP id p17mr21656799plr.30.1560835617843;
        Mon, 17 Jun 2019 22:26:57 -0700 (PDT)
X-Received: by 2002:a17:902:b091:: with SMTP id p17mr21656776plr.30.1560835617300;
        Mon, 17 Jun 2019 22:26:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560835617; cv=none;
        d=google.com; s=arc-20160816;
        b=RswIn7YF7N4SeWYMUGbIef5H5B+tFoncfN3nJIlDk5C37pAcBXENsHkIGPZdYlVtTl
         7EFXhL5H9RC1N7R5kGHlFeZVp6MU+e29e8AFh/T8lDgr0nxbP93Ysk1w9C6P7Q7vDdW2
         hTVi2LGwdAmJVsx5b5cLOL0kAp5UIDWaKo1yH26613ccGkfaJ8qkPRyY3Ez3A2PGyKuH
         wqctZ9oaiDRP8Bwgr95iw3sH/ZfUMwNLPKE4g3SxbHLTqgMMZX5nJmD1VFAEkNJRm/PS
         xntk4U6F8iA/TVQcSieXheaX4Jyt2IFd8pXmmj59c4DlI+P9Si8lVyVjLmtm1VaLKmQm
         nT3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=KBk0vI4RQMrq25uWSdJ+2ep8omPhMVPkB3j/qaHLhoE=;
        b=COCn5Z1MwvnnCdNZcwgRZCJW0VvXnVFilThq+AkhVOQimTIQ3A8B4pGmwehk5M98/w
         VqVB9MZW12gTy1LiEg+qS5rrMV5/GbGs8xd7eGc9FIm28o6X+lScslNyg7y09KKks1gh
         tQnOt9kF2YMiUcKCrlQg2OecvhtodpRj3QrOuIue8DgdMp2wSBB4EUnvJ6mTAxOy1pLh
         9n8/IVWXTlvebncqUIdP2aK0rAB3wVKiCcX8zo8+QbRKBG+KsrWMvO/Fvp5vL7yq1jbr
         LBM28RLHXJLViEJmrT9lGIZ4YtT4p1uzV3Pg2pnibFBJBPa9sBGkLyNvy3W+LaBoxc7Z
         Zvog==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Y3HKJITK;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s25sor370572pgm.44.2019.06.17.22.26.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 22:26:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Y3HKJITK;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=KBk0vI4RQMrq25uWSdJ+2ep8omPhMVPkB3j/qaHLhoE=;
        b=Y3HKJITKouhlh1TaWa8IWuAVIdnIJ3wgmjU7crc90t1KDNlYYvSLwj18Z0zor9/CM7
         15NCMxEnt9WljXbe3UmAHttwdlrKLaCbiCPf0CFYydlVSL+a5h3Fnj5GWUqU2aBl0lft
         KhcoBYkCUzUb3OOk5cRxE9pLL16NEkLvSrj6I=
X-Google-Smtp-Source: APXvYqxsGDOAjuyeiUBQQfKlHRpkhzSzNh4pYCucZFBzZqr6L06keNW+FE4qiWVrESZjwyeODy5DBQ==
X-Received: by 2002:a63:1d1d:: with SMTP id d29mr956576pgd.259.1560835616920;
        Mon, 17 Jun 2019 22:26:56 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id q198sm18025478pfq.155.2019.06.17.22.26.55
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Jun 2019 22:26:56 -0700 (PDT)
Date: Mon, 17 Jun 2019 22:26:54 -0700
From: Kees Cook <keescook@chromium.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>,
	Christoph Lameter <cl@linux.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Michal Hocko <mhocko@kernel.org>, James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>,
	linux-mm@kvack.org, linux-security-module@vger.kernel.org,
	kernel-hardening@lists.openwall.com
Subject: Re: [PATCH v7 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-ID: <201906172225.4645462F1E@keescook>
References: <20190617151050.92663-1-glider@google.com>
 <20190617151050.92663-2-glider@google.com>
 <20190617151027.6422016d74a7dc4c7a562fc6@linux-foundation.org>
 <201906172157.8E88196@keescook>
 <20190617221932.7406c74b6a8114a406984b70@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617221932.7406c74b6a8114a406984b70@linux-foundation.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 10:19:32PM -0700, Andrew Morton wrote:
> On Mon, 17 Jun 2019 22:07:41 -0700 Kees Cook <keescook@chromium.org> wrote:
> 
> > This is expected to be on-by-default on Android and Chrome
> > OS. And it gives the opportunity for anyone else to use it under distros
> > too via the boot args. (The init_on_free feature is regularly requested
> > by folks where memory forensics is included in their thread models.)
> 
> Thanks.  I added the above to the changelog.  I assumed s/thread/threat/

Heh whoops, yes, "threat" was intended. Thanks! :)

-- 
Kees Cook

