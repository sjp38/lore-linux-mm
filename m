Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28B75C282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:47:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD2542190B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:47:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="bCg7kSok"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD2542190B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B8508E0002; Tue, 12 Feb 2019 13:47:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 668608E0001; Tue, 12 Feb 2019 13:47:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 557568E0002; Tue, 12 Feb 2019 13:47:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 26A688E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 13:47:29 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id b8so2249039ywb.17
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:47:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=NHgwJW8uZa1+IvdRZWLjiQxpHR7wp1gc5jbfvmSpeBI=;
        b=kcbIsNz6EHulAZaRSaXbsGqMkuPBZyW3KEWIF8EEbwxU0PDIKBvmzjb+ppewyaGsgc
         f3VrNOapv4twP/PBZzwz9Udfg4V2QytuSEiqkQClHm07CDU7ZWx93Nt2jCGB7rO0aXRB
         lYcqj7fFbFWA8e+DmRKgLozqIq0YhgJdf4WhtF5uWu36z3XGgHudA4LusL1nTed30LOJ
         vBOEsVyBkid8yAcxXcq3I7QkefMATRjNHMfDMQMgc3II23ZBfIr3hE8pPmKM5Y+49/Ec
         ugiC1tLo1kA5EIVnaejGQh8hJciC1Rbw4ANZmogPTjCAOXQQ182U7RupJnbbmRcVhPty
         nMfg==
X-Gm-Message-State: AHQUAua2VAb2dVWu04FzgtzwXGmkQyYNgLLApsulsMj8JxFCsb9fl2fu
	QHM7FcQlAO87TR0ADhbZbM336hNxrS1t2IQfHml4vZ5+/sGbBRMZqt7YXGtpmtq/KJau1KOxAPB
	VfDxCrmRhgO6dAJfxEEE4jb0TOlq+zJ6WxUSZMqCwm5lnHriPBcpXe9RqxqiOidycUHkQa9Rj8b
	0lzNT09o5kCI9M0CUV1bp8mWYwemgkpJBmSN7i5Avv8io9c83VwAP/ToeabsC5kr4hMSgPs5P9H
	Q4k7GCPiIH+nibu5Qw/OXe50aIqlHRHZMG2snGX57UjWMI+D7H75UHFcqTq8NkTNcYUqxEFQQfr
	AbpynK//qrTWBtOfDhiLrprgrR8kTQtjI7Y4RHrpHQn4OcHDkQaRCfoRd5q/QtFrDLMMpuOn2Y+
	g
X-Received: by 2002:a81:3c47:: with SMTP id j68mr1401738ywa.69.1549997248766;
        Tue, 12 Feb 2019 10:47:28 -0800 (PST)
X-Received: by 2002:a81:3c47:: with SMTP id j68mr1401651ywa.69.1549997247427;
        Tue, 12 Feb 2019 10:47:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549997247; cv=none;
        d=google.com; s=arc-20160816;
        b=Dwwtc2HGfeeHuVHfiQZDgkCC/XIUmrxVD33yiMRwKyw3cy6MFRFnf5Z0hX9iDq2DN9
         TDpFS7luWrP2kNPEoNQvR6MruefCqZzDv79EEjLUeggW1aDQ0cjcqas/0Id5GSupwMCn
         QAj5cZA38X7L7oVGXWbRalISGnLgIzMN7ryN2n3EUyijlElw6csWco2OLCUg1pnBmJha
         5viDrKW9ShcUYrpXxnuVmfv/Rkce2sYSgjl5lM61zJOWjPJWwJCjw9lIPS58rvuYqjFO
         OyZEvwKLaKPfmuBkWQ8TTvVkPHEbqMp1iHjO/kTpgIQaIihHs/Vr7BPKclVHQXgstFCu
         MJfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=NHgwJW8uZa1+IvdRZWLjiQxpHR7wp1gc5jbfvmSpeBI=;
        b=d2hkPZM0IU5TPjiV+tx51u9QbUZjKVCje0nDj6/cQ+Hy4fnv9/ZHBpl2JTw9sQLVZD
         fOVAH8jhuRi/KRkuXvN/pZH1PWT9OXgPBSRPoCkmbJMFhb3mIHiXP9aPxO8Wd0pzeZU/
         U7WAtdehtBwu4z+/UydwgVwDD/fA9rndy8JqbCVe6Ix+jxSr+W6EMcGoxxSMYUh5E5YO
         HZP0XZGkRawQhhGc05lon/ZPJ87SG1oPgfpwdZet5bxX1OR9ojXcDxpHhJwdWdYJ8EiU
         +cg2olNxiDF8EnE68uN+Ve5OHU1CC3SIDeaUhMKsJLvwyyiRt7BcnEBm5pktXYODRsr5
         96aQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=bCg7kSok;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p131sor6903882yba.167.2019.02.12.10.47.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 10:47:27 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=bCg7kSok;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=NHgwJW8uZa1+IvdRZWLjiQxpHR7wp1gc5jbfvmSpeBI=;
        b=bCg7kSokGrTdQuBARH3O2Nhzc9WlfTeQ+dtwHWXUq8FY03gFuSmjwOa27VYdYL6r9f
         ycv8bQvneBI0LpeN/3T+N7HhFHyZHDGgx8GXwdwcC1kUnVdGVh1L9k0gydFUjw1PLI2l
         5pVhOnK1GDqV/uNs0hhwBWvIrDiIGl60RrKhy9Oy3nHZ8oECt2xwFF7a8L2vSR3cqX7x
         c1FjWP/BAzVD9n8OYBFun6pRHCgO8FYIW+ws0fUzLJ5hCwZchsxkr5aRcNVOL+4vDDnL
         EX+VxLAM0y0SNb1r5DT/RTkOt9zTqGGW5HDoktGG2uYO1Vuxg/FwNLgd4gZh1v2h46Su
         MjxQ==
X-Google-Smtp-Source: AHgI3IaQHJL8sj8e3YvFWEGuPHknSiaKLw50Q46hJ9x70lqKEK4DXNI2Ft7jqYE/pbh+h08dEyhTkw==
X-Received: by 2002:a25:c207:: with SMTP id s7mr4123285ybf.37.1549997246781;
        Tue, 12 Feb 2019 10:47:26 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::4:41f4])
        by smtp.gmail.com with ESMTPSA id t10sm5228536ywa.17.2019.02.12.10.47.25
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Feb 2019 10:47:25 -0800 (PST)
Date: Tue, 12 Feb 2019 13:47:24 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Roman Gushchin <guroan@gmail.com>
Cc: linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>,
	kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2 0/3] vmalloc enhancements
Message-ID: <20190212184724.GA18339@cmpxchg.org>
References: <20190212175648.28738-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212175648.28738-1-guro@fb.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 09:56:45AM -0800, Roman Gushchin wrote:
> The patchset contains few changes to the vmalloc code, which are
> leading to some performance gains and code simplification.
> 
> Also, it exports a number of pages, used by vmalloc(),
> in /proc/meminfo.
> 
> Patch (1) removes some redundancy on __vunmap().
> Patch (2) separates memory allocation and data initialization
>   in alloc_vmap_area()
> Patch (3) adds vmalloc counter to /proc/meminfo.
> 
> v2->v1:
>   - rebased on top of current mm tree
>   - switch from atomic to percpu vmalloc page counter

I don't understand what prompted this change to percpu counters.

All writers already write vmap_area_lock and vmap_area_list, so it's
not really saving much. The for_each_possible_cpu() for /proc/meminfo
on the other hand is troublesome.

