Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6ADD5C43444
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 19:43:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C25D20879
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 19:43:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="bfOEJAnj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C25D20879
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF7C18E003E; Wed,  2 Jan 2019 14:43:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7F8D8E0002; Wed,  2 Jan 2019 14:43:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A21ED8E003E; Wed,  2 Jan 2019 14:43:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 58EC78E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 14:43:22 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 202so27595342pgb.6
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 11:43:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=R11YRNGLg7CgD4a9KU3qTMje2Bj1pNep2Y2+/ttJnKQ=;
        b=gaNH2A7P3MjdKTR0XEkWdVKZa8Dl1T0S9ApyVf01xrYVNIg5gzhP1BBd65M/v6jo+X
         /AKBBTK1i+XwPi38SUHjUdlfaraY2nv+6tZioc7XXekysnOU5ZyYqaHm9y8APibvNTYH
         wrWP/OK1fROHQOPHWWhVQ2felIJSOzuC1fUZe7XIW3seAUAotc2tFX3LhsZX0lFYy3UP
         IJAzgzgPsjHKdVAIvcjneOZh8ryf22qalMH718QvdcJ2LDEhPIMS+h3mw2YkUokwaNxV
         aGzROh12nfd8V6ODfWT5huAg62ex1KsMYuOHBRG8NNNF7noFmgBvGoT+reZsgjPFk5Ka
         vD7g==
X-Gm-Message-State: AJcUukdDL6kYmoF+Y8xGvVFSj0C6MlX+OX13S3MHvHCtKTEbV6kEPt++
	rJfY9SHd2eDPDf/3/+nKeleU27bRLOHvMddUTJns4PUk+CGIsu6MooGgefOJjSN7TgxzvC3Utli
	9zqRqMDGyfCApCh5FtUsfLpwt0znS9ZZiIY2Ap0Cq152J2YeFhCMO8UGvCiF6vbppizKYBXsVRD
	5uWhOzqH4YHl3f3wt/4eAO4zUHSpeRjOZ6J9m0NGawJWmcqrnLh2M4QytuU3NQ8dKIpwzSDwX6S
	4IlqeCecRmCb6r3+cmtrM4KR/HFuq2JbGX/ZjUeNtOP1UfXcShYTxIC+GXzpBVsU1WT2XgILCsy
	oqf1M36D+mSrFXq+3BIvSOoCXKfNx6E5x5XBYZ+/wouVHcsXckyDl7SNQ+cikS4vSw6w8bHI0nq
	o
X-Received: by 2002:a63:6b05:: with SMTP id g5mr14282150pgc.15.1546458201943;
        Wed, 02 Jan 2019 11:43:21 -0800 (PST)
X-Received: by 2002:a63:6b05:: with SMTP id g5mr14282121pgc.15.1546458201127;
        Wed, 02 Jan 2019 11:43:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546458201; cv=none;
        d=google.com; s=arc-20160816;
        b=EmjFlTamp0x6NBvHmqk7JJj3wBpZbvibNEPxe3GXdZGVuJfb2U0u0IsjRX/MRHPAuP
         xAknd8i4LCXb1C2u9pbbck7cgnblrUuWekL75zq91j+/HCQia+3ebKiaAT5QTUULNDrz
         RP5vs3OH3rUwRWx3Lmj17hDdRuZwxeaidQJWhJKhD/txN4ySsI+ijJO1CKUuQ32SDwfw
         hFPEUjD7FoK+46hDbFN1CpeiuB8nqdtPTERuNmWHR6G1esZwiEjrZlOizlZe1NG63OS2
         aSN1HxX9H2sdLysrJJtM5e/mFn+czQbZ1ioxQKwiSgzjIkUIw/527V1q7BFr54gkOcTn
         3feg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=R11YRNGLg7CgD4a9KU3qTMje2Bj1pNep2Y2+/ttJnKQ=;
        b=R0SYSCtt5tOOXWPgOAkkDd6PFHz2pH4x6GWJEuttwrcLDZtM4LzgSEOrB2OSwcnXvT
         NELTkKePtgQQyO4qx4xTyBRoBZ7jVgycZhzhr+DTut87p9Ha/GUVFxsJLRXIv+Zla5R/
         RtG9FJCwD8y3xd7fzxWm8901aYNc6virmPFCXM76arcqo+iGQZ4UxfVl7XviLRJoqgoX
         ZOK6RgxMGUtA2QHGzTfDrmv76xMvW9eMl5+fibeuZAsBscb4aigcGJcbyKtFPHZa0Gax
         QrCrkpNegFtGfp71xMQa9zCzG/Ieg0ziBXvNxff9vtrmurXtxS2GftflkKwJGNp6QKhF
         CuCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bfOEJAnj;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x8sor19973845plo.55.2019.01.02.11.43.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 11:43:21 -0800 (PST)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bfOEJAnj;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=R11YRNGLg7CgD4a9KU3qTMje2Bj1pNep2Y2+/ttJnKQ=;
        b=bfOEJAnjnaN57sGdjQL7WTLCb47OFeG9Jx9a7m41YFvupoOw/BDT8FCtSgCQJHNKoD
         zrcTbdFz1BtMs2ipclejuZ5rxueDg05/fV/IZyh29nM9aRxzQaas9TxhqofVO7hOJlMX
         ym6tCsHNKSzn4md6EeHHz+RMawQhHjaw751q2Q81oTwlF8mCS32vaodtA7ByBw3YUl6Y
         xRcHoh0WtT0a35nF7I8vK6eGjnAnJlo6bNHSiOpn1jmnzL43YYgX/rP6jZwqO3/NKrd+
         sZx7c+Qbx0Ns8zrG1fka+XyGxuTq9r20jHSB4uBSsjYQ9NHTdow+Ku0yrw4JZ3od8gdp
         5elA==
