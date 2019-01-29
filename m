Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5CA7C282CD
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 01:42:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FD14217F5
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 01:42:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="PFO/i6rh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FD14217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06E088E0003; Mon, 28 Jan 2019 20:42:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F37448E0001; Mon, 28 Jan 2019 20:42:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4E3E8E0003; Mon, 28 Jan 2019 20:42:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0808E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 20:42:05 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id w12so7329187wru.20
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 17:42:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=CgA3sRNVMXk7js4c/E/CVOZKEVaE8DANGoI5NS4jIsA=;
        b=B/WrwiE2Smk0XJkO3ePc9j2pwjcgnC5Yhto14P+MpGjGLsJtABdnIumV4bHZ13FQK1
         T2i647PosqihylWUfRxFLIqpAyCrUb5bSi4cfv5lcd5yhtTNximYUVayghNLdvGiJVYH
         wZgiTNUrXb4t02oGNmNTLI98VZM1ruvVgUnM2MmoDcfJhjUV2zd2723BSKpigzhjkuxN
         YmCmRCG/1S7cglinC9DQfe2t/rhzJpi3hZBfKdNX1ciqgkRXcbMDCPR64p8LFnLSE5ec
         5KUJXy9laRCArgi37JMaJfVhMqbjemmaNYX8EsuIObEsoRjF2XMJ1FJDBVT/f+3fJJDP
         uYlA==
X-Gm-Message-State: AJcUukfruvajNK0CbIMpwH2nnMXpPvwM2T4R7+pZE9ZNY2CHhmAuuSbc
	TZaR1pcHh6tUn6VdkRnSjvKPtUvxy9jvDafMLNPC1fO94g6+D8mcRdSwJTZVial7GKlgb2w7o4E
	HslG3ogtbHRz52xuXM4+HOaFD6uWAOkJ6ofFOJY8bs4rxTug0w6nqqIf527fqssTeQ8UyWvEq6H
	Y8QjnB5J77RS6KkSnumjWsL8BGAEWlUx1IH3Z2jJ3bHy+8t2mkQI39fOZm4dEwevsU6GvNDiRLW
	NVPCyJcXBZnV+ajWOOUMiaBkwX6zzXu7UqRoguGm6owaKD4bNIlO/0IimptqqfiEqdkxiXMEbkV
	J2KItQowez5AYjjWI3OI9K5JCuc1MxOjN99xYts2nBVbha8n+SYTDncEGgPluv89yck6RezmVCO
	E
X-Received: by 2002:a5d:4fcb:: with SMTP id h11mr24336822wrw.139.1548726125083;
        Mon, 28 Jan 2019 17:42:05 -0800 (PST)
X-Received: by 2002:a5d:4fcb:: with SMTP id h11mr24336796wrw.139.1548726124359;
        Mon, 28 Jan 2019 17:42:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548726124; cv=none;
        d=google.com; s=arc-20160816;
        b=h/UQvTH7vHGS++lzDVs+Dl7nKxSYmxE2SF74meiG3Em0HoU9rnjqR/k5E+ixDMg2Tw
         gEHHQ9dMreO2Bbstsnr3I2oYnRsiZ2SBSfrjvD7Y6UnIae+0r4A4lv3MxGoprzTI3v+s
         oj0seuBt+aDTLKS378E14OgG3Nr5NOyG08eId6BR1+zYOx6WEHgzvVaOnJPJH3dqL9MY
         DxZ/xrk+31kLG6WLpsUJWC+rmCcrimAcgTE7Hk+Mo2LY+SWTc0bL9yu9kpBrx5rVeIRX
         sVCOGc+/RxAA3Du8nJd9U35l5G5uqyxoXIqxlgTKEQMQKeUGaQtu9VNhDVDpDBlvSm5o
         87CA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=CgA3sRNVMXk7js4c/E/CVOZKEVaE8DANGoI5NS4jIsA=;
        b=umTXAZ13Rd926urP8RaEp6QEBrdH5e+e65Jma/JJKchDMwKGgI4Eyf99+p0IS2xz3b
         q0Xd3YSmlBP1eror9cW1lDn75yhPRRUOoxg25K4ZYkTvn6pcw7x8kGzhmgb3kZRWK4rV
         Zztku9KxX+kv2KzXfn6BhWmzjzgDDbPKEVNLnJ4NRcJRK8MkvN1qz7IAlEtdRLNgu+qB
         EHKvQB/p8UtbpBVAVCBrYw5OVv7JitrlffFFPBUXf2TMPJRFirYJv34EdU5u8BRjPEOk
         gdwEzSgAIZCH7kQHrNifWli/NYeQsjioe551p1P80J9tFvm7Dgo5Na+N5V7esZb6qgPL
         AkGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="PFO/i6rh";
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n203sor721051wma.16.2019.01.28.17.42.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 17:42:04 -0800 (PST)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="PFO/i6rh";
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=CgA3sRNVMXk7js4c/E/CVOZKEVaE8DANGoI5NS4jIsA=;
        b=PFO/i6rhgf+YNrmRAo/R4/wZcZPGj6tRLfu+GLooakQVPwy4w3hgE1wFIEOX3TUidu
         FDuZuRhUsqVyTdGt7/Sbog4uLx+au2Wc+ki1mv2g4elLshnxy4VunOiv1wZdKdmDEooj
         JOvh0JdwciQX49Q6T7hVZg6bYAK8Sh6VQ46xUoP9EuImPbiODZTOhm75d0956bAayfRZ
         kiY6mkHGWMbxymUPtEmdYUaCiTnTc6R/Ad8Yuy+WeYXZNTn9WVnn6rPKPKbjEeiC1ah0
         ICDZMIsGrJvVazGVIpyYvnx1jfv4Z14alRWHdurPDC80P5jlxJYuua66USDLCuGzzmM8
         WKxw==
X-Google-Smtp-Source: ALg8bN6BYzwni8B73SnaSoCgIxcAaI59FvHE+qVEYDBAH8vUdjEBNZ7mKcIu14vwd6BG6o617Hezqg==
X-Received: by 2002:a1c:bdc5:: with SMTP id n188mr20341571wmf.69.1548726123691;
        Mon, 28 Jan 2019 17:42:03 -0800 (PST)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id h1sm1237956wmb.0.2019.01.28.17.42.00
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 28 Jan 2019 17:42:02 -0800 (PST)
Date: Mon, 28 Jan 2019 17:41:59 -0800 (PST)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Miles Chen <miles.chen@mediatek.com>
cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Jonathan Corbet <corbet@lwn.net>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org
Subject: Re: [PATCH v2] mm/slub: introduce SLAB_WARN_ON_ERROR
In-Reply-To: <1548313223-17114-1-git-send-email-miles.chen@mediatek.com>
Message-ID: <alpine.DEB.2.21.1901281739230.216488@chino.kir.corp.google.com>
References: <1548313223-17114-1-git-send-email-miles.chen@mediatek.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 24 Jan 2019, miles.chen@mediatek.com wrote:

> From: Miles Chen <miles.chen@mediatek.com>
> 
> When debugging slab errors in slub.c, sometimes we have to trigger
> a panic in order to get the coredump file. Add a debug option
> SLAB_WARN_ON_ERROR to toggle WARN_ON() when the option is set.
> 

Wouldn't it be better to enable/disable this for all slab caches instead 
of individual caches at runtime?  I'm not sure excluding some caches 
because you know they'll WARN and trigger panic_on_warn unnecessarily is 
valid since it could be enabled for that cache as well through this 
interface.

