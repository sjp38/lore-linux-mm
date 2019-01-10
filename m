Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFA1EC43387
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 22:52:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51406206B6
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 22:52:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="YzzMx2lD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51406206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3ED88E0002; Thu, 10 Jan 2019 17:52:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC6068E0001; Thu, 10 Jan 2019 17:52:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 967A78E0002; Thu, 10 Jan 2019 17:52:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5F6768E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 17:52:46 -0500 (EST)
Received: by mail-vs1-f70.google.com with SMTP id v199so5305909vsc.21
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 14:52:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=P685nafa2zAhgI9zC6sdbujL0xwAtvqi0aNgLLph/TI=;
        b=OBsV4eIsjOCHv9THsOCKDtNqGLiIQoCvlIy4Cl/KG2428wE9JbpP2OhscHuEYcmKpJ
         fTHpF6BQCSU4uJd2ACb65ZDlwayjQ3T+XKBl1X7zWtnd7kYJ+mqnhdZFNC9pUSX7v3gP
         6U/fAbSgwpA4kr6m1aeNvWqw3/e6xefs39whjIEWZ53CdZM26o4zkMDdv4/x90II7P48
         ZXRcWnKfIRVm+wqibCw7rI/XX25LzG4aBLE8GjRAJhWxos1HPgiWO7a9pJVABJY+65fO
         0osRjKFvTn92z/TkMaUhiOgZUjsRefNOYceMSSq/GgQZFOaYRh0Lq5CNa+jgnZSq6Tr3
         XT1g==
X-Gm-Message-State: AJcUukdLilYNX5vd03Mi98xMxwxfT7i7LgKKKU6xTjSJXChepefM4irL
	gsdhMtyVt5vK6i2W65F5zWkMtO9ki+StbfDy12mu6YgfgcdcGsxzNnmgXQFTepy1nH7wgUV/p8q
	9qHW3Ig4SgXQbyG795P32zH++bGT60DIUD2TSgjtc3gX1sRDjE7b641HyhllS0pTDuqbuIv6ZK5
	lOCJH6JGptBhnx4G8u7IPd/sJSCT3S8RdMvK4tqlDFM1x1OBGcQigQazhwlcAWhKzZn/UBDF85F
	ybYGmuyyCS4GIkHmrPjhoJgpcpx2VpJr7gfshXNIMvJKWEn6rgsBqu1elRYX7Wigdexg4Esbdwg
	6G8MNXuyxhEoJDiWSNei8OieZrPAWaKybnYHWgJhn4xrT1a1E/kgJA07MEOaK4uqc29qTI/hdBg
	i
X-Received: by 2002:ab0:550b:: with SMTP id t11mr4773034uaa.31.1547160766058;
        Thu, 10 Jan 2019 14:52:46 -0800 (PST)
X-Received: by 2002:ab0:550b:: with SMTP id t11mr4773032uaa.31.1547160765387;
        Thu, 10 Jan 2019 14:52:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547160765; cv=none;
        d=google.com; s=arc-20160816;
        b=PsUV8ZA8e+wKHTdt1CWI3Iep6vVcJVi133F8ktbutYvLWN9Bqu7qXWg8GOmEblOPeO
         pK66taE2zmuQvBC2RD0JQf7X5dU62FYZxYzz8moNUxctWgh22vv9Nog6m6DsglMmIWik
         9+0pNDWNSZtDRxUZJRjvO5O4dU5uF0b3a07FV5rX2p9Lwpq5dLTqWPNxcCGUjlDGeBT2
         aJpdFODUjcO8OnOCi/gLlJ6dO14V247t4y0KuZH08f0cG1/aPujJodXEQewjTXwU4vQq
         natONkOdTMVsMJG2nSodioR/zMo3ToDbOswBXw6l51jIFiVIKvZ9S7m/D5w2pcmVMzEi
         zZzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=P685nafa2zAhgI9zC6sdbujL0xwAtvqi0aNgLLph/TI=;
        b=epohqVhY/EiSsUZerFQgWgwPzEw6rkNy/yKPOMok/fnrMhf0PUa1MFZSONPk6EkNeN
         p4HTDcfjlgbrUfyMXsbgbFkCX7OP5llEfnSireNgS3nVwwfm10bHsegcwXQCCfD2ZMTV
         FE6+m10ggOmuoHfawF2VFAtdnxOZmQF8FiBAVgB4o9VPHxbqPc9t7FJmaXYZ8NR1XCBP
         syCMnEJ4tnYqnCz4ScHKGXOUutndspgKL2g5IL6I7lr7ab2yUAA9HtclChSeszNCt54v
         tHuh7KJ2L5yb/3PWwgmqpHqsRQFb7BvtRyxkau/LlvlLBWmoJyefhmHDh42wWhXWkw3e
         davQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=YzzMx2lD;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x1sor44587141vsn.12.2019.01.10.14.52.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 14:52:45 -0800 (PST)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=YzzMx2lD;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=P685nafa2zAhgI9zC6sdbujL0xwAtvqi0aNgLLph/TI=;
        b=YzzMx2lDiGK3NMYbzHeZe/msuEv9PiHkTHo2YTKzNeomHQBc6chIBEacJmMxVoLYhE
         6P9xQTbDSaNsJDgITFuNhAdzGuU5hwxYayRUDtv3WCSTag+Zs7KhoCdUFeWxusC51ESN
         Lo/RWfH+aeq6cXTFCMy2ed5O38BxapTXpaeWw=
