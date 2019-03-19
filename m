Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1EFA6C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 02:29:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3E4020828
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 02:29:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MUFGUAJA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3E4020828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F7EE6B0007; Mon, 18 Mar 2019 22:29:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A6C66B0008; Mon, 18 Mar 2019 22:29:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BF0F6B000A; Mon, 18 Mar 2019 22:29:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id D8BEE6B0007
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 22:29:55 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id d12so1705772lfn.5
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 19:29:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=t9LeluuAwbLdhqLKYrLQeqJxgvFSi8zRhy1PLSOWg3I=;
        b=ho/6U2uBv+ytqnlUXuD7jO1YS+QpMNFF99eFngUn46cLmKlEmeikvPnA+U37wLAJI7
         YuI6byxurFtpLwKdvuK3EjcqhLthG4zkLIvHhzvt+On3awBu5O2Z+C/b83HTe+arHvEl
         IBgryOxoYPPj3QYv6JLCKt8IgythXgrT6HnvcOLd3nlOEZoD9dmCeDGdrNPBC4S3I0+4
         NxFXD7/Fz02FVAjePNJlhoy/NCzv1GeCQ4i3PaHRo8nIaT9Wo/Z+VjL3oKpJ5yjujFde
         h7wBp8hGEqbAj+4Yhas+ASXhjGh137l0denAwbvR1PSxQY3NtzZovtFSFixUjaJo+pLL
         eDzg==
X-Gm-Message-State: APjAAAVZr0gZ/q6iCeosupQbyWXpRa3DMbwVtIR3zSn6q7IpGd1eefvc
	lKf8vBR3QrEpV7Tc2vXvrnAyaowO4RkTwaGWB7HgDg5lpFEvxiDHSqbQyLADwzDNWlo2UyA/hNL
	hKFoG2ATDtX2ujuKRCGuwOIeAdXuBeGuMkTa8bvrIbeEmEuN/ZTjG1aTZjcMp08sL5w==
X-Received: by 2002:a19:7007:: with SMTP id h7mr11521287lfc.23.1552962594956;
        Mon, 18 Mar 2019 19:29:54 -0700 (PDT)
X-Received: by 2002:a19:7007:: with SMTP id h7mr11521263lfc.23.1552962594146;
        Mon, 18 Mar 2019 19:29:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552962594; cv=none;
        d=google.com; s=arc-20160816;
        b=fXJXxKFNLuQKlSjNrJf+TLe5wd49UgvwtPB39PnaCC5jX2R6QhHmIbycPuwnPssaKH
         TJj5LeqgN6rNKlDomxwlV4v+YEIlz3NVBI0qYIJZ5D5v65Q86J1MJO1dEcVWysgADmNe
         ZR3V6vOZ08vXOPHIBEbIT8cIYawkeAQCMZel34GYgMIyX/XCLKgWO1lYS6IZrNHk+v4R
         LbihPJpNocsXERXy/2GeDwfQBIYIfVkG5BWelnOU+46qZusxKkUU6pW/cCGD4YI60m0V
         Sz36NbICOCMxevv1Gerewn8S1Pb5VY5LPERvdWe9X93atQtL/rZETV7ddrC8mczAuyfD
         K3eA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=t9LeluuAwbLdhqLKYrLQeqJxgvFSi8zRhy1PLSOWg3I=;
        b=coSBk0BdAEZosH2AL6Y7R1DQm8/7Iz+ZFi63q9AhkHLrCQdPB4dn9+9MmnJxYzthJU
         eGgSM8J/Nzm9f4qNqA4cLRyQjf4MWSJVk5KGZV151B5YYpEwqS0nIaEOtBjHRW+hp1QF
         EeUO46IrJz6x7GHxkGdR2JDeDUnE7RjdIuiwDz+yShjQI+Mu7z84lvqWFPkaGMWPrtQU
         xDKdlWclrHbOODkFg4nRMfZl9XWdozPEnV6yKSBrdcNo2eHOtuvKeLe+I7gdG8gGYbT6
         5xJg74xHB/qi9P2UrjOsIS3fPAuiFH1tlqkqO46v6OAgaKvflRwd2X6YAIO8PlNU3598
         ADyA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=MUFGUAJA;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s2sor6419943ljg.14.2019.03.18.19.29.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 19:29:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=MUFGUAJA;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=t9LeluuAwbLdhqLKYrLQeqJxgvFSi8zRhy1PLSOWg3I=;
        b=MUFGUAJAl/zJoucy75Z3xPtEwYsA3nnr8nu3V/s7YNK7VD/HcTmcZGLwodlNVAkQj9
         X2Q0/0gM9y8qxFg+jjinDtvWD9oO1eLRRRaql73i9CtaS9pZSPHFSzStnCRcej3tHrRS
         gEwwyBLNZYt3bOaajqMqeOgWqQ5tXYVnkgjp5Y8V84ZBh15cihEoIlvsg0YER61WxGsw
         yMse9WUsVwQ0Hr7WhFyn1iBq68dgV0BlEg9FB0Rp8/VgmkDyqAtjo7mufoEzhgminBR6
         LdmhTXwmnVQ2mXybEaEb3BPoWOt2gY7X+b+6axfJIQuclT0XSKXUhRuEWDO8Byng+qju
         cagA==
