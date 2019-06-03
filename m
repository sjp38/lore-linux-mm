Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACFB5C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:40:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E50726795
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:40:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E50726795
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 140806B0276; Mon,  3 Jun 2019 13:40:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F29B6B0278; Mon,  3 Jun 2019 13:40:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F229A6B0279; Mon,  3 Jun 2019 13:40:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B87886B0276
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 13:40:09 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k15so27563085eda.6
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 10:40:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=25Yc9Ik3R+Y6EnRn3h9uEr7/N0lFYvHeXCFez5voKhY=;
        b=lnVI9r8KVUjboX1pby96Lkuz0i8ey64RqHBJy71leuvslJoZknsPfadj+fgiYzgxn0
         zCaFTm7lrzssfdXQu63NRF/tF5QyIf+c3+LBU+YJNyZfmylQo/JT9HYIjz/8RuswVxkO
         MhqLyFz0zr/CldRqKgKelC1GKSO35+3ZiQ8CgR6CZJcynF52LJiJdwuWFTqaNGOIZdML
         +bwjC16GeCWqscyqgQv4QMWBuMuBUyT6+Jv9FPqw7nMV5jU7UeH260he8tSu4QInlsUm
         78nYnbOfFIoGxB/NeizlwayRaG2Nlh1kEGnY6JUheu0arscmaYjIo0LqRk/VROTnFIFY
         lR9w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXPgvMHOjjWHc0RQQJCFlGXQLKxHmwGvnXATx1EuRjTy6mvp70N
	CqeK8DU/U93Fzn2mzyGpfvAmc9OCvo8KYqZkuulexZiYJqG4bbIKQ7AWPoj6HaQ8TpB3w3kdnss
	P1KaV+s690Dt3+Abq6Mgc5Dkpr2tBI3zF8HtLqTBFrZsXAlOnG3GmX7awxU1rkYTl3A==
X-Received: by 2002:aa7:c919:: with SMTP id b25mr30421309edt.274.1559583609347;
        Mon, 03 Jun 2019 10:40:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwyO8K4FFYfwEZhrc4+ynuxjOXJefxHvaYIqNhf9X6Mx/mALrZcHVF5fH+BJye1RU1UEisv
X-Received: by 2002:aa7:c919:: with SMTP id b25mr30421222edt.274.1559583608474;
        Mon, 03 Jun 2019 10:40:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559583608; cv=none;
        d=google.com; s=arc-20160816;
        b=tt9d1vRTK/0QHxu4wW3U70hMoR3N5xLzKxbYHL5B93eXOJ1X4HzNlI/UhFCh5c2mkr
         PmHT+ohfIuP9iaDhbCNmQE4RF4kMcNkE5ZuRgwp/NalCgnokK0Ak6nLwr3Xb0OzllI62
         KUpo7cfKQO8iqRFN2cc9A/fxMMlNza/Xn0dfeGNwuFsSo/xxvdXJl3Los88ZmwxLLsPj
         kNbwTtzFSDv/jcRMeaYUzyCh7rB1SQbif9oAI0D+VQa4JEd/Fo6cHjqVAyJybz3brIFh
         qgsSiSbyQNaxTmwSNQgxzNN+edSq9FNqdTHZcICAn9HlHCC4Als6j/jJ2O693AWvHVoO
         DP6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=25Yc9Ik3R+Y6EnRn3h9uEr7/N0lFYvHeXCFez5voKhY=;
        b=cM1BXt+qsN3FewlldWj13ABZq2hjmJqSFnh3uYDJIGVnWLf/b99YxTc1Y3LKWPoKM0
         oraMEkXejFPaPX29MQsma1Xq3Jw2oOkCp8SD50JZAEBYZCllwiQX4ordFeQmc9j+bXEN
         enfgTc6+hBrhHxSUP6wpCJibGOB1KlHDNu78wS006a5EIhgN1Iuv6QJFyBVfm+Q/TlI5
         41Ts5oRfgL72gUoB7GACb8kmBPbqPK3fhqskGscXlPvM/I2T9mkfmN2OQBe/AGRFN7P3
         A/OYBX4HIEPg11KtsjPnQUF6YWXtT3glVZwsTSJmX/aZEWSjCGfzCG2lZyevo6bFjclM
         qPOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z25si6191190edc.17.2019.06.03.10.40.08
        for <linux-mm@kvack.org>;
        Mon, 03 Jun 2019 10:40:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 81C7280D;
	Mon,  3 Jun 2019 10:40:07 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6BC373F5AF;
	Mon,  3 Jun 2019 10:40:04 -0700 (PDT)
Date: Mon, 3 Jun 2019 18:40:01 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
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
	linux-mm@kvack.org
Subject: Re: [PATCH v4 05/14] arm64, mm: Make randomization selected by
 generic topdown mmap layout
Message-ID: <20190603174001.GL63283@arrakis.emea.arm.com>
References: <20190526134746.9315-1-alex@ghiti.fr>
 <20190526134746.9315-6-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190526134746.9315-6-alex@ghiti.fr>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 26, 2019 at 09:47:37AM -0400, Alexandre Ghiti wrote:
> This commits selects ARCH_HAS_ELF_RANDOMIZE when an arch uses the generic
> topdown mmap layout functions so that this security feature is on by
> default.
> Note that this commit also removes the possibility for arm64 to have elf
> randomization and no MMU: without MMU, the security added by randomization
> is worth nothing.

Not planning on this anytime soon ;).

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

