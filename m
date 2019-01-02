Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31A54C43387
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 17:47:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E133C218FC
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 17:47:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=digitalocean.com header.i=@digitalocean.com header.b="TDyu69lZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E133C218FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=digitalocean.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BC278E0035; Wed,  2 Jan 2019 12:47:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76A458E0002; Wed,  2 Jan 2019 12:47:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 658448E0035; Wed,  2 Jan 2019 12:47:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3F2D08E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 12:47:54 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id c33so14860221otb.18
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 09:47:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0hBUk8Mse5SprcZveZ649K7+7VQzzipNWH9bsLfG1zs=;
        b=BHr5vEFS5x7wS67UWypiWD2AX2Yc9U3usK/W5bfsbIdx9F4hHTcdjCdHHp/lllh8kY
         JCRP7Kqljvv/biYUB5EYys7j9xhKSushABOFpPjgV77C0ABfv6bpushiRMNtNBV/GnsL
         ELpUUZXOlIf/j37R6zJ8nr15ZL/k8O6/oQItkpliUyPX+JzLN1nR7LHWgL9O4bIK3y3B
         iVIoftYs/WBDSOv9qNvcxvYxdHO/t5oQr0nA/mTFKEzkmWkya3gpG/cEGO7opCnfB6bK
         EyEYUNu1VwQjttndPlJ3YldZn/2ZWTCecjHstegUnoSGyhz1WvsDs4XtHseOVDqcFrRx
         fP6g==
X-Gm-Message-State: AJcUukep4/4Pergc8wrcRnkaB+EntLiVCS0e+fxZeTEVsl9ijgwt1HDX
	2O7+fsnKMa2ox3VbCSVS372bNskHiZGP3xNlhw2fv642dRrRSD1jE6ko2ieHODk6b7K+BfqiQo8
	v/rmu4LDg1qq/MQYLQswlSa7vmkQrYSwbqeiP3mSL8qgcdBKfw4clFsaYay12s+XkjhNyS2KeeX
	ycHgbG7vSiL7R0khRsW7fceVz/NZwPV4JnBj9TQaypxJ8cFyJc4kmpBTAen7NkUgkpf/wsPxLf/
	yptfAsnZ93YgTJMfqFTPUEM8M4hJLlnLJy0OZmlDtzRHnc0ppLw6u2xunCygssPlUIykhK6V0tJ
	/6UaOM8RvHL+l/wJ98jnzC27N+28tVr8R7vlgUAhB9RnAvUigu7717mJLY5jACX7JDa83TfEGKH
	Y
X-Received: by 2002:a9d:19a8:: with SMTP id k37mr32592766otk.283.1546451273998;
        Wed, 02 Jan 2019 09:47:53 -0800 (PST)
