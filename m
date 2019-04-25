Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7443CC10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:09:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 292AD20651
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:09:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kAxXHkZY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 292AD20651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3E116B0005; Thu, 25 Apr 2019 06:09:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C13896B0006; Thu, 25 Apr 2019 06:09:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B03DB6B0007; Thu, 25 Apr 2019 06:09:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 65C2C6B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 06:09:39 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id y189so5688922wmd.4
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 03:09:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=qDXe8aInWx7rrUFbUzdCjPGqVvpdtP3z9EWwVfzbZc0=;
        b=eUzQGCZ0tfSuoaht4ZMrt3gDWLK2oTNLUQJVSK1hPQBiKEYz4CgyuZjj1iDbHxDesw
         MfE43cN1VvoB0ffo3ypzwkDv8uc8fRNFFm1NGnom2ozYFBYQ2tcG1uQ8uFe+2mi9wvKX
         9AETkLR6rVRnuMzzNKqGl1lqfOAoyU80fM08v9UZQAr+oa3j/xPlUIr6VbY6HXRAPDkr
         VjJTdKgAj2Pp5U/TcUGyA6X+c/Y9QWrdIKQ03oZzC+OutU7mXflt0Q9a4CTdVjOpwI2E
         4tszFADgqFT3Jk0pg7u5mDvZ0D1TjiIN6ECJLwcd8yHCz1yIn7RMPfcgndV/guV3qHPM
         GTzw==
X-Gm-Message-State: APjAAAU+zUSgCWw2WXTv27LwUpUL4/4mP+v6rFRrxUKcLxoAmWjYkf39
	l5ZnAcD3cCfyTFBPVlC/0NUB5QzTAeBjFOMde8ITBNd2EcuIYzzJAxGG1z8whYYNtUsZKrK5hA+
	061cygnOuiYT+JEIF3vApm0rs2Ifputqfq2W4mycg6W18t/MhU6DQC8BAtN65U5I=
X-Received: by 2002:a5d:484d:: with SMTP id n13mr2576604wrs.219.1556186978995;
        Thu, 25 Apr 2019 03:09:38 -0700 (PDT)
X-Received: by 2002:a5d:484d:: with SMTP id n13mr2576549wrs.219.1556186978172;
        Thu, 25 Apr 2019 03:09:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186978; cv=none;
        d=google.com; s=arc-20160816;
        b=Y7bmch9DYxXDinqZQsOPa/FhiM4DjC+zadw2xSClREnUqYPZK4aTXfAR+8Cuud2gt6
         4Bf0CKdTWNXvgqUXmWiTXYpuHiA4JfeKxu8ZgLSfTurznNdhUxXKTu89MgTomaanqn32
         xu875QBdEIkwHXC6s7JpqBemXDoTbANGcGzsYn1PXPIOt0Ea200xifKMWGOl+tl2ZDdQ
         VdivEkW/wX+IGF9FF3Hwy0poQr6pCsbMJznV1Xo+emZHy7Sp+e5Lyv3K3S4Vn5nQI4Rm
         sddZzD5ZXOKC/Hshfd3ZC7TKfGD4xo5oh+w3JA/lzahbOk9DI7yCmNZWOkDgylWMWUzl
         DROA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=qDXe8aInWx7rrUFbUzdCjPGqVvpdtP3z9EWwVfzbZc0=;
        b=oJuJ5tMdy9NgJglcpbFZfySOuMQDP4x5mbsIkFBtOKqScscnPIMjo2V6fTy7VKTT4n
         f6QpyTVUeJdYhcCyVsaxWYrRYm3H49yrIP0bXYmwItWdXAxZfDln521WuJ8DKMfpEyKR
         233vGPqLztWjRd2r8bmC8wTWf/ILe2d05qWKGN1iWLN6jLBca8wtjWHZxPYA+u4j3pf7
         7xyqsshUkp7GEri4RRx7Il97RVJco6drbAtsNj4k/adztV3Zyq+HiYoXSJ28Qg73VUln
         uylrw+GSBFQhd9IN/lf3b4eVjrTGp1syXEmfy7pGExytQojiQ41cXr/rprEML79FtYBH
         HUgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kAxXHkZY;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l26sor12210019wmg.26.2019.04.25.03.09.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 03:09:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kAxXHkZY;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=qDXe8aInWx7rrUFbUzdCjPGqVvpdtP3z9EWwVfzbZc0=;
        b=kAxXHkZYy9zXKuU1mD/GV24mrHOTRf2dSE1dytqyDTE9UDI6Qs03UeV4nB5Yquf+nl
         1tep2U7T3Sryt2ngffH0HbGnWoldhLQYMgCmjjSkzwRogMPhe3prjnuLu6GRBIQdgUmP
         FO9A7NNqPP+fSPIriO0PBVmQlihNr+lRUE9kN3TizxGphIMjD0dAZh3pX8+TVTBIlEGM
         NvtAJ9V68fpOVi2Lsx5HMiib5OaOfiymoKlY6eqWti6BEHTZMF6SWGNJ9IBt5/IKPWow
         QfTd69DVj5A06mVnuB2nERuOjY3Jq4M3TbOja1rBzuWUVL+Z+FGC8ZLEkNP4i5JfSmzV
         aAvg==
