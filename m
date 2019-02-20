Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AEAEC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 09:48:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DADA92089F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 09:48:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DADA92089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38DC08E0003; Wed, 20 Feb 2019 04:48:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 315028E0002; Wed, 20 Feb 2019 04:48:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B7018E0003; Wed, 20 Feb 2019 04:48:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B060F8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 04:48:16 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id i55so9796763ede.14
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 01:48:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=l6QPj+ET07McvrRv8j8Lq0DlErHjfnWdlp4tCv1O3S4=;
        b=FO7lhzf+WIPUVq/t1k7N1bDwc0636gYAqVRTo3a6Nk1+MLuOgcyeH0odr6GKd4yG8A
         J8T3hAXqQog66SKa4JZFFWXriEYXkGB8FkcODbvftO79oJ9N4E7u/yX5hVVKGkThtGH1
         8wAb5x0N3jd90+TFTbMBej1GA4KIrRBTL2AYCiSnW4x8Pj6sTPBjtyvobU93BPuxmVI6
         9wR68fKUfUaeAihxYhlsrEAQWOx3OcdqZik65QI40OO3NNV0iFJocRKhMxAIio79BvLA
         hGaRgb0uItdgyopVK56iU+Vcxna36SSDcbWFIWs1BQzmPj4vV1TdrU6yIvSr70bFLVs6
         0WdQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAuZA9dLf/2Hp7M3lwaFrKy70NMFlgPh5ZyTWq1Wr/B6QUTJcfezW
	HOYTnEmZ++PXW68BnYCllvSlu+oZmp9WQa1VsHEFvbWYloE1dlqjYYgTvVifZg4A2wuY6azGOUg
	lSC0zuW8XbS7bftdkP/qI2W79D6TsOC7Yn9+eiRenah09bUj4qs9X9CjbkfBBm+8Diw==
X-Received: by 2002:a05:6402:171a:: with SMTP id y26mr21063918edu.72.1550656096268;
        Wed, 20 Feb 2019 01:48:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYYJF3J6+rJoQ10C+VXWoMVtEKGN7ifF/ZCRiAibeMTNbnbe0AMov7fWdxxMYhi5qYkuYG+
X-Received: by 2002:a05:6402:171a:: with SMTP id y26mr21063860edu.72.1550656095253;
        Wed, 20 Feb 2019 01:48:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550656095; cv=none;
        d=google.com; s=arc-20160816;
        b=tBFJd+B2o/DmISJGfuY6rEizzjXvCkAvLIe79vMCJ4itxPFsuUzqoQX3eWf8bpQBUb
         cLWd+rGgXEIFXE/y+yYwSobPLgpjvmoo8falNru3H34UnN5+/WVtmVWoKLV+/SR+4U4q
         C3focgiL3vFdHE1sfJz/CfaTs1u50Rjw5sAf3/c2HfGXy60JHhO8038gOXB0p4lVoue4
         CNZ2tKXApWntpomuN3veLfxgoOOR8lyrziQSKiovRExtEyCSJUiFFyRy9g1rbEPjapFx
         s5a5EgrNCwS4VsnTa51H0IhEOSIF0Sx1x0WPW8oGYqWvuKMaHYeaLl3v/SMSIjSvT5fm
         EL3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=l6QPj+ET07McvrRv8j8Lq0DlErHjfnWdlp4tCv1O3S4=;
        b=QHncT582eW6vRwfCnyBGyJcFCyel/+oeaETFyIlviS+qoXp+8BKOeyy8/SnqXfIzn3
         9pI1nPQejA0GLVZ+5r7nPMlpF6IlrhcKGxMp0Hlkvl5BSBq2dAEkkBZEZiT/gLilU7rR
         D9wVZEs6X27DnFChAoXmuxWr9sDnwqcIjQnOT4VfabLfCGHAipy7X6/zrj26o3eCEOSs
         crI7yQjq1JGQOs+PwtCg4bQPGNKFw+rHY9QCqe19UTELM6LFaciasYZLICRWYvFdO2zi
         L5JJlL37lDIxeeJwMfR7VCv1GuPgrSBOg/4AvcTySyU6WtRvQrRqQoRwXt8SuGEZdAhM
         MzCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t2si2885267edb.296.2019.02.20.01.48.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 01:48:15 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B9EFDAFBB;
	Wed, 20 Feb 2019 09:48:14 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 136A51E0880; Wed, 20 Feb 2019 10:48:13 +0100 (CET)
Date: Wed, 20 Feb 2019 10:48:13 +0100
From: Jan Kara <jack@suse.cz>
To: Meelis Roos <mroos@linux.ee>
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	"Theodore Y. Ts'o" <tytso@mit.edu>, linux-alpha@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, linux-block@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: ext4 corruption on alpha with 4.20.0-09062-gd8372ba8ce28
Message-ID: <20190220094813.GA27474@quack2.suse.cz>
References: <fb63a4d0-d124-21c8-7395-90b34b57c85a@linux.ee>
 <1c26eab4-3277-9066-5dce-6734ca9abb96@linux.ee>
 <076b8b72-fab0-ea98-f32f-f48949585f9d@linux.ee>
 <20190216174536.GC23000@mit.edu>
 <e175b885-082a-97c1-a0be-999040a06443@linux.ee>
 <20190218120209.GC20919@quack2.suse.cz>
 <4e015688-8633-d1a0-308b-ba2a78600544@linux.ee>
 <20190219132026.GA28293@quack2.suse.cz>
 <20190219144454.GB12668@bombadil.infradead.org>
 <d444f653-9b99-5e9b-3b47-97f824c29b0e@linux.ee>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d444f653-9b99-5e9b-3b47-97f824c29b0e@linux.ee>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 20-02-19 08:31:05, Meelis Roos wrote:
> > Could
> > https://lore.kernel.org/linux-mm/20190219123212.29838-1-larper@axis.com/T/#u
> > be relevant?
> 
> Tried it, still broken.

OK, I didn't put too much hope into this patch as you see filesystem
metadata corruption so icache/dcache coherency issues seemed unlikely.
Still good that you've tried so that we are sure.

> I wrote:
> 
> > But my kernel config had memory compaction (that turned on page migration) and
> > bounce buffers. I do not remember why I found them necessary but I will try
> > without them.
> 
> First, I found out that both the problematic alphas had memory compaction and
> page migration and bounce buffers turned on, and working alphas had them off.
> 
> Next, turing off these options makes the problematic alphas work.

OK, thanks for testing! Can you narrow down whether the problem is due to
CONFIG_BOUNCE or CONFIG_MIGRATION + CONFIG_COMPACTION? These are two
completely different things so knowing where to look will help. Thanks!

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

