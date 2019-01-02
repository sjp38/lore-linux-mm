Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DF4BC43612
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 20:05:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4EC6220836
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 20:05:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=digitalocean.com header.i=@digitalocean.com header.b="FVUoshR6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EC6220836
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=digitalocean.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B23D68E003F; Wed,  2 Jan 2019 15:05:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD4118E0002; Wed,  2 Jan 2019 15:05:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C2838E003F; Wed,  2 Jan 2019 15:05:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 732678E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 15:05:36 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id r131so22525121oia.7
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 12:05:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=jwNzLMTXb+K6/MpjHKyHQEI4PyVQzu80D6rs7MUtTdg=;
        b=iUE06k9wzZrQsU1CcmMnThkmwHZ8oSF3fVDMwnKtB9IVaTPwI32X+mdYbqpU/zms5C
         IWKjBRoSSvvHu/7MsNxhmVBsD9wY/XTNypuu6WlkVZxtymZGlobgfqiYa4KE3Js77Q+H
         HpknHhz1ZM3uAv9Z1jnZJ83hjhtdcc9DCZy0W6UePWlSW2g3PjKIm1iAzAWltbkm6HAC
         SmRxlgcYf5tBlmHHpcZplpD5IxiuTVlxXfzJQnSbuS1ABSk9zQ6LLjNf2CqnsavTg7NA
         xWKJLJYdsdU1vvXgrET+O4CKuKE7mnLKitNd1oOAt1Etz3TOFiw5rjMQx8AqZOH2CcHs
         aLmw==
X-Gm-Message-State: AJcUukeHJDrBe9UoYirouIUSWQDfPB4zwgaERlue5HNoeJOivOp23BK2
	5Jq9dlUD1SQq2v9lnBGfV4oMrdXgQy2Y8HaVIFKvSwtn6/lXlnE0IJdMvYoOIiByjbwKNpGPrOT
	C76XInRqd2wv1J/L6CyXNdoayj+kPjfqijbpQcCwHSweCBQg1KVphMx0nlFaQm6VHuRjurO6WgN
	3ErFT/8TyahjCloXPp+Skk1c1bLqayAaKW1KhVhS6Sj3RrKkZMFMlV70U8ZnW4ZFAyeiZUm7tpa
	bQ8YQ8LdZ3Jl7pZCDSEyKdObNyZlwX1bCCoctLtSEFS7sO8Kbns/BHnoM9xiXjekUY0PWZURgAL
	MtkdarXhqSUwj9mftrPpKTMkdvunD34FJBB4gLD53UZdjjkwV7ojQ0dKo3QjB6M6xnsndHSvxBD
	+
X-Received: by 2002:a9d:6143:: with SMTP id c3mr32548867otk.227.1546459536140;
        Wed, 02 Jan 2019 12:05:36 -0800 (PST)
