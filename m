Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E67E8C43381
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 07:57:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FD2E20830
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 07:57:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uy/Wtrn9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FD2E20830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AF536B026D; Tue,  2 Apr 2019 03:57:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45E546B026E; Tue,  2 Apr 2019 03:57:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 300726B026F; Tue,  2 Apr 2019 03:57:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9CA6B026D
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 03:57:08 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id j8so2055618ita.5
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 00:57:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=wwqAk3i2+Zv3o0pWyHzJF+VB/i0BlUhtj9pR8gcxtjI=;
        b=VaLsGaNelW9N4P2AYF/g78JXXGsaOrrQu5kvcnnWomSCenvSu0xu7dscPY6yrJDoyp
         GWIqX9eba5fvarf4BbtG83fPVJscfD/waazFObzk5laO674hsKlNZB7InsddzmkO801S
         Wf0Ous/lwNt5HiqC7fgtKoYlNTHGfaB2JbG7RO8xtOum4oQwQFa0QWV3tJogi4frCNCa
         FFXDag9IO9xvaQ+6wQ2VjCRjz3scW6OxlyBgm5nUZhhBrClgXr5WQJMRhtYdeH4/cSHg
         eI4wNf51RtaTmu2eUbxCnbN+zEquAYLoyPHt4cFkcBwyZnZMWUpGBDHtqZNKkIxXHnUB
         daLg==
X-Gm-Message-State: APjAAAXyHmxwaWRDrUf5kHkbqvgBATtGMVDwi5qe4yF7uQ5TFisuuwfG
	O5cV9o6af7pfhBFUIRHTK89o+fVj7E3x2gL8c0a+2TUKcb38PTAMgGlA9JByFvExIi2me0xt/sj
	P7p7Dq3UuC7CK0WeA4Y3AkQdyuvQAfwaiIiPU54Q8/pazpSlxXMej/AMXj92d/00PbA==
X-Received: by 2002:a6b:700d:: with SMTP id l13mr47053365ioc.248.1554191827839;
        Tue, 02 Apr 2019 00:57:07 -0700 (PDT)
X-Received: by 2002:a6b:700d:: with SMTP id l13mr47053333ioc.248.1554191826938;
        Tue, 02 Apr 2019 00:57:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554191826; cv=none;
        d=google.com; s=arc-20160816;
        b=tmSXS5oFQ9GCthe7ifvSs3K5G/e3mtdTHEG2C5H2Zh9x9JbQHqGNBUwxSNrPxRkFo9
         Es44sP6Zh9VFwQy5jdZ+XAY4MmgSCUYlOWU+x+n/dEQIcUMRa58XSPwkb/ezi2YGCVq+
         ufiRRSmBH3ZFvoqNEnV8IEqtyb2jxWExmR6vnlkYVMOE3YQgN7xHKNiJaNGqDmoH+CqF
         58c40EVoVkeUF8n7BUQR1IsIrmDO0D0UrjL8wFoo5WFQg0E5404JONJO6uMg1ulBI+T0
         MFoohEARwuPWlHnhBMpQpkPVLodj1sHjtAGmviHMKH7VGflz/YVy/st/+SHGDPK2b59H
         DIyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=wwqAk3i2+Zv3o0pWyHzJF+VB/i0BlUhtj9pR8gcxtjI=;
        b=HbIswy3aouy7uwE+zjlz9yK4R7KKPcFt9uQJAUe2DmVlnZCMdN4wxEZra/hPQa8qQo
         zKGLfysBwViX/9ohtqwPb52K+qTyPVC4wmIz8764rBJhmyd1RLEUCC0IRoC3xB6A37qd
         5HxMNt+XM7+q8d2nhRDryLjTcxOMAaxrtMf9JbF8E9/ZGLOraE5p+qSYmSEBp9alNsPK
         G5xRpcur7IId4EV+De1/iXRwVTphaWYJWRRTTC1w87l3y/kLLAmOYsFT8vevnwI/xrjt
         IQZTVu8V2PN/5qxvgdLJ6wx5SfZ5fIZl764VJZJdqkuVRTXiRH5lIrRfPSYEXWWAtBWR
         OcCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="uy/Wtrn9";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x7sor6808385iom.5.2019.04.02.00.57.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 00:57:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="uy/Wtrn9";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=wwqAk3i2+Zv3o0pWyHzJF+VB/i0BlUhtj9pR8gcxtjI=;
        b=uy/Wtrn9+qQNfoD8pExD0yoZlxPtLH19N8AgGJ2doFoBypY+rnAQvyPnxGnM+arKIR
         DRfvy+Emwog0Sj1yz9KQXmmZ7So68Mq0BN2VVWp0vjnZixyxtxhIv/OVddgWC0RnowWY
         +qSJzQs2ZGQhBP6U+kq2KC4EBpFK/TRbX3ks5FwabsJxOnASeR0BLBk8liZ4YFbjMWa2
         M0GCEz7zmV1vCiFU87c2b6Dp3wWEi66xydlXpyJsELAqaDHCQZ3za6o0zP7mwQnkP/Qo
         5vdCJZ+YhkzsV9iaDNTa87oaOwnQBa8V7lA9rQE9PSrQcSEoSMX0sqJrUascyt+bb/3+
         pjeg==
X-Google-Smtp-Source: APXvYqwnp6xCt7FlNjMJy2A1tfclDopUF4MlZI21KCVEtf1MQeguCgxCXZp1epuwptOd50yK23WasNPnQR9R06rHqgg=
X-Received: by 2002:a5e:df06:: with SMTP id f6mr14527223ioq.199.1554191826738;
 Tue, 02 Apr 2019 00:57:06 -0700 (PDT)
MIME-Version: 1.0
References: <1554185720-26404-1-git-send-email-laoar.shao@gmail.com>
 <20190402072351.GN28293@dhcp22.suse.cz> <CALOAHbASRo1xdkG62K3sAAYbApD5yTt6GEnCAZo1ZSop=ORj6w@mail.gmail.com>
 <20190402074459.GP28293@dhcp22.suse.cz> <20190402074911.GQ28293@dhcp22.suse.cz>
In-Reply-To: <20190402074911.GQ28293@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 2 Apr 2019 15:56:30 +0800
Message-ID: <CALOAHbD=64+Sy5HsRVvGXBSduv5eofD39XNuz_cvwymAX-ghYg@mail.gmail.com>
Subject: Re: [PATCH] mm: add vm event for page cache miss
To: Michal Hocko <mhocko@suse.com>
Cc: willy@infradead.org, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000039, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 2, 2019 at 3:49 PM Michal Hocko <mhocko@suse.com> wrote:
>
> On Tue 02-04-19 09:44:59, Michal Hocko wrote:
> > On Tue 02-04-19 15:38:02, Yafang Shao wrote:
> [...]
> > > Seems I missed this dicussion.
> > > Could you pls. give a reference to it?
> >
> > The long thread starts here http://lkml.kernel.org/r/nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm
>
> Thinking about it some more this like falls into the same category as
> timing attack where you measure the read latency or even watch for major
> faults. The attacker would destroy the side channel by the read so the
> attack would be likely impractical.

Thanks for your information.
I will think about it.

Thanks
Yafang

