Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCB8AC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 15:48:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55C92218A5
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 15:48:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="KGbrERFz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55C92218A5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A75356B0005; Thu, 21 Mar 2019 11:48:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FEC06B0006; Thu, 21 Mar 2019 11:48:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 877CC6B0007; Thu, 21 Mar 2019 11:48:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5E4FE6B0005
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 11:48:57 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id s87so20173269qks.23
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 08:48:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=o6wA8Xm3/KE1HlmA+afwuG/RDCWHkgLTSDA7aPPLpPM=;
        b=qaWniU9cWys5JaL1SS1Mmv/YIjfcZsHEhydIpLwUtg5swn7fPLgdKfWBdGNUt2NxXM
         of2gLvQK2pyVDTWwO87ZBu8sR3kETexQ6NjfrHtX4nAFVPONY43/fy4a8GFY2OMvloSf
         2R4PjvzCatHRk0MFnPaj+t3dw2KA7/KddxD19hkGan2mTmjMOn1dILs0MhJ9zbdO63NL
         mp3NndZ0Igr4EunzVKsLOqEwHKYCkiUA+QLgwfjKMK1VVnQJjdklZvJ35YhRZPRCEoUM
         xw/IXLQqumBsnvINuEfZYI+8SGW0jBhtXc5/85H4biv1+D9NcY8ZRJvox4MiotP2g9M1
         2NCA==
X-Gm-Message-State: APjAAAUc7/4aBNJXKDRd+V+xqlhdFpNHQIlLgZ2PSDowcTsnKJwLlx0X
	nuzEpjMXO/37vUmBsflfV61fVRML9rUebEI95HKBhfIOh+X9h24FJX8dNyZkjck/0r+zZpnJLji
	wPPsIuPQ820r1jcFx8sQMYBTk+rJIAN5jjgvWcVsw5Xn5qeGn41Ddd+ouzwMvlypcdA==
X-Received: by 2002:ac8:2195:: with SMTP id 21mr1812316qty.182.1553183337139;
        Thu, 21 Mar 2019 08:48:57 -0700 (PDT)
X-Received: by 2002:ac8:2195:: with SMTP id 21mr1812253qty.182.1553183336295;
        Thu, 21 Mar 2019 08:48:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553183336; cv=none;
        d=google.com; s=arc-20160816;
        b=FnRJvTDgtATRMOb4KhLIqNhDcnYioTic21mc+pDwuqlJgTtD/puy+Mi0TIbmzVP+/j
         0eat3YcWW9LFJNRFHRshvoNL+Gs9bkgAJw4+7uR4ElJhwSjIG/UJc8IffSaTf8p2ZRYE
         QZUZKx9TMylO1A4VE0FAv8hHHvwemxS3/o3RyJpLvzj5QZSHCVm3Ob7fJTYQgaA9I83m
         cWCNzspdGZWK46V9aIh32LFaVEvVhA2yC1llL3445nOyIkXt35XA6kL2bFdzKeDHZFi1
         7k9iYv4CSFvqHfd014vchMf686ai3CZ+kgcvFTBSHD9A7esBA3ya8H+eMzNUhV2PQ1yC
         /3PQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=o6wA8Xm3/KE1HlmA+afwuG/RDCWHkgLTSDA7aPPLpPM=;
        b=bDrSWVETxcsjxnCf3KwhjH6XfCliUin6CXWlbVwk54gmwPYRdX27urgU4nHxmqwwc/
         S1NJ5R49kktxRkg14axQErnPl6AF3pG9ftO1qrqAm/gMZRHgoUKDx3ZnspHDWl2Ii9CA
         8cAjnYk+LCMNG+q3oAVV0U3zMW8JfISuTaOU0sCkGguLgyBdG7eY1l+4L3po/+tRW1Gn
         CgUbj234yH0C7QKlZlVf91b+FBD5TxpPI3AmL1HtfaRSCQPF8nHmzYUJZgHFOHsGVlRr
         c8GV6B/n9q8Dk2VGNcQlmd+SI3AFJI6D2aGkd+0R/aNkPaNZYgp9hK3zhz6r/OqPnqMp
         8LAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=KGbrERFz;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n27sor6580945qvc.41.2019.03.21.08.48.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Mar 2019 08:48:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=KGbrERFz;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=o6wA8Xm3/KE1HlmA+afwuG/RDCWHkgLTSDA7aPPLpPM=;
        b=KGbrERFz+LMKlc7C+ltIj5lTCqoJxUoX+OOQh7d/V/efPt/Sz2SYc/09I0M/z3Suzv
         twf8H3DQo97dPByMmpeZ2+rlR0cwlTpTWHG2geO7GlqajLnbeRyZn0RdzCnUD13Saj1S
         3e+fq1+ek6TPiigqHNaNUBgixGSGwN62S13NzuJx80/uVtGzw2hVtNCgRwbqa1WuLXZ6
         H5uWqyYlqvz7S4M4g63pHfCb8IxTSc9oStq3MWY9Qf7/JiMY3xyGh3OAcPwjuOzJjFEM
         HVoqAX0so3TNKoHmQZ/tUQUIWUoxnptHTCjDFTu+gezwgjLKTUv/Q+PuLIUrVHvLGSKK
         HMEg==
