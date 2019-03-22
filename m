Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B2E9C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 15:06:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC4B1218FE
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 15:06:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="t4bfZHjq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC4B1218FE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 682706B0003; Fri, 22 Mar 2019 11:06:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60C326B0006; Fri, 22 Mar 2019 11:06:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AD086B0007; Fri, 22 Mar 2019 11:06:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 043676B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 11:06:49 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id n9so1151847wra.19
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 08:06:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=mQ9n0LJWHq04GQyycgsbt63+kUhUfjFPp6Imgiozptc=;
        b=YjS/Qng+zBC5G6khMzNmbMCnIlo+TAgHET+rW9j7clOV35qGIrcqtEr/WUjXU4Bg4a
         uHzy3aUfeS2uj2VGpvw65aJAKn4pD6WIzX7Z9wbx8Lgwg9Gy6q++Q5jjAtpPyUrYFIqR
         oXunBqTAO/w6kEjO2jI3zeqQ0mcORZ9ZewBXgW9CY/DM2WR1+9O5SAcbofNCSsPDHsVp
         cQvivmNVONR0APDwu3Jc5kJXjRN4PWnTJ8a6HCLagXMgciwdPv1/ezvPmfguChaQ8h1z
         PEH54ImAME4kGzuEqN0/sP1e/kaneoFXBJHkGvogYfdWNGGqfrIxC9O4liuD0PDC9pdq
         /rig==
X-Gm-Message-State: APjAAAXcEUwksUZvOTAhrm+LHlcLnmgyWEvKX4v+S81wmg9uB09+5uOp
	hV54o2xbCw4Kk6yah4nYaDhJfaHEgOx6jG8eb+ujA8LCXTHjg0us65ZTatRhH9SHtFj4NwfiRvc
	98QA282W0gh6Tm110fTFmOxEN6H6T9pcWPw1WgYgFEwff4OpmrheaG/6JQTUkceQ49g==
X-Received: by 2002:a5d:4446:: with SMTP id x6mr2701059wrr.147.1553267208536;
        Fri, 22 Mar 2019 08:06:48 -0700 (PDT)
X-Received: by 2002:a5d:4446:: with SMTP id x6mr2701015wrr.147.1553267207922;
        Fri, 22 Mar 2019 08:06:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553267207; cv=none;
        d=google.com; s=arc-20160816;
        b=C0PWobniNII8U/ujmzSf5TiQxputW7HUATGIYhRAod8y1ZSKQpHSi04mFeGHvpp+GE
         07mugPdsFUwvq3IrW8Qj1JUJTjtlRGsMIICp4wr6H4th/TmcXt+DfAuuDQ2wVKTdD/57
         e1a44R2rl8QxDAPIRaOJx3Dh+P0CpWygMKDB+3zY/6gm3cJqBYdSBADAO0uVTgyTWkIB
         zEVxQkw4sttWxpyp2JjzAc4qB9VmDVTDvCMRFmPikH0VA7ycM45WPCdPa7M4Ks2xUg8X
         YsMmgUylPsiXCj8G1rDfJVbJhopqL3z4ztA110SETyJEsilFO3I3419AQl3FisFLL4+A
         aaPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=mQ9n0LJWHq04GQyycgsbt63+kUhUfjFPp6Imgiozptc=;
        b=kxDe5e8kIXtHrmWDIwM6y3jcfsG3omVzPNO4+uMm4E1nwVK5tGhCNdAJ0wQ/0msq45
         5bfSu3+s3HI8BtB7MgcqVwlnw5IT1TKZFbJgv0RicUCdL6Gy2EEFSlq55vGDi9lzTyPO
         PEeZcEQQ787TLVLQaodjieGi/zOwRVHPAipCDoslZ6VRYO+hn69cn59FZF6yKWHNS/Il
         rofDK2vnb+TEqlOMx16pP4Ng3Gg2NbhvKsqhiMFg/EssIT9lBPnLh1qi1MkuFC3o/bKY
         3XLuhm6dJ5TKeymQvlvYigkWhLTViet2P/a4y/gcJP9FCDT8gLQ2M6kmFaWaOVet8fHP
         Dpwg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=t4bfZHjq;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 189sor5464084wmc.9.2019.03.22.08.06.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Mar 2019 08:06:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=t4bfZHjq;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=mQ9n0LJWHq04GQyycgsbt63+kUhUfjFPp6Imgiozptc=;
        b=t4bfZHjqYlNcpYtbOTd0L2aL8YCrHmtR9jw4IXOpS4MH7a1j9hEA/EkLAVaIrYVSWW
         iG+Ru2fd+5vRNzfAq1wUg4XcUy8wpr9g+pnjcj3GOM8Kg6cwiTXlHWm8+mVQ4jxWDwBT
         mKqwDN8vorH0l/niQI2Vwwxw7HlAhsNq75efQ=
X-Google-Smtp-Source: APXvYqwjcWjNHVr1ddFCyMelUwuxcf9h9A9xdWYy4x0PENAFJZinzN6+H78/cavWFkt7o9sovEYSlg==
X-Received: by 2002:a1c:6588:: with SMTP id z130mr3498438wmb.39.1553267207534;
        Fri, 22 Mar 2019 08:06:47 -0700 (PDT)
Received: from localhost ([2620:10d:c092:200::1:a21b])
        by smtp.gmail.com with ESMTPSA id g8sm19619754wro.77.2019.03.22.08.06.46
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 22 Mar 2019 08:06:46 -0700 (PDT)
Date: Fri, 22 Mar 2019 15:06:45 +0000
From: Chris Down <chris@chrisdown.name>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH] fixup: vmscan: Fix build on !CONFIG_MEMCG from
 nr_deactivate changes
Message-ID: <20190322150645.GC32163@chrisdown.name>
References: <155290128498.31489.18250485448913338607.stgit@localhost.localdomain>
 <20190322150513.GA22021@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190322150513.GA22021@chrisdown.name>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.076362, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Chris Down writes:
>"mm: move nr_deactivate accounting to shrink_active_list()" uses the
>non-irqsaved version of count_memcg_events (__count_memcg_events), but
>we've only exported the irqsaving version of it to userspace, so the
>build breaks:

Er, "with !CONFIG_MEMCG", not "to userspace". No idea where that came from...