X-Google-Smtp-Source: ALg8bN6kRhkBZkXOitnb7Q+odz6FlL9b5lqgkoTkrx0GgGY5k3dGhB6zNdRbReruPH9m3BJxEkfdFg==
X-Received: by 2002:a67:7106:: with SMTP id m6mr5182209vsc.67.1547160764392;
        Thu, 10 Jan 2019 14:52:44 -0800 (PST)
Received: from mail-vs1-f52.google.com (mail-vs1-f52.google.com. [209.85.217.52])
        by smtp.gmail.com with ESMTPSA id b131sm31015270vkf.45.2019.01.10.14.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 14:52:43 -0800 (PST)
Received: by mail-vs1-f52.google.com with SMTP id x1so8059290vsc.10
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 14:52:42 -0800 (PST)
X-Received: by 2002:a67:208:: with SMTP id 8mr5164430vsc.48.1547160762534;
 Thu, 10 Jan 2019 14:52:42 -0800 (PST)
MIME-Version: 1.0
References: <154690326478.676627.103843791978176914.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154690327057.676627.18166704439241470885.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190110105638.GJ28934@suse.de> <CAPcyv4gkSBW5Te0RZLrkxzufyVq56-7pHu__YfffBiWhoqg7Yw@mail.gmail.com>
In-Reply-To: <CAPcyv4gkSBW5Te0RZLrkxzufyVq56-7pHu__YfffBiWhoqg7Yw@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 10 Jan 2019 14:52:29 -0800
X-Gmail-Original-Message-ID: <CAGXu5jL1sivv70_Uahbg=cMZP2UM=eYBn4u8nx3NU5ayzHf28g@mail.gmail.com>
Message-ID:
 <CAGXu5jL1sivv70_Uahbg=cMZP2UM=eYBn4u8nx3NU5ayzHf28g@mail.gmail.com>
Subject: Re: [PATCH v7 1/3] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
To: Dan Williams <dan.j.williams@intel.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Mike Rapoport <rppt@linux.ibm.com>, Keith Busch <keith.busch@intel.com>, 
	Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110225229.3-IcGUtlCmrRCLoFAImA36dey9G9qvlRwFBfoDzt-Z4@z>

On Thu, Jan 10, 2019 at 1:29 PM Dan Williams <dan.j.williams@intel.com> wrote:
> Note that higher order merging is not a current concern since the
> implementation is already randomizing on MAX_ORDER sized pages. Since
> memory side caches are so large there's no worry about a 4MB
> randomization boundary.
>
> However, for the (unproven) security use case where folks want to
> experiment with randomizing on smaller granularity, they should be
> wary of this (/me nudges Kees).

Yup. And I think this is well noted in the Kconfig help already. I
view this as slightly more fine grain randomization than we get from
just effectively the base address randomization that
CONFIG_RANDOMIZE_MEMORY performs.

I remain a fan of this series. :)

-- 
Kees Cook

