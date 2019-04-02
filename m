Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A04FC10F05
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 02:55:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7B79207E0
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 02:55:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="S80rgrKK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7B79207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36CEC6B0003; Mon,  1 Apr 2019 22:55:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31D036B0005; Mon,  1 Apr 2019 22:55:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20D216B0007; Mon,  1 Apr 2019 22:55:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id DD15C6B0003
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 22:55:03 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id q7so8888926plr.7
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 19:55:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=2YJv0TU4reqr1XesjZUu85dr59wYQQ2sU3iSxRPA0nA=;
        b=QhX8cz4aZlfJUtijtb1//zJBODuaCHvtPNG9n/gWoSiyA4IxnBjtdzLbNaDB7vsl0x
         Ufix/2vcO994yDBSJKtPXn+K8yF3qkDKrXhviFHoMTugtknRmVrQUo8kAVtPIv/Xrk7/
         Jvy7lS2LBGIPh0798YeT72oAXp0BY40Nt2jsjXMLVB0LIqoYbu9C67EF6PRmW41CRsAi
         BW3lfVZkjjoXE+vsTD3f7/8hMPMujwkJ6vrTfEBusaKix7qGfABMzIMfIt14VBuRQ+jc
         LhGnaEpwag5bDrvsbO6kRWOBtkyLRZMW8nG0d6tI570tDE31r+yDN4IIeyAHOtgNYXMP
         TfPw==
X-Gm-Message-State: APjAAAWFXjikBlX1R+RVYZnKlney0ja2P/bvHpNJy/+itkvsVWk4EWMc
	xuT8K0dcGjCV8NqMxVZJFmTZYh8lKnc5V3xaIu56iUITZhRzt9K633jMs44EmYI+rE7nrc8GZyX
	m8KVxndtGi8Q8fgRGNpoYwEMcepcZ2AX/ov3Q765wfbVbftzUHUMHKcEIp+Lu1VmdkA==
X-Received: by 2002:a17:902:b282:: with SMTP id u2mr49937494plr.9.1554173703435;
        Mon, 01 Apr 2019 19:55:03 -0700 (PDT)
