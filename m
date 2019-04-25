Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA6FAC43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:45:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A02C20717
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:45:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="MRWUNUxA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A02C20717
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1886D6B0003; Thu, 25 Apr 2019 16:45:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 135FE6B0005; Thu, 25 Apr 2019 16:45:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04D276B0006; Thu, 25 Apr 2019 16:45:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id DCC216B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 16:45:54 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id o197so828192ito.3
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:45:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=fTCIXrMkQw8DWjirY0wbyKHBu3z39INvewV6V58xb34=;
        b=JQHyNJX5PSaB7dSQaKfc2CqUPK0Hu4ha9DLfRCalj9jOuS1QXa4bZT2Rp2/0Zg2aPd
         cqSsgT6xBOlEU5R/ieSyHmEjP7ibJtNWfA2oeXnDJDutxR3FQ4kIj1Aqk+k2X5UJBNVX
         V1+gibGiuQbQLaddKpMPjdutjT4YaqVXjEuqaqDQ9cqBA3FbPMjBbC/Q9dBy3fGbwYxu
         iIYNQ61L2ap1R+PmrGmhGKp4lUKNwgtC/MThlT/itccfitF0bFXbPnoqyTxL/094Ot9s
         4xbh55GrU2FHtqn7hnX9JZjtm5IbcEGfOq/dtFXquTCrcadtH09uityCQRKLsQt8P+rR
         edVA==
X-Gm-Message-State: APjAAAWMPIG+CdJRi0f0sLybzYcWme388Ki/7sVg6ZzUoDCM+vA3XZRl
	jT33A/jViw9pVJRiq4/EhVvTj1e7YWs2g2QbD5Uyd/hprwuCMicKalfa1Xwjj+ATdXbpyZhprCc
	lzA0ppsNfMLUQQp+OhC0+TAu3ziUXO7mA+NbaP9OfH9lS6/vzpDQWwD6G1rbBjfeaOA==
X-Received: by 2002:a5d:9b97:: with SMTP id r23mr12106079iom.74.1556225154641;
        Thu, 25 Apr 2019 13:45:54 -0700 (PDT)
X-Received: by 2002:a5d:9b97:: with SMTP id r23mr12106059iom.74.1556225154147;
        Thu, 25 Apr 2019 13:45:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556225154; cv=none;
        d=google.com; s=arc-20160816;
        b=zVKIHTwCurnkUA4Rvkd/WMuO3zmmadcDf6p/VNx9tsCZYW/l/7pUqcFRBRLx3jdpQb
         W7MtJrzcN+nZwZBmpBhP7eyRZJHKyjDhRcRuUQ0vkgtSeoAdBD2uio38ZdSnK9PcUFfD
         FJ/RBhRrrqzCclrXQrmFNLXG3ouGdJ0bLRPM9SW7wyncw8Tt2/MQn8z1tVmAuDN7OVES
         dFD4w4plll+uVztPjP9VAAdO6y4W155tRCoh2bu2O19jCZv0WNa/Ivd+W7K+V62AkCHd
         dc/7FJF8R9Zq2UAuo6egNtzMUCUWp6TCLYMwDi4meDZzK5x0TpGcSfTxgweQLUg2OBCy
         Fw6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=fTCIXrMkQw8DWjirY0wbyKHBu3z39INvewV6V58xb34=;
        b=wRksDfqUdX7P5N14gig+3XSmX3FDJxschp8iYTiaj6BSJcQrs34FRohnp9OR/iWkNE
         A7qVjr2PFuLH6OhF6LwNImGvR7/hTurHrr0GcWvfmhSMRVo53viyeE+qD5MgPo88lvfw
         U5Wos4XVnOr7H6w0vYa2h0Tqjgv878jOaJ2o/IIxt8ILKmklnQ5zCs+zn8anZR30WBvB
         daJmpXfAf6XZwj13OvZXXa1u037JXRR4+P7ANoCPbizj7fUPszlNglMNcJrIRTuGSkbt
         BZeQHG5E5Y729eg3MM8xFV7Q3BEIP25YuEI22eZW/JfJwFKEiE1cLY8214uTT0zUZwf5
         KGJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MRWUNUxA;
       spf=pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matthewgarrett@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s25sor13307294iol.28.2019.04.25.13.45.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 13:45:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MRWUNUxA;
       spf=pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matthewgarrett@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=fTCIXrMkQw8DWjirY0wbyKHBu3z39INvewV6V58xb34=;
        b=MRWUNUxAgMtfjEUKh5EiicK3Gw8p3WkCwK0DaRezcQPhpuLx8df5emcz4NTK4E5D1o
         gAu0JkwLC+9tUT8zbS9e51olKa2jyblmviizLkXanyqOnYG93fxu/gElGFUGcmWOp/OB
         IfKtowKQ+80dsUp4qfifBulhtVIsPHSkOGGHLmB3TAgUTCkCcfBTt3ncKeByczcklw+c
         5YOVm2E0mHEqz+FQwKO+YAzhUkzxvF2dlEBEo0uyQ/CjOPgK7+JpfaFUw8R76QnHKmaX
         8u7U2ZhFNXvy/CCqKWdoRxpJjYhvxFtD4Ta/5Ij26a4vTAxBONBuPgh04ErsTEKhI/JX
         uHSA==
X-Google-Smtp-Source: APXvYqxXUTfVNIfA/fuKFQepO3/TNOnkhuDEVEZ0HByFbGB34orvrJ/gIzU17shHf9oBJnXNEcjKm3AfDav4RWXi5X0=
X-Received: by 2002:a6b:e20e:: with SMTP id z14mr24868217ioc.169.1556225153517;
 Thu, 25 Apr 2019 13:45:53 -0700 (PDT)
MIME-Version: 1.0
References: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
 <20190424211038.204001-1-matthewgarrett@google.com> <20190425121410.GC1144@dhcp22.suse.cz>
 <1df0ef0c-4219-c259-18a2-9abfb2782c08@suse.cz>
In-Reply-To: <1df0ef0c-4219-c259-18a2-9abfb2782c08@suse.cz>
From: Matthew Garrett <mjg59@google.com>
Date: Thu, 25 Apr 2019 13:45:42 -0700
Message-ID: <CACdnJuvU4jZJwtpcZq4_t+qujV3X_YLwo=FoDKoNmP74=z7Hng@mail.gmail.com>
Subject: Re: [PATCH V2] mm: Allow userland to request that the kernel clear
 memory on release
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 5:44 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 4/25/19 2:14 PM, Michal Hocko wrote:
> > Please cc linux-api for user visible API proposals (now done). Keep the
> > rest of the email intact for reference.
> >
> > On Wed 24-04-19 14:10:39, Matthew Garrett wrote:
> >> From: Matthew Garrett <mjg59@google.com>
> >>
> >> Applications that hold secrets and wish to avoid them leaking can use
> >> mlock() to prevent the page from being pushed out to swap and
> >> MADV_DONTDUMP to prevent it from being included in core dumps. Applications
>
> So, do we really need a new madvise() flag and VMA flag, or can we just
> infer this page clearing from mlock+MADV_DONTDUMP being both applied?

I think the combination would probably imply that this is the
behaviour you want, but I'm a little concerned about changing the
semantics given the corner cases described earlier in the thread. If
we can figure those out in a way that won't break any existing code, I
could buy this.