X-Google-Smtp-Source: APXvYqyMNBOknG2i9I+qR+MgQA8ikKE9fRNsSolPoJmGJ499CeDc0Uj+pjoMPEgi1xfawlVpPq2FCybbiCZpKxkvEFo=
X-Received: by 2002:a2e:9916:: with SMTP id v22mr12140112lji.68.1552962593789;
 Mon, 18 Mar 2019 19:29:53 -0700 (PDT)
MIME-Version: 1.0
References: <20190318162604.GA31553@jordon-HP-15-Notebook-PC> <08a039da-6bc2-0da9-e83e-46cce6d7264b@oracle.com>
In-Reply-To: <08a039da-6bc2-0da9-e83e-46cce6d7264b@oracle.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 19 Mar 2019 08:04:19 +0530
Message-ID: <CAFqt6zah2hM1X5-TCsrGN6xVG+CYRygvMiZ98jBdSeepFqaSew@mail.gmail.com>
Subject: Re: [PATCH] include/linux/hugetlb.h: Convert to use vm_fault_t
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 5:47 AM Mike Kravetz <mike.kravetz@oracle.com> wrote:
>
>
> On 3/18/19 9:26 AM, Souptick Joarder wrote:
> > kbuild produces the below warning ->
> >
> > tree: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> > head:   5453a3df2a5eb49bc24615d4cf0d66b2aae05e5f
> > commit 3d3539018d2c ("mm: create the new vm_fault_t type")
> > reproduce:
> >         # apt-get install sparse
> >         git checkout 3d3539018d2cbd12e5af4a132636ee7fd8d43ef0
> >         make ARCH=x86_64 allmodconfig
> >         make C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__'
> >
> >>> mm/memory.c:3968:21: sparse: incorrect type in assignment (different
> >>> base types) @@    expected restricted vm_fault_t [usertype] ret @@
> >>> got e] ret @@
> >    mm/memory.c:3968:21:    expected restricted vm_fault_t [usertype] ret
> >    mm/memory.c:3968:21:    got int
> >
> > This patch will convert to return vm_fault_t type for hugetlb_fault()
> > when CONFIG_HUGETLB_PAGE =n.
> >
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
>
> Thanks for fixing this.
>
> The BUG() here and in several other places in this file is unnecessary
> and IMO should be cleaned up.  But that is beyond the scope of this fix.
> Added to my to do list.

I can clean it up if you are fine ;-)
>
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
> --
> Mike Kravetz

