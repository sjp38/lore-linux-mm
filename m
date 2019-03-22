Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFCC3C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 07:54:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A046620643
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 07:54:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RiGYw9vv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A046620643
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50AE56B0003; Fri, 22 Mar 2019 03:54:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B7186B0006; Fri, 22 Mar 2019 03:54:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A8BB6B0007; Fri, 22 Mar 2019 03:54:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id F00536B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 03:54:13 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id u194so188209wmf.6
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 00:54:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=F7KUXJQXMMpWqwjiUnhQK77Wg9oZd9i1uvNgz8BIdaw=;
        b=OcVmVD8BAhgCCv9wGHCFUOsIB1xy0BbO6pflqC/iERvRduqaeG4D1gFjNeIyHJASKi
         j5jppuKjIL65UkmaByeH4hD0LdZk/kP5NLfO5et2dxqLhvo4rG7zdGggXFiIpLizvOHA
         VzXtZnd9R072fGaxqxNrB/icId9zDGog3QN5fjKSg8mbQ9KS13AY7EQNx6Xg8aPMplsP
         qj9+EK3ZmhorChTwkD3Gi6GM6PjOfS6VevSwf+x3NpK/EPVFePdWtOeiRcCYd6KxMTCO
         Z3fvLkpg+YyCXlM3I3a9/ZkOMUfF7HNen/FykT50KTuCY9ZxAgU/CVaNuGlspQToSaqQ
         N6iA==
X-Gm-Message-State: APjAAAWJdh/xux/1z69HWzju7TFFSDYgfL+rdZEN+ZdBCzpGXjHQN0lX
	sXzAlD8BaD6k3CBxL/xHWQltTdgacD243geULkOFMUnWMC0ke+w4NWYzbak7eggRSfF934BKevN
	SnkpM4p8ibpB+zY/07ch6k9alC+mjx6wxK56568KfWrANW19FytjcUPLhN0gHyIzs7g==
X-Received: by 2002:a1c:e910:: with SMTP id q16mr2172128wmc.30.1553241253498;
        Fri, 22 Mar 2019 00:54:13 -0700 (PDT)
X-Received: by 2002:a1c:e910:: with SMTP id q16mr2172096wmc.30.1553241252746;
        Fri, 22 Mar 2019 00:54:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553241252; cv=none;
        d=google.com; s=arc-20160816;
        b=gqXKlaYSyrIedPxi+JDm1a5jCjpIMK8z728IeZTp8DnrCclt06sNd9qb1KbqW4Kqa8
         E9t+6C15P/CCS7hJamBXJe1gYVhYgN6Kv4aT4CvWT0kXzJE7GJvJJ6GQAytXDWtpx7J1
         QlGdJg02ddGYrCmkmNyO4EQvBsZeJerMZupZtT/DPcOXbSqjxX3GQBWTwH81ghhTCbhD
         Bkbzo3HH03RDIui7K+hlGqnwBeW8qqyc9vrI+kjW2haZhhiVMM/AdU8S46DuKuKcz2im
         SHbHKQ9nlc8RYE+o3G6UJKYBYpqwkukonPJwdVlm84jpLLdSZTzjVrPhkqPmuuhnTz6y
         DvOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=F7KUXJQXMMpWqwjiUnhQK77Wg9oZd9i1uvNgz8BIdaw=;
        b=bvrb07aAlrskp+GG9sjDQcGHnTZjnyzWDQuOnROEm4NxSPFakGgxbVnxOYysTFmuLT
         eeQGSyojKhrQ90d6ZNzN2IK/GlochoSAFxW6C+BtwMqf7aJEGYiQV+KkPhXr/HW/9JV4
         C5+LhzAbFEqrc10sU7fstjED6GSsaIEGIVMEW+ukrkYVJysY9f1aodruZUmOEaJGa/BB
         Ju6aT7WFb7ZU1cgYRfPf3DXPRpa76YV9naaJzU68As9HmTtWQnh/WGVdYRbS0WprzoJ3
         73X4WmutO6rOfAqL5tKo6lhddhTbqq3jk/tOJ5eESCWq/N12EJEZYHE9jJCS8MOajcmS
         nICg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RiGYw9vv;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g9sor5769122wrm.40.2019.03.22.00.54.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Mar 2019 00:54:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RiGYw9vv;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=F7KUXJQXMMpWqwjiUnhQK77Wg9oZd9i1uvNgz8BIdaw=;
        b=RiGYw9vvsIqjDTy9J8wTVwZiM38WTpxsiuxLeEKdaAEGh5ASot3Kk7ONobn0RkCdrm
         vypMXNfsoarjRBTYoTtn9CyFTwHIVUuEkf4ytku6THfemTY9v/s9jg+B4HiRPr2wjsG8
         b7DDNi1/EZ+VcFAZVXNLzyMJGpc5q6daFIDJ46S9KrlJJROfQcYuEbpYAfDnADPN7GMc
         J+Y1dYwBYy7VJ/IlRMXtFZuA851n4KPTV7llS56UcdpicB7qNQnqW9MVfaLFDRYYej+y
         D3t3KrziUdFn/fcO1BVA/DGBwzD8GAQkR78mPcLFszP5OnvHykDjye5EwQlzS8BLax4H
         p5Mw==
X-Google-Smtp-Source: APXvYqyRBozLMEuSX6xqYmtWhVw9P0wTsiV7GzOP8/zkLRx71mN57k0jt1xO8ALcMEt96ju5LO+Ra2nh2pnYhQKC6W0=
X-Received: by 2002:adf:ea81:: with SMTP id s1mr5175568wrm.277.1553241252171;
 Fri, 22 Mar 2019 00:54:12 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
 <20190322073902.agfaoha233vi5dhu@d104.suse.de>
In-Reply-To: <20190322073902.agfaoha233vi5dhu@d104.suse.de>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Fri, 22 Mar 2019 12:54:01 +0500
Message-ID: <CABXGCsPXEAfYq3y58hMnXuctUm1D3Md=BpSo=cq5dR9+3aFzOg@mail.gmail.com>
Subject: Re: kernel BUG at include/linux/mm.h:1020!
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 22 Mar 2019 at 12:39, Oscar Salvador <osalvador@suse.de> wrote:
>
> do you happen to have your config at hand?
> Could you share it please?
>

https://pastebin.com/4idrLvJQ

--
Best Regards,
Mike Gavrilov.

