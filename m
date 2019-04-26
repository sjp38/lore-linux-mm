Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF25FC43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 18:08:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DF63208CA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 18:08:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="mM2gNYUi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DF63208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E3B86B000A; Fri, 26 Apr 2019 14:08:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 391446B000C; Fri, 26 Apr 2019 14:08:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A72E6B000D; Fri, 26 Apr 2019 14:08:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0D2186B000A
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 14:08:58 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id 73so3615994itl.2
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 11:08:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=KSDUm6zaly7/6QejATEjb8e1RQYiq+vEm5C7j7vxPK4=;
        b=L0K8KYtG6jiAd8G5gG7emmTpYTe2bGmVgm4YGXwftt1+PG52bD/gcSO7c4GNmGA9ds
         TuT+fjIlckeGHZpcAfLWQ+jMSCEOOetYSZYFy5pIsYvC+NjvMwQUwnWgrnDrZMFx9Ym0
         9xXeuZ04cd4ZjVU7xFX8ElgPlfdaF6yh1XBvaQvFkpH/rQJNf2ax8VCcGwA6v1jCNod7
         BfAYfNNemEgpZSqrJysXnWf016BYSxxFdmhI8IY4VKAf2VzmaImLblkuSO1kwQv5ADOG
         mBuFIAPmLoxfvmiCQ1hCSrsbaI9dLBippso4Fbx+apu+enHCizOOl1qj57b9FRVUrie7
         RBHg==
X-Gm-Message-State: APjAAAXWopjBz95/68ysp9fxFAXEOZVhb9RuvMeuc5a7TBjt06KXQpUA
	qBUgz9z8OZ95nVni1HOa1qy86GLv1OvyTC0LS8sWUBf+fbbsXCgum+8KkWbCnwx7qBBCmxkA2mZ
	Wq0mNp1sDPyaF3Y9o3QYtBrHOUCIqRsFn23ZwDsiz4WYRgYVf4kDXpVNn5DL+uO78Mg==
X-Received: by 2002:a05:660c:248:: with SMTP id t8mr1081617itk.162.1556302137763;
        Fri, 26 Apr 2019 11:08:57 -0700 (PDT)
X-Received: by 2002:a05:660c:248:: with SMTP id t8mr1081579itk.162.1556302137192;
        Fri, 26 Apr 2019 11:08:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556302137; cv=none;
        d=google.com; s=arc-20160816;
        b=V3pwGFY8tWWdw4f6hMOxACDY3qYSDa0IUG4rl6tOgvS7ogCtNBr4HrLjn5FuB1h9IZ
         h6YR9sFM3kvupU7bCxFjWRSKjoZQk5GX9nhacwjYE/pnYcsrHL9gNPk5+YCcu2xv55+5
         TlxS1UDSRPyhVWTceiA5a6Wo7EJSTV5vbtIh6he/j5o/V+GxrGqHbwbOIZXiF25OK78+
         cAl+Yw87vPtzmYy2e9WUWvjr8xAalK56vlotQCR8C8EOqgz+fOOObH8u6bss0Iy68UZB
         qLafEz/aq7eRF2+Ru61Hm5fokZxAH54j7RblIq0WYrgIey5TWCQ5XkP5F7YWqi+BLKAH
         N7/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=KSDUm6zaly7/6QejATEjb8e1RQYiq+vEm5C7j7vxPK4=;
        b=biJOu++4mwoa45uVmcyT+Yaf6LfIEkKaYKLpK97TqhpPa3YeNv6DToPYjcrtmupUHR
         PcAj5funpEf6TAqci+TTnjcQcCa95HqdhP0uDI4/jG4EV7SzMu80d8zvvucEeh06wM2Q
         wQmU0BcGlazevGbbjvxZ9SK4uqVf8cSlfMW7xXQbcxbSfY0QqtnJCFnQAlkZHNEKJtHn
         2T0p+uhFfuuPViOxGrB1sOwHc3iRJFl+/oVPOnE4yCc/PM5A5rzgj2LqkRiikKtUs7jI
         L1F8qbczEFfJOkm7e5ic5bcUnZTlG3mDUmImHpS+REBndmTU2Fve957OZEBRlfBEqNfv
         jNPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mM2gNYUi;
       spf=pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matthewgarrett@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w14sor18253253ita.13.2019.04.26.11.08.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 11:08:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mM2gNYUi;
       spf=pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matthewgarrett@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=KSDUm6zaly7/6QejATEjb8e1RQYiq+vEm5C7j7vxPK4=;
        b=mM2gNYUi/70Hohs3RgWqrz/IAXrbekJ+xfzhbMuc83HLnonIIOAND8fNLzPeKY7OuX
         zTZ2ysZFPHaq/GVmztzTKZpMaUVgb/a2UKfMV7n9uNEsnfJJpnoOIlObqAPabtxxM5BF
         8EkrQ4g60BXzRK3XIivpMG6AUJWmUF7YNBMjXBlwvXzDninFtVk7kcZROUswKjpscx+S
         k8FmnA06rbRfLjsHTVczdHxUFYFcdvCgt3MOHEPjiL0iwEqb+kqxeS6AyPfeUJFAeoEj
         BwKjLi7+5pGLTI/Pt+0JEphCU0qFdZ0G0ONukVUui6NTbN0xkLJtSGm7UZbKvqf0UVBw
         kAxA==
X-Google-Smtp-Source: APXvYqx1qt1n85QyABwVrqqSHtIju7qNaLOVL6vf8Pqs1UiBmO+nbB9VvzxmxR7qT0ggofA6H7kWVyqXfSIUdYPiYTE=
X-Received: by 2002:a24:eb04:: with SMTP id h4mr7779231itj.16.1556302136456;
 Fri, 26 Apr 2019 11:08:56 -0700 (PDT)
MIME-Version: 1.0
References: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
 <20190424211038.204001-1-matthewgarrett@google.com> <20190425121410.GC1144@dhcp22.suse.cz>
 <20190425123755.GX12751@dhcp22.suse.cz> <CACdnJuutwmBn_ASY1N1+ZK8g4MbpjTnUYbarR+CPhC5BAy0oZA@mail.gmail.com>
 <20190426052520.GB12337@dhcp22.suse.cz>
In-Reply-To: <20190426052520.GB12337@dhcp22.suse.cz>
From: Matthew Garrett <mjg59@google.com>
Date: Fri, 26 Apr 2019 11:08:44 -0700
Message-ID: <CACdnJutweLKsir_r9EgP9g=Eih-hbhq20N8zHzKawR8=awnENw@mail.gmail.com>
Subject: Re: [PATCH V2] mm: Allow userland to request that the kernel clear
 memory on release
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 10:25 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 25-04-19 13:39:01, Matthew Garrett wrote:
> > Yes, given MADV_DONTDUMP doesn't imply mlock I thought it'd be more
> > consistent to keep those independent.
>
> Do we want to fail madvise call on VMAs that are not mlocked then? What
> if the munlock happens later after the madvise is called?

I'm not sure if it's strictly necessary. We already have various
combinations of features that only make sense when used together and
which can be undermined by later actions. I can see the appeal of
designing this in a way that makes it harder to misuse, but is that
worth additional implementation complexity?

