Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B376C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:54:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3270E204EC
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:54:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3270E204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1C246B026F; Mon, 22 Apr 2019 15:54:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF36A6B0270; Mon, 22 Apr 2019 15:54:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE2A76B0272; Mon, 22 Apr 2019 15:54:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 891996B026F
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 15:54:32 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id r126so650709wme.1
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 12:54:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NucAgZ2xCAUMp9viU+KpaGAhriOgQKHfNLk1DJTEJRg=;
        b=hnYfHmGuvwk5u94IONG2QARlH/8VDBVXq+tuqP8vovToTBnf6qAIRX6DMckMrPuVuy
         DQRbeATgUgd2rb/SqOV2HkySpLM9DYzMWl/gHqVjdsHlHxu43eTnP8l3+u/qdK/JeIqa
         x5Wgo65reY+Y5tjuaMvJ/EzOyoibH+pdX0zaRrQcRa8y85N/GOxk7BbG2cYpTzEdRmER
         8fVW35D+nqCJwxNs9CDE+CyrAgBptOclHGQYrfTwNjjL9rpM/5C4bSKD5389xbztr6b1
         IQd/ASdhlsluJJMJqRhf/i++uRGPIS4E95CzAn6f3zCqmBsJnYnoOqnm1GDK/yu6gEkU
         7zlw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXfzxzBPkiQf8i4bfSmfnih26f+PISmFwBFdl3mVVmzI3DulU0A
	c0Ft0ChEMjY4H1WBoKHaM4vKOUUXraGwxPrbUdKZMl21pvW95WoWGl9vbKPYqLF25kDYirz4CI9
	l1S8YlhVQ0VvxUvNvtrxJX2SRBHXNp320f6rqcEMWm4XSsqdFdrRdoBNQF7tVm0qIVg==
X-Received: by 2002:a05:600c:2293:: with SMTP id 19mr12911369wmf.77.1555962872147;
        Mon, 22 Apr 2019 12:54:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvHrA+QcVJ9c3tqbg3ZnXG9on5+mXyRIJb2mFoYs+r7CqeAN6uQI5ivq9qaJI+7DZKrJPN
X-Received: by 2002:a05:600c:2293:: with SMTP id 19mr12911350wmf.77.1555962871345;
        Mon, 22 Apr 2019 12:54:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555962871; cv=none;
        d=google.com; s=arc-20160816;
        b=oy2mN+oNb+aorZOom2Ut3zacG4RNP1jfKpi3YInpC6URn4Ws3q2s/A97xY7pto3Ubg
         ria8aZuHVrEZFTEIJ84WIlCYtZepuw1EMpfWKeZyWEPOXiR/R1fte7M4w805FdGAH1q2
         Lq7PcQNw2ptJEDt5Q3EBn2fLKqhJz01yFROspW+4bR6mg6kAEaedU0yeaw5+vOyXoeNY
         qmXLhN3fEJu0ILGuYS6AcwwNqAw8gUFXT5dGOSzKCNfk9bowxy8Q1ixND2Duv4JYJ3Wj
         kH0BuCUAs0raEKCASxclFaFtsmeLOyneuj3GCNiYX9QWJ+Vzq/h6aKizeZQBMHkmmzpn
         /KiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NucAgZ2xCAUMp9viU+KpaGAhriOgQKHfNLk1DJTEJRg=;
        b=ISyfvofgRwA80+eTaeW9pjFzM8RTmnBmTwEVR5xUsNrEbvCgyLqjiAKIBL91uGiL0S
         AnlPeECPQlu0+j30I7EjrMU77glWjMP196THs1ZJUI7rwpdBNYb+RlL3aErTjmjMHIW0
         v77I6f+tw8w/yHMG64yUcJx/1jJhWo2fH+XaLZJeZvApxDtuBnEOu3v/j4tJN3FmqjbN
         Mkx88X2yRTSvwFYVnQYcePzZ7ST2ZEXcPoogqSiqTH0aHwWl77g34kGOQrjPZghA6HD1
         kqmA7pLCpStgzEHAAHqS5UgSfvJSvBsw/VVNhdsLTR4Ac6dvRfCRZDz2QjbyPUbAbyjh
         kyvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id c11si10213383wrx.179.2019.04.22.12.54.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 12:54:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id EDBB668B20; Mon, 22 Apr 2019 21:54:16 +0200 (CEST)
Date: Mon, 22 Apr 2019 21:54:14 +0200
From: Christoph Hellwig <hch@lst.de>
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 04/11] arm64, mm: Move generic mmap layout functions
 to mm
Message-ID: <20190422195414.GC2224@lst.de>
References: <20190417052247.17809-1-alex@ghiti.fr> <20190417052247.17809-5-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190417052247.17809-5-alex@ghiti.fr>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 01:22:40AM -0400, Alexandre Ghiti wrote:
> arm64 handles top-down mmap layout in a way that can be easily reused
> by other architectures, so make it available in mm.
> It then introduces a new config ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
> that can be set by other architectures to benefit from those functions.
> Note that this new config depends on MMU being enabled, if selected
> without MMU support, a warning will be thrown.
> 
> Suggested-by: Christoph Hellwig <hch@infradead.org>
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