X-Google-Smtp-Source: APXvYqwMw5MMYI+0+mTgz9d3K0vkknD/dFkiYpQB/hVsJ1ySSZWT4K386fAzeXt12zrHqHE8OQpC7Q==
X-Received: by 2002:a0c:8733:: with SMTP id 48mr3747855qvh.101.1553183335918;
        Thu, 21 Mar 2019 08:48:55 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id h24sm3946602qte.50.2019.03.21.08.48.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 08:48:55 -0700 (PDT)
Message-ID: <1553183333.26196.15.camel@lca.pw>
Subject: Re: kernel BUG at include/linux/mm.h:1020!
From: Qian Cai <cai@lca.pw>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, 
	mgorman@techsingularity.net, vbabka@suse.cz
Date: Thu, 21 Mar 2019 11:48:53 -0400
In-Reply-To: <CABXGCsM9ouWB0hELst8Kb9dt2u6HKY-XR=H8=u-1BKugBop0Pg@mail.gmail.com>
References: 
	<CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
	 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
	 <CABXGCsMcXb_W-w0AA4ZFJ5aKNvSMwFn8oAMaFV7AMHgsH_UB7g@mail.gmail.com>
	 <CABXGCsO+DoEu5KMW8bELCKahhfZ1XGJCMYJ3Nka8B0Xi0A=aKg@mail.gmail.com>
	 <1553174486.26196.11.camel@lca.pw>
	 <CABXGCsM9ouWB0hELst8Kb9dt2u6HKY-XR=H8=u-1BKugBop0Pg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000182, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-03-21 at 20:08 +0500, Mikhail Gavrilov wrote:
> On Thu, 21 Mar 2019 at 18:21, Qian Cai <cai@lca.pw> wrote:
> > 
> > Does it come up with this page address every time?
> > 
> > page:ffffcf49607ce000
> 
> No it doesn't.
> 
> $ journalctl | grep "page:"
> Mar 18 05:27:58 localhost.localdomain kernel: page:ffffdcd2607ce000 is
> uninitialized and poisoned
> Mar 20 22:29:19 localhost.localdomain kernel: page:ffffe4b7607ce000 is
> uninitialized and poisoned
> Mar 20 23:03:52 localhost.localdomain kernel: page:ffffd27aa07ce000 is
> uninitialized and poisoned
> Mar 21 09:29:29 localhost.localdomain kernel: page:ffffcf49607ce000 is
> uninitialized and poisoned

OK, those pages look similar enough. If you add this to __init_single_page() in
mm/page_alloc.c :

if (page == (void *)0xffffdcd2607ce000 || page == (void *)0xffffe4b7607ce000 ||
page == (void *)0xffffd27aa07ce000 || page == (void *)0xffffcf49607ce000) {
	printk("KK page = %px\n", page);
	dump_stack();
}

to see where those pages have been initialized in the first place.