X-Received: by 2002:a9d:19a8:: with SMTP id k37mr32592745otk.283.1546451273334;
        Wed, 02 Jan 2019 09:47:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546451273; cv=none;
        d=google.com; s=arc-20160816;
        b=gcZyI/PDk09Rr9bqUOAOMUQUEWavIvcwdIZ4h3xT3Zb+9tTfQjnOgyzvXvh9TMgGrz
         Fng2fDHk5SeQJVsrc/pC/MKtx7iCVNao+80BWRH965wWBYVvsw3/zUV5RiM0JFSfJKOZ
         M/2YP7p6OiaAQTSUdeUHvSKbmGRN5fm8B0y5Hb1DPj5mz6hMTqjMT0RDi838fKTbi7Ry
         LN2RWfYI9dv4xfyf2NTSncrJ8q7SrgK++Rr4Sfo6b7io34zixWkUTCSt6YK+u6L1Z20P
         19yXclBKR03k7YMKkdRqkBMhlicXj16R6I1z1u63DxrDjP2u0luVoR9mWCZxiDKQknNt
         ujKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0hBUk8Mse5SprcZveZ649K7+7VQzzipNWH9bsLfG1zs=;
        b=F8CHiHhZn9FU/LMQEX4/A6TmC14L+YO83IlmPGSi7xQC0jhSfChfB+oniX+o7nxbTC
         oKcizfC/957/swEYuDK8NeipP82vdURCdhDznNnJsoK6cVflgk78Pw7Or+w+YKEeZ/H9
         DfETzmpd8TastsALi3X0vnw974w8VM9DDTc3zlVMwLgThDLINYegVmet2gBfImL75y+X
         WL9t+t6gzm1HmD+T5cFaX6KXniKeJJqCnfPz7hFgbxGwYoUWFDLDjTeE90SfOelEWf79
         uB9ruLTfpMJK+0sMePalEbtwQHtJE5v8z/F0RPW5JRGryLr6is6bYcwiftlBQgo352F8
         ko1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@digitalocean.com header.s=google header.b=TDyu69lZ;
       spf=pass (google.com: domain of vpillai@digitalocean.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vpillai@digitalocean.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=digitalocean.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z89sor138199otb.62.2019.01.02.09.47.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 09:47:53 -0800 (PST)
Received-SPF: pass (google.com: domain of vpillai@digitalocean.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@digitalocean.com header.s=google header.b=TDyu69lZ;
       spf=pass (google.com: domain of vpillai@digitalocean.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vpillai@digitalocean.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=digitalocean.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=digitalocean.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0hBUk8Mse5SprcZveZ649K7+7VQzzipNWH9bsLfG1zs=;
        b=TDyu69lZSUHU/VU7Ss2yo6UJzSknmMCUOHHR1EQDCiw2yNvY97ekNE8jOmsUl0EmTY
         61ge1HunQ8fGibGB88QKzLie1fF/v7IE7xxdbwWDImQUcORxvHSY/k4s7ZmPIVy37XLr
         xJKiRqVlBW+w2PFwTuoGxZyRC2kaI4Z6SwgLk=
X-Google-Smtp-Source: ALg8bN5Q0vtZNj9c9C6J/ihvx9BkDJAA+ekzmZVGE31cgguG5Qo9I8KwhxlPZUvc9TmgT+bkTPAEpmgOe2kAPhrbP5A=
X-Received: by 2002:a9d:1f3:: with SMTP id e106mr29318143ote.369.1546451272726;
 Wed, 02 Jan 2019 09:47:52 -0800 (PST)
MIME-Version: 1.0
References: <20181203170934.16512-1-vpillai@digitalocean.com>
 <20181203170934.16512-2-vpillai@digitalocean.com> <alpine.LSU.2.11.1812311635590.4106@eggly.anvils>
 <CANaguZAStuiXpk2S0rYwdn3Zzsoakavaps4RzSRVqMs3wZ49qg@mail.gmail.com> <alpine.LSU.2.11.1901012010440.13241@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1901012010440.13241@eggly.anvils>
From: Vineeth Pillai <vpillai@digitalocean.com>
Date: Wed, 2 Jan 2019 12:47:43 -0500
Message-ID:
 <CANaguZC_d2EBmNuXtcJRcEcw8uXK234tYSXx6Uc2o9JH_vfP4A@mail.gmail.com>
Subject: Re: [PATCH v3 2/2] mm: rid swapoff of quadratic complexity
To: Hugh Dickins <hughd@google.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102174743.HztUB3h3XpLHG2eCzqaIegm-y1RB6lKvKiFRQXgyCF0@z>

On Tue, Jan 1, 2019 at 11:16 PM Hugh Dickins <hughd@google.com> wrote:
> One more fix on top of what I sent yesterday: once I delved into
> the retries, I found that the major cause of exceeding MAX_RETRIES
> was the way the retry code neatly avoided retrying the last part of
> its work.  With this fix in, I have not yet seen retries go above 1:
> no doubt it could, but at present I have no actual evidence that
> the MAX_RETRIES-or-livelock issue needs to be dealt with urgently.
> Fix sent for completeness, but it reinforces the point that the
> structure of try_to_unuse() should be reworked, and oldi gone.
>

Thanks for the fix and suggestions Hugh!

After reading the code again, I feel like we can make the retry logic
simpler and avoid the use of oldi. If my understanding is correct,
except for frontswap case, we reach try_to_unuse() only after we
disable the swap device. So I think, we would not be seeing any more
swap usage on the disabled swap device, after we loop through all the
process and swapin the pages on that device. In that case, we would
not need the retry logic right?
For frontswap case, the patch was missing a check for pages_to_unuse.
We would still need the retry logic, but as you mentioned, I can
easily remove the oldi logic and make it simpler. Or probably,
refactor the frontswap code out as a special case if pages_to_unuse is
still not zero after the initial loop.

Thanks,
Vineeth