X-Google-Smtp-Source: ALg8bN4T5keWdjzEDYXMLBrTaz792i+sHg8SlzQOmoMyLJz9y9szbkag54wCLTpqqc8D1CB/GiY8yQ==
X-Received: by 2002:a17:902:9a9:: with SMTP id 38mr43746591pln.204.1546458200138;
        Wed, 02 Jan 2019 11:43:20 -0800 (PST)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id w11sm64310340pgk.16.2019.01.02.11.43.18
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 Jan 2019 11:43:18 -0800 (PST)
Date: Wed, 2 Jan 2019 11:43:12 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Vineeth Pillai <vpillai@digitalocean.com>
cc: Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, Kelley Nielsen <kelleynnn@gmail.com>, 
    Rik van Riel <riel@surriel.com>
Subject: Re: [PATCH v3 2/2] mm: rid swapoff of quadratic complexity
In-Reply-To: <CANaguZC_d2EBmNuXtcJRcEcw8uXK234tYSXx6Uc2o9JH_vfP4A@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1901021039490.13761@eggly.anvils>
References: <20181203170934.16512-1-vpillai@digitalocean.com> <20181203170934.16512-2-vpillai@digitalocean.com> <alpine.LSU.2.11.1812311635590.4106@eggly.anvils> <CANaguZAStuiXpk2S0rYwdn3Zzsoakavaps4RzSRVqMs3wZ49qg@mail.gmail.com> <alpine.LSU.2.11.1901012010440.13241@eggly.anvils>
 <CANaguZC_d2EBmNuXtcJRcEcw8uXK234tYSXx6Uc2o9JH_vfP4A@mail.gmail.com>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102194312.03491H5CcWg8lDmOiaiL_7o0hNoL5UrOqJ6eWrtq3ys@z>

On Wed, 2 Jan 2019, Vineeth Pillai wrote:
> 
> After reading the code again, I feel like we can make the retry logic
> simpler and avoid the use of oldi. If my understanding is correct,
> except for frontswap case, we reach try_to_unuse() only after we
> disable the swap device. So I think, we would not be seeing any more
> swap usage on the disabled swap device, after we loop through all the
> process and swapin the pages on that device. In that case, we would
> not need the retry logic right?

Wrong.  Without heavier locking that would add unwelcome overhead to
common paths, we shall "always" need the retry logic.  It does not
come into play very often, but here are two examples of why it's
needed (if I thought longer, I might find more).  And in practice,
yes, I sometimes saw 1 retry needed.

One, the issue already discussed, of a multiply-mapped page which is
swapped out, one pte swapped off, but swapped back in by concurrent
fault before the last pte has been swapped off and the page finally
deleted from swap cache.  That swapin still references the disabled
swapfile, and will need a retry to unuse (and that retry might need
another).  We may fix this later with an rmap walk while still holding
page locked for the first pte; but even if we do, I'd still want to
retain the retry logic, to avoid dependence on corner-case-free
reliable rmap walks.

Two, get_swap_page() allocated a swap entry for shmem file or vma
just before the swapoff started, but the swapper did not reach the
point of inserting that swap entry before try_to_unuse() scanned
the shmem file or vma in question.

> For frontswap case, the patch was missing a check for pages_to_unuse.
> We would still need the retry logic, but as you mentioned, I can
> easily remove the oldi logic and make it simpler. Or probably,
> refactor the frontswap code out as a special case if pages_to_unuse is
> still not zero after the initial loop.

I don't use frontswap myself, and haven't paid any attention to the
frontswap partial swapoff case (though notice now that shmem_unuse()
lacks the plumbing needed for it - that needs fixing); but doubt it
would be a good idea to refactor it out as a separate case.

Hugh