X-Received: by 2002:a17:902:b282:: with SMTP id u2mr49937449plr.9.1554173702577;
        Mon, 01 Apr 2019 19:55:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554173702; cv=none;
        d=google.com; s=arc-20160816;
        b=PFLyq6qVxNhWpEbswngBCIPs/M5WlSVfV0lPSG8YUatIeUheib1vLly5GJeoYkkiiq
         e28nsVJ0LR1ZvtB94Gtn4am7UbG5dDYoxjxHWX66kQk8GRLBlCjn25jTioh70c1L1Xw6
         GjLMAz8/mTVaHTWjTCQiZf0LT69ZhWmSswL/X1dKAJiIX/4Hj7eEXy+YSscDkbxWR9Ed
         l61f717wX2jhjjfVEQkihbK87+IQZm8eu3o3ZbaoCyT/BCSkXl5IEBFlz+UlpgwfxZL1
         1pehrP8vPKhW3A95FZ6+43jDwlld2j1F0xA9Uly93+o+0OHssaHeOHmnSAyslfvD6iUA
         OGvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=2YJv0TU4reqr1XesjZUu85dr59wYQQ2sU3iSxRPA0nA=;
        b=JfUVFu3C+KY9xZ/ICCMNrtjkbD6ZA7Nk6RJd4InWC7JAh4wyBjL6w8d90NBlPoUFk8
         YUyaPwyvRle9FOZ74qtazXrePiqOzTbqmWPRU+UfAUUB/XcnNwD6T/9st4M2mBUoAHid
         LKyOuyTjCTOpYM+KO0xK2rZLcPAk9of62S0se2UtUgilvluNLNDX7LRbxDToyEHw3g6i
         AbfctdhaqGMnbByVToHG+4QKCeunfp09VSMoER9wZ4DGeCTDTLbyR5qDl9MvJZ4JiH1P
         IMjsMT7chJ6MfcYWphTqtgDL3VDEvLF8BICdH+ph75oyxfJO42WBWOIQKx5dKD15VEPK
         ET5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=S80rgrKK;
       spf=pass (google.com: domain of ndesaulniers@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ndesaulniers@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f12sor12673882pgp.66.2019.04.01.19.55.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Apr 2019 19:55:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of ndesaulniers@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=S80rgrKK;
       spf=pass (google.com: domain of ndesaulniers@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ndesaulniers@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2YJv0TU4reqr1XesjZUu85dr59wYQQ2sU3iSxRPA0nA=;
        b=S80rgrKKnKgYNCbvkSPiIuDGpRPXZ5PcLNMr8oY8XBSSnzoUNg1wh2K+j+SDx3D6KZ
         y67KJ3vRFSFhU+8rxZmJARzpzjtyYmpOfNMZzwrKFM8kmu5QoK4AF2gvXHa2J93wwbND
         n+XLuFEc2J2TB2zeVCsLAxbLrt8LQsBtlRvByqaEkDdoa8uLwU/SA+mthltHW/KCb6go
         Od8a8pSd2glFkZKmpeErd3GtbSACJEiQ9tgBl0w2NRg3bLHDJ2QVOIYuhh35nAtUtV1j
         KOoVF0U0HQnV76bItRJ4RPzcrDsRoux2U9ue1+vdxGVWpKSTFD8hXNmzdeGzQDYsB2/g
         ALqA==
X-Google-Smtp-Source: APXvYqzCV5fvCjc8AQ2luhPjV0wd8ML4qhCjaMK9ahShMpCfz9YWDN4+7uPlOM+kDxTJd2fLOu9sX6RlX3SqvdiC70E=
X-Received: by 2002:a63:7444:: with SMTP id e4mr46157276pgn.261.1554173701838;
 Mon, 01 Apr 2019 19:55:01 -0700 (PDT)
MIME-Version: 1.0
References: <eea3ce6a-732b-5c1d-9975-eddaeee21cf5@infradead.org>
 <20190329181839.139301-1-ndesaulniers@google.com> <83226cfb-afa7-0174-896c-d9f7a6193cf4@infradead.org>
 <CANA+-vAcW0VfAZmZWi84s1pQQ+tFx8VyzYsWi5_gj7vHT3Ao6Q@mail.gmail.com>
In-Reply-To: <CANA+-vAcW0VfAZmZWi84s1pQQ+tFx8VyzYsWi5_gj7vHT3Ao6Q@mail.gmail.com>
From: Nick Desaulniers <ndesaulniers@google.com>
Date: Tue, 2 Apr 2019 09:54:50 +0700
Message-ID: <CAKwvOd=PstHEm_Vxtx_SGanKhAJSjoQiCb3kgCVeK4peUF2k-g@mail.gmail.com>
Subject: Re: [PATCH v2] gcov: fix when CONFIG_MODULES is not set
To: Tri Vo <trong@android.com>
Cc: Randy Dunlap <rdunlap@infradead.org>, Peter Oberparleiter <oberpar@linux.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Hackmann <ghackmann@android.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org, kbuild test robot <lkp@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 31, 2019 at 6:57 AM Tri Vo <trong@android.com> wrote:
>
> On Fri, Mar 29, 2019 at 1:53 PM Randy Dunlap <rdunlap@infradead.org> wrote:
> >
> > On 3/29/19 11:18 AM, Nick Desaulniers wrote:
> > > Fixes commit 8c3d220cb6b5 ("gcov: clang support")
> >
> > There is a certain format for Fixes: and that's not quite it. :(

Looks like the format is:
Fixes: <first 12 characters of commit sha> ("<first line of commit>")
so:
Fixes: 8c3d220cb6b5 ("gcov: clang support")

We should update:
https://www.kernel.org/doc/html/v5.0/process/stable-kernel-rules.html
to include this information.

> Thanks for taking a look at this Nick! I believe same fix should be
> applied to kernel/gcov/clang.c. I'll send out an updated version later
> today.

All yours, happy to review.

-- 
Thanks,
~Nick Desaulniers