X-Google-Smtp-Source: APXvYqx2GAh1uv+m48koOKK3YSqfB/7bnkVhISaxrxFGwOyRBo5NQ9XpO4CFxCAJqjHa83cweimVmQ==
X-Received: by 2002:a1c:6c04:: with SMTP id h4mr2890302wmc.135.1556186977884;
        Thu, 25 Apr 2019 03:09:37 -0700 (PDT)
Received: from gmail.com (2E8B0CD5.catv.pool.telekom.hu. [46.139.12.213])
        by smtp.gmail.com with ESMTPSA id c2sm19739225wrr.13.2019.04.25.03.09.35
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Apr 2019 03:09:37 -0700 (PDT)
Date: Thu, 25 Apr 2019 12:09:33 +0200
From: Ingo Molnar <mingo@kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>,
	Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
	Andy Lutomirski <luto@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Alexander Potapenko <glider@google.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	linux-mm@kvack.org, David Rientjes <rientjes@google.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	kasan-dev@googlegroups.com, Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org,
	Robin Murphy <robin.murphy@arm.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	David Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org,
	dm-devel@redhat.com, Mike Snitzer <snitzer@redhat.com>,
	Alasdair Kergon <agk@redhat.com>, Daniel Vetter <daniel@ffwll.ch>,
	intel-gfx@lists.freedesktop.org,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Miroslav Benes <mbenes@suse.cz>, linux-arch@vger.kernel.org
Subject: Re: [patch V3 00/29] stacktrace: Consolidate stack trace usage
Message-ID: <20190425100933.GB8387@gmail.com>
References: <20190425094453.875139013@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190425094453.875139013@linutronix.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


* Thomas Gleixner <tglx@linutronix.de> wrote:

> -	if (unlikely(!ret))
> +	if (unlikely(!ret)) {
> +		if (!trace->nr_entries) {
> +			/*
> +			 * If save_trace fails here, the printing might
> +			 * trigger a WARN but because of the !nr_entries it
> +			 * should not do bad things.
> +			 */
> +			save_trace(trace);
> +		}
>  		return print_circular_bug(&this, target_entry, next, prev);
> +	}
>  	else if (unlikely(ret < 0))
>  		return print_bfs_bug(ret);

Just a minor style nit: the 'else' should probably on the same line as 
the '}' it belongs to, to make it really obvious that the 'if' has an 
'else' branch?

At that point the condition should probably also use balanced curly 
braces.

Interdiff looks good otherwise.

Thanks,

	Ingo