X-Received: by 2002:a9d:6143:: with SMTP id c3mr32548835otk.227.1546459535349;
        Wed, 02 Jan 2019 12:05:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546459535; cv=none;
        d=google.com; s=arc-20160816;
        b=mzV6X7WrouEZ6Hm443hlGZkw53ceVcF17fB1c+mJGKudMgmeD0oPnZFFKNPxC40Vt/
         D8Yt+fUjN/80AooD619LFowK+9SEjSNKuIL3AQqFuk4/I5a8sfXZgqCJ++zvtert2NA4
         tnwV1hwJCsGtnP8Xuc7Ip1b9fXEM8uZHv0BPnWNfLp7HV3gVPmXcxL3EAHT9AfOTB0ag
         x0EsyMIBva8tT+oLtzVR9bh6Te3d3v8ScUv4nZAyHF05rBW9AfwP4XUnGTOSNd2bIrF+
         nQJjF6vRRv6kiKWcdWlrwZilcxhWKBMfEtHj0qa8Q6PfAnET1X7HXbHAzFfHrRmpfdE8
         nhjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=jwNzLMTXb+K6/MpjHKyHQEI4PyVQzu80D6rs7MUtTdg=;
        b=H61s05UasEP6h/Rhw909kQppEDS4mYnijUtxNoJ68svFsh9KE/zFA0z5a1busIId+3
         2hUDrj7wEliuHK0no4cnqbqBash+SC/m8Er5vAFBqHtfjmP5decyC9WX9ys4XZ8eUxNZ
         fT2wsAIKyEzUtCuUhX15Pq701UQ5OqBWxXLR2e2i8Fdc06WBDBJ5ikVXWMZv4kQSjdFr
         BdCSskqsrfXhJ7kDUPz4jEZXdb3IvWrkSbV27oCZ1t8r8Bv4a1VAPMmR5W8a5Ny60hiI
         lu8WP+vkEt4CdLDX0+eVZ5H/ZvI38M6g4HtWdtJ3Hk4047tySQENKw8IM9gn6jpCQU5D
         rg9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@digitalocean.com header.s=google header.b=FVUoshR6;
       spf=pass (google.com: domain of vpillai@digitalocean.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vpillai@digitalocean.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=digitalocean.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k24sor19133405oik.152.2019.01.02.12.05.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 12:05:35 -0800 (PST)
Received-SPF: pass (google.com: domain of vpillai@digitalocean.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@digitalocean.com header.s=google header.b=FVUoshR6;
       spf=pass (google.com: domain of vpillai@digitalocean.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vpillai@digitalocean.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=digitalocean.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=digitalocean.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=jwNzLMTXb+K6/MpjHKyHQEI4PyVQzu80D6rs7MUtTdg=;
        b=FVUoshR6kTZsAcEIlAy811Gn+sD88fDMXWF8uWPdUFp89IZpOvZpAARU1UwUPf4knd
         IYVH3843fsz4ValbAcrlfx7/Fi8mF5KXcxbrukGYj3xWVRUz+Gk50iCfpPWRzF+DvTbR
         LRmlxBeFdq0VoTBqVljyhFq6paxGdiziW7vhU=
X-Google-Smtp-Source: ALg8bN6ENcIppHwHJfZ9Pot+DtaRMePk0FeFzNPj46Ihtl46V9A1CMs9WBV0x8ugovRz1Grbej5V07lZvgVzqNZZLpU=
X-Received: by 2002:aca:4506:: with SMTP id s6mr28611606oia.115.1546459534608;
 Wed, 02 Jan 2019 12:05:34 -0800 (PST)
MIME-Version: 1.0
References: <20181203170934.16512-1-vpillai@digitalocean.com>
 <20181203170934.16512-2-vpillai@digitalocean.com> <alpine.LSU.2.11.1812311635590.4106@eggly.anvils>
 <CANaguZAStuiXpk2S0rYwdn3Zzsoakavaps4RzSRVqMs3wZ49qg@mail.gmail.com>
 <alpine.LSU.2.11.1901012010440.13241@eggly.anvils> <CANaguZC_d2EBmNuXtcJRcEcw8uXK234tYSXx6Uc2o9JH_vfP4A@mail.gmail.com>
 <alpine.LSU.2.11.1901021039490.13761@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1901021039490.13761@eggly.anvils>
From: Vineeth Pillai <vpillai@digitalocean.com>
Date: Wed, 2 Jan 2019 15:05:25 -0500
Message-ID:
 <CANaguZDcJa9NxZU4Z3Q7DqvQK5zsDXZKNbhbO8fcppnYrTxMHw@mail.gmail.com>
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
Message-ID: <20190102200525.an9ox28mscSUDBuRfJMnx8izrZSPu_IIWYwXNaeRxXY@z>

On Wed, Jan 2, 2019 at 2:43 PM Hugh Dickins <hughd@google.com> wrote:

>
> Wrong.  Without heavier locking that would add unwelcome overhead to
> common paths, we shall "always" need the retry logic.  It does not
> come into play very often, but here are two examples of why it's
> needed (if I thought longer, I might find more).  And in practice,
> yes, I sometimes saw 1 retry needed.
>
Understood. Sorry, I missed these corner cases.

> I don't use frontswap myself, and haven't paid any attention to the
> frontswap partial swapoff case (though notice now that shmem_unuse()
> lacks the plumbing needed for it - that needs fixing); but doubt it
> would be a good idea to refactor it out as a separate case.
>
I shall rework the shmem side to take care of the frontswap and retain
the retry logic in a simplified manner.

Thanks again for all the comments and insights..

~Vineeth

