Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53C52C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 11:28:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C1D12171F
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 11:28:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C1D12171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A64B46B000C; Fri, 12 Apr 2019 07:28:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A14DC6B0010; Fri, 12 Apr 2019 07:28:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92BE26B026B; Fri, 12 Apr 2019 07:28:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 474396B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 07:28:20 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id 41so4762756edr.19
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 04:28:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=03ENd6/uFGBm+amFRn6QXBuSnbJmqs/fgUqGi3J6GSI=;
        b=V8setmZ272Dj8QpuZvibryU68JPX1ypMsm/OxpmsiCj2jSHUU1aM9thPKxQahoOlDJ
         8skVRoQWVrIOqyoMWKMboEQ1QoY1k8LGY8kKrFU32GbNAWwboc4FNfmAEiO7lryuqgW4
         Mcwchod+qPruHKqT2GLMMBiOkLAkA7H+iau/osPG7gMNpXepwSLJX1T8IiwWU9+d7xF6
         OtyoysOYVQl/bRFMvYIT4jg57eXomj2cm8gazAYiubkMjEkh0cmjdaHSmv6bry2Qg/Gm
         pjpC1HUiKTUBSzUpFJ3L3pSDpfCeLiMQdvXFwMpRhPfMz7iYMPfF5Hq0Q8bbUcNjkV6l
         UJBw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.41 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAXm6zJU5gGRam0kuve65d+OmKG4zBqezE3iSrdfhV4nTMsrjjKp
	N8Kg7+QV7btkcqATIhEYGZcSuQ3rP/Gg4VKtKIH2B7XOx6vOCk3IUYiC/fCkbsbRvgfUkTq5Dxb
	BgBcjFuW3fHb+ViyVKJ0YUBryBE6sMzFO8tMiVn9HoS21HAjkMrJIdNM+IDio6dmk7g==
X-Received: by 2002:a17:906:16ce:: with SMTP id t14mr30690152ejd.244.1555068499737;
        Fri, 12 Apr 2019 04:28:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/w2hmVivKaA2ldkqhQGsjUoePSXWAOTDMM3908Dv9Oz219Ub8NDJJkPtW6D2vXIy2c4+Y
X-Received: by 2002:a17:906:16ce:: with SMTP id t14mr30690118ejd.244.1555068499012;
        Fri, 12 Apr 2019 04:28:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555068499; cv=none;
        d=google.com; s=arc-20160816;
        b=k+4haP/x8eE4ifCveSVs5lpSbgRkeVSK7d8ITbyL0Qj4TiDchhpsMrhPX9NNb0uLQI
         rpE/m7cqMUzk+a5BdRz68e9us25fCui/LmanaGhq5N1IOFZXEc2HZtQs0YuJDZz6SGio
         XtAJwi1eXUctOhqdeXrpDkw5DXOkRh0FluDCbe9HGVgj/yKeSaWtDOLFNAMp0yCqq8B3
         H4R137MGlwxJ6OrhrGgq9AgRucQxXs/BxcKTFuLzxtsobJwFx0rjeDFRXbJpdgjNF5Zn
         SvA0ljHC9O9wZgYGYl8c5Tt/+nSWpFjnbyA4XY1LSv9DMGZafS66HnAxvnkoOGD0Kwlr
         7hag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=03ENd6/uFGBm+amFRn6QXBuSnbJmqs/fgUqGi3J6GSI=;
        b=lTvMYjO3tIxYFX8h9wEtWpJzgU4jtZDpAchzvrIFzmRyRqH1ppM4d/+P4/+c/OHxUq
         P2XlZmefQFXbVRE04aPj/hS3S4K5z7YThcncQnaCp54EAS6CHaPqasfdYf8iKYSFeEYX
         iaxK7L/qbG0uccdiFp/wiPGYVZM4lZ99qI1zP8GdjiHo6CY+d6uIdK7xBeA/0c2Jrd5R
         WMNYEO522b0d0JpsfPxpTOIM/pjDfzBGZmfLOXLoO6zd3iTO+oe+0wmachZonqPEhzS1
         YUF3HXPS+/hV975hvuzuqtgnoZVhKVAnSb+Vesvx2q66x2meN1RJnfIu9pBW4naD9g9J
         JLzg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.41 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp21.blacknight.com (outbound-smtp21.blacknight.com. [81.17.249.41])
        by mx.google.com with ESMTPS id z13si3841235edh.125.2019.04.12.04.28.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 04:28:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.41 as permitted sender) client-ip=81.17.249.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.41 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp21.blacknight.com (Postfix) with ESMTPS id 8D840B8A7A
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 12:28:18 +0100 (IST)
Received: (qmail 4311 invoked from network); 12 Apr 2019 11:28:18 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 12 Apr 2019 11:28:18 -0000
Date: Fri, 12 Apr 2019 12:28:16 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>,
	Qian Cai <cai@lca.pw>,
	Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/1] mm: Remove the SLAB allocator
Message-ID: <20190412112816.GD18914@techsingularity.net>
References: <20190410024714.26607-1-tobin@kernel.org>
 <f06aaeae-28c0-9ea4-d795-418ec3362d17@suse.cz>
 <alpine.DEB.2.21.1904101452340.100430@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1904101452340.100430@chino.kir.corp.google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 10, 2019 at 02:53:34PM -0700, David Rientjes wrote:
> > FWIW, our enterprise kernel use it (latest is 4.12 based), and openSUSE
> > kernels as well (with openSUSE Tumbleweed that includes latest
> > kernel.org stables). AFAIK we don't enable SLAB_DEBUG even in general
> > debug kernel flavours as it's just too slow.
> > 
> > IIRC last time Mel evaluated switching to SLUB, it wasn't a clear
> > winner, but I'll just CC him for details :)
> > 
> 
> We also use CONFIG_SLAB and disable CONFIG_SLAB_DEBUG for the same reason.

Would it be possible to re-evaluate using mainline kernel 5.0?

-- 
Mel Gorman
SUSE Labs

