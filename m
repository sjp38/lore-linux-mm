Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE261C4CECD
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 13:11:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86D29214AF
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 13:11:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kajB+luL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86D29214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD66E6B0003; Tue, 17 Sep 2019 09:11:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D86C86B0005; Tue, 17 Sep 2019 09:11:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C751A6B0006; Tue, 17 Sep 2019 09:11:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0120.hostedemail.com [216.40.44.120])
	by kanga.kvack.org (Postfix) with ESMTP id A70C56B0003
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 09:11:58 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 20FD0181AC9AE
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 13:11:58 +0000 (UTC)
X-FDA: 75944450316.02.kick81_8575611c11719
X-HE-Tag: kick81_8575611c11719
X-Filterd-Recvd-Size: 4138
Received: from mail-ot1-f66.google.com (mail-ot1-f66.google.com [209.85.210.66])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 13:11:56 +0000 (UTC)
Received: by mail-ot1-f66.google.com with SMTP id g13so2960944otp.8
        for <linux-mm@kvack.org>; Tue, 17 Sep 2019 06:11:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=CzecQDZ62zroHHw8m7sjMbru2dXenqLbLLNiiVj6NRc=;
        b=kajB+luLNeZ8dqEybrVdpqSOj6f2QJ0PK904wHnOUqAGqvkNyRcQ5AhL2JjWe0+FLx
         DJHAaig3vb2yKalhpIVOGgBpscbhtEy+eu2ppNf4MSrQsDOobWtJr72Tkr22cCZQHqfz
         REoRPq21IZ9hm51MWqVmNPbZ9LFqGpiUcAXtzPQQ0O17x7aBmBDMA5u1KqAJTTuYI7hj
         VXnyiAbY0WkZFo+TRpev/sfTHPfjzMJv4NGPiZkQ2P1KiMxcOiC9+QIExgYSnpNwMR9X
         Y0gAKhVGuWwij3onrYg7ZR30N5ThIKwTzhdU9rwnawvEZ4nJBRUhe7Q2gkuAtf/z+B5G
         uXDQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=CzecQDZ62zroHHw8m7sjMbru2dXenqLbLLNiiVj6NRc=;
        b=lRFuE+lbGgE2w1hWduBw7Do6o5pgDOqWgLno3XRANXaBE2+qitOKSFCgGOTw7ceSO+
         tx3Wv8eBycaAHPkFMM6mLJtQoc4yOC08xfhCgNFcqj9tqqecaPGP0ppoegAC0miVf0zc
         4gxA+wyQypwWGtUzokRT6EmVZ8v5pTChvpgzpcpI1GD5z9foVojLe3tQNTQLjv67N1OP
         EiLL+NtXj3e9E8WZlK7gOIEnl707GzufQWU8ytt1WcjUo2xsWaMhhb8Dn7F3L8bGVxRg
         43f/el/oFkSxXyM2MIPFdedk/ElMW+LIS1FFub5cXk5d/svze5JBWiuw6OOi1tHo0GXy
         TQDg==
X-Gm-Message-State: APjAAAXl8l7KF3QM0LqlDDR7KH2/ohIcaAxCXFb8B0yvvzOB8RDpgBSZ
	vhkIc5ELnyXqauK1UiGQ7VpF5W2qb2q55rNbAZ0=
X-Google-Smtp-Source: APXvYqy3689Lv0lWVZFmGlqW6cIme+LFBCl20Y7Uvk5sGT5jTr2Jsa3VjskkANQ4rp+f6kHELOYSCJdhw8f6ziUzfL4=
X-Received: by 2002:a9d:73c4:: with SMTP id m4mr2706556otk.369.1568725916216;
 Tue, 17 Sep 2019 06:11:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190916144558.27282-1-lpf.vector@gmail.com> <0100016d3ad11d18-fb812791-af73-43aa-b430-ba1889f1a85c-000000@email.amazonses.com>
In-Reply-To: <0100016d3ad11d18-fb812791-af73-43aa-b430-ba1889f1a85c-000000@email.amazonses.com>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Tue, 17 Sep 2019 21:11:44 +0800
Message-ID: <CAD7_sbE6XZkwV2OyBk863Vfuf86FzHNg-U8bjaWRjt3ohcJa8g@mail.gmail.com>
Subject: Re: [PATCH v5 0/7] mm, slab: Make kmalloc_info[] contain all types of names
To: Christopher Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, penberg@kernel.org, 
	David Rientjes <rientjes@google.com>, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001195, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 17, 2019 at 12:04 AM Christopher Lameter <cl@linux.com> wrote:
>
> On Mon, 16 Sep 2019, Pengfei Li wrote:
>
> > The name of KMALLOC_NORMAL is contained in kmalloc_info[].name,
> > but the names of KMALLOC_RECLAIM and KMALLOC_DMA are dynamically
> > generated by kmalloc_cache_name().
> >
> > Patch1 predefines the names of all types of kmalloc to save
> > the time spent dynamically generating names.
> >
> > These changes make sense, and the time spent by new_kmalloc_cache()
> > has been reduced by approximately 36.3%.
>
> This is time spend during boot and does not affect later system
> performance.
>

Yes.

> >                          Time spent by new_kmalloc_cache()
> >                                   (CPU cycles)
> > 5.3-rc7                              66264
> > 5.3-rc7+patch_1-3                    42188
>
> Ok. 15k cycles during boot saved. So we save 5 microseconds during bootup?
>

Yes, this is a very small benefit.

> The current approach was created with the view on future setups allowing a
> dynamic configuration of kmalloc caches based on need. I.e. ZONE_DMA may
> not be needed once the floppy driver no longer makes use of it.

Yes, With this in mind, I also used #ifdef for INIT_KMALLOC_INFO.

