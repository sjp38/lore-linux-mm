Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58708C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 20:22:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B31320835
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 20:22:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="aCxbrCuW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B31320835
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97C506B0005; Wed, 24 Apr 2019 16:22:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 901A06B0006; Wed, 24 Apr 2019 16:22:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A3826B0007; Wed, 24 Apr 2019 16:22:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2346B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 16:22:45 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id w1so4273345itk.4
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 13:22:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ltHpCvaDH0MdzUIEDOiPJEYuRRXip5WNmUSOIBLj3WA=;
        b=uLvou9cB7Zx5L4uA2cHnC72NM2IIIGrjHTW5/H0H1w8MTVLzpY7F0qv7rPDqUSTYtD
         pJLqwHGxpcgylizJQRPmeiUfgOiBGJU5eimnXhYfsuOvoEkWgo7zA5f59sAKDaQ05CRk
         dsBWpsFq7PYA4KzBp5jwlY7sUW9GBtEObyLJLazbk9Le9XVyiumY43RlesTzhCLW4Atu
         k10+NCe3tEN1cDrdrSUy1rkWH/OBjb+AWbj9tKxI/ulH3PVEYVoiOWxY6jEMu5UssAfj
         dX0XmmU7EogoK3UPv+ziQkKX5wv5fZadW97TrB4uLU7Y5CZqNneKB8iWVvsXXeftUUvm
         L1vw==
X-Gm-Message-State: APjAAAUQTO9iFe+eyXcp6dItUn3tC0t9lkgY5q1KvtA18HGywhW8axHu
	JtuFI4yP3ny2LWBOFsI3kTGyVct1brVIcRHG4Wit7OnMIWJgP6NzC9FSHLlbKi6I0bzt5jVfO+9
	gvnq4TvIaRQFTKy5ocMFblCDIapc4y8cEH92EDWvDjkumY1BmHgNaaQVwpNp0tOxINg==
X-Received: by 2002:a02:6307:: with SMTP id j7mr19685438jac.65.1556137365140;
        Wed, 24 Apr 2019 13:22:45 -0700 (PDT)
X-Received: by 2002:a02:6307:: with SMTP id j7mr19685381jac.65.1556137364450;
        Wed, 24 Apr 2019 13:22:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556137364; cv=none;
        d=google.com; s=arc-20160816;
        b=VtG8PeW+dpLpSWevedVumiZ6pIiJS8AwREwuY80A6gPRAiPudVwDiLTtAEx+oopwSS
         yr6yrxt0uJV5GIWso1j9E4xMkBBlOtMzvczAf72GZkE7TIYl+52cTn3TpjL9FNX5nJp7
         BcyytfmaRExF+R5eX4I0TypRMzWLX1K2vI3jywkUjpG2FLhTyF13dDUNHAz2RPH19Adc
         0iZw+7wbVv4yszbYaLVPReC0wfujCav0bh1y0mY1NAewf5F+V6us0TIZP7UR/7mfGL9l
         q2qzWmO+lvpA4hQIZ3bxgUd5XcYNzMdhVVXTH5rJ+93Yo+TP0I4hbxI2PmvC6yzBjXN6
         gscQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ltHpCvaDH0MdzUIEDOiPJEYuRRXip5WNmUSOIBLj3WA=;
        b=MV8DMLv5dPfIlXbpppRsoFC5P48yniKTGh5snMVBGOQYdQXkgCyITxvrEe0MAZJjv1
         fPouBKwxhw6Lqgftf9OPNLTTzBqLNGa43P2DjEh+F3OGLSRnGh+QWrxKzOBRjA5YZDhr
         Kw5d8xH/Hpfhxn6ow25gmSw9v64E6RS5wlng4aoLr7cD0prOoWjMtDnJA1tzEfFOX2Lz
         gAlqGlmvzYMio7lXxqdBlx+cje1sWcN5v+tDTVaPF9Wb63ACfq/FdO+L2NVgOw6Zbk7g
         9eNrORotGe6IduBwII/kk+GaKwBAKTBcw9ditcJqhky/ExD6O6PT4hqfZVgnJ9iq6Grh
         O3pg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=aCxbrCuW;
       spf=pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matthewgarrett@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l12sor4496673jaa.0.2019.04.24.13.22.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Apr 2019 13:22:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=aCxbrCuW;
       spf=pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matthewgarrett@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ltHpCvaDH0MdzUIEDOiPJEYuRRXip5WNmUSOIBLj3WA=;
        b=aCxbrCuWdkFAWtU99D3beSVgZBV29+mudc9bxwax85StrwLHtx55VSBHYXXmBRJPvp
         BcLXAO3KZFy33jffdX9Cc+LE7ErYbxncG/8rBWa60u0AMk5bZKzuauGJ/utyDSrRW3qK
         Mu2thUGdiMQa/Ce8UMZnyuiLjOYqjQXVEaap7N8+l2b2Oz0ZoRHz9qwLWYDHeyYLbKt9
         4GUTxtvIcufJcNSRvN2Gre+MCRlYbOPXIZLjXCsM2obfXFag/8G26D9Shh6jXcZlO+UC
         sOsd86pg294hODTTnP8ehCR4AuGMhgyIa74nNJ9Txy9KTu2PFcDvPgeSF0QHBmRMCHIM
         Sbkw==
X-Google-Smtp-Source: APXvYqwDIHdpqJZWC9/1e1j8c7MN7Q7ec24v/q7WYdAsy47RoI6XXcs7tJMSLCseUO1rJ0xxq4Gwz7aOUUkKd0Z3OJ0=
X-Received: by 2002:a02:ad07:: with SMTP id s7mr14136376jan.103.1556137363865;
 Wed, 24 Apr 2019 13:22:43 -0700 (PDT)
MIME-Version: 1.0
References: <20190424191440.170422-1-matthewgarrett@google.com>
 <20190424192812.GG19031@bombadil.infradead.org> <CACdnJutj4K1kQj7yXcCNVWM_hmrUwMfZ-JBi=FHkBvYFfbJNZA@mail.gmail.com>
 <20190424202006.GH19031@bombadil.infradead.org>
In-Reply-To: <20190424202006.GH19031@bombadil.infradead.org>
From: Matthew Garrett <mjg59@google.com>
Date: Wed, 24 Apr 2019 13:22:32 -0700
Message-ID: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
Subject: Re: [PATCH] mm: Allow userland to request that the kernel clear
 memory on release
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 1:20 PM Matthew Wilcox <willy@infradead.org> wrote:
> It depends on the semantics you want.  There's no legacy code to
> worry about here.  I was seeing this as the equivalent of an atexit()
> handler; userspace is saying "When this page is unmapped, zero it".
> So it doesn't matter that somebody else might be able to reference it --
> userspace could have zeroed it themselves.

Mm ok that seems reasonable. I'll rework with that in mind.

