Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 229EDC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 13:38:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF25320989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 13:38:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF25320989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36CEB8E0002; Wed, 30 Jan 2019 08:38:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 319278E0001; Wed, 30 Jan 2019 08:38:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 193B98E0002; Wed, 30 Jan 2019 08:38:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A986B8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 08:38:51 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id l45so9445966edb.1
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 05:38:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gqd31/i4BHnhFzfydETNTSu3jZ4+YiDJO1wxnEnXBpw=;
        b=L8DAykEV55jY7R17f7sFgjQCA4LLNNCbTlGLvIckMW3AtlWOtuItgzN/APVJTGCu0/
         SFoZvcCjwor+WRBwm0haLC1aXO87F3mfFCUkHmUzLlqSXx9OFI+156d8nvPCO2h0k4gW
         unlPeJCtQL09YQdycbljOmIDsBhM3Pu6MvQ+7sk8CK/acG8m10SIQYJAzBOzB5QzTjBB
         S4in29X0VR+XMcj2ePborPyxKYvc376QsGAvj3KIjuk5PqXvdK2yDhmr+A6u17d94eLe
         sO+PKj+WbsBQwupVkrkGc3SUFZyVHtpznQQDmszJWk7WEjh8oPuvTgxNKHJRzQD84SPY
         61tw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of pmladek@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=pmladek@suse.com
X-Gm-Message-State: AJcUukfiTOVy5H2yZyI8iqdn4y/9mZZBF0aPHetmedueMOPwaDZa3Hrs
	VcOIDwdy0wrNRYGi3mgTiOBr0OaqEg1T3aCvtzSvvH9Yj5tuzg0Zx4UJJfpSKlhOUS8pBo5ws3A
	oWIubagAneKu0vGxVCsRyhe03gGHL3sn39FXhMAv9LHl8D5jhNyJ+M84D+SG+Jvc4CA==
X-Received: by 2002:a17:906:4d1a:: with SMTP id r26mr26886232eju.32.1548855531259;
        Wed, 30 Jan 2019 05:38:51 -0800 (PST)
X-Google-Smtp-Source: ALg8bN528cSWmMgHKWpOk+I8Ihx0Da/D/bLay/v0+PuPg2NOqPqzLpgAO1bS4jpUwHUp8uWaXoWn
X-Received: by 2002:a17:906:4d1a:: with SMTP id r26mr26886191eju.32.1548855530349;
        Wed, 30 Jan 2019 05:38:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548855530; cv=none;
        d=google.com; s=arc-20160816;
        b=ea+kOmD9S0ffeujf7cZWEs5E8N8YPwLFieJnB7l3Cb7pIEZG5TR0WMzbT78xYo7B/Q
         tD0K3F9uoFT6ClZxpX0BP0klMDf1e1PMhvqOCxTAzdpbqkTFZ+buvg9I5d5J7FN0HtTx
         lnO8S1LQWRNMrZs0OJljHMF4Uu3xYtO40H4VqSCxEVZvqEBDFcL46Ed3lN/QC1PyyYTn
         AZqqHdsaoApmKU8TQVhli1HXaqn3ccl2jX/DSiWKr9QW6wudhk5kAX3A28Pe1g1oMpaw
         PT0EN8dLXpwOGPlNVHdzCIIeI+ppkVt2xAvIZtD5Qfs7JVvhycScyuFWL+dPzmy6yM7w
         PkuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gqd31/i4BHnhFzfydETNTSu3jZ4+YiDJO1wxnEnXBpw=;
        b=M/OmAJa/bz8EwF1oLZusPKkdV70twr4eqjXg9mcG1o/9sk9tX3Y/gHBO4H6Fc/pPSD
         2g9Qlm4i4LuKyeNqdU3nFiXKxVGNOolKkZagt1yosHHcQ4rTFM2jXjRtYaq7HxJKEOm8
         VU10ExYdLkC9Lp1fPI0xz6KmD2nTE5KvkTsQ+D7BsYTu3bpr6W5o7nrlV8k19xzQJdzc
         RTYbul5+xPe7vOTn5JhNFABr0yFJLapz8pIPtXw6Qx0TepAQ0I7D4mhuttSgoeuuuyv6
         /kYEyy8Po16oSgNEj8FZGpvnZikdzH/K4KsiwN6xIXzSKUe8u9ChY0utn0Ha4ujwjqKJ
         Wrhg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of pmladek@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=pmladek@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a9si282066ejb.297.2019.01.30.05.38.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 05:38:50 -0800 (PST)
Received-SPF: pass (google.com: domain of pmladek@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of pmladek@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=pmladek@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DCEF8AE9D;
	Wed, 30 Jan 2019 13:38:48 +0000 (UTC)
Date: Wed, 30 Jan 2019 14:38:45 +0100
From: Petr Mladek <pmladek@suse.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christoph Hellwig <hch@lst.de>,
	"David S. Miller" <davem@davemloft.net>,
	Dennis Zhou <dennis@kernel.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Greentime Hu <green.hu@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>,
	Max Filippov <jcmvbkbc@gmail.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>,
	Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>,
	Rob Herring <robh+dt@kernel.org>,
	Russell King <linux@armlinux.org.uk>,
	Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>,
	Vineet Gupta <vgupta@synopsys.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	devicetree@vger.kernel.org, kasan-dev@googlegroups.com,
	linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org,
	linux-mips@vger.kernel.org, linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org,
	linux-um@lists.infradead.org, linux-usb@vger.kernel.org,
	linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org,
	openrisc@lists.librecores.org, sparclinux@vger.kernel.org,
	uclinux-h8-devel@lists.sourceforge.jp, x86@kernel.org,
	xen-devel@lists.xenproject.org
Subject: Re: [PATCH v2 21/21] memblock: drop memblock_alloc_*_nopanic()
 variants
Message-ID: <20190130133845.nps4itatl4fm6dcl@pathway.suse.cz>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
 <1548057848-15136-22-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1548057848-15136-22-git-send-email-rppt@linux.ibm.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 2019-01-21 10:04:08, Mike Rapoport wrote:
> As all the memblock allocation functions return NULL in case of error
> rather than panic(), the duplicates with _nopanic suffix can be removed.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> ---
>  arch/arc/kernel/unwind.c       |  3 +--
>  arch/sh/mm/init.c              |  2 +-
>  arch/x86/kernel/setup_percpu.c | 10 +++++-----
>  arch/x86/mm/kasan_init_64.c    | 14 ++++++++------
>  drivers/firmware/memmap.c      |  2 +-
>  drivers/usb/early/xhci-dbc.c   |  2 +-
>  include/linux/memblock.h       | 35 -----------------------------------
>  kernel/dma/swiotlb.c           |  2 +-
>  kernel/printk/printk.c         |  9 +--------

For printk:
Reviewed-by: Petr Mladek <pmladek@suse.com>
Acked-by: Petr Mladek <pmladek@suse.com>

Best Regards,
Petr

>  mm/memblock.c                  | 35 -----------------------------------
>  mm/page_alloc.c                | 10 +++++-----
>  mm/page_ext.c                  |  2 +-
>  mm/percpu.c                    | 11 ++++-------
>  mm/sparse.c                    |  6 ++----
>  14 files changed, 31 insertions(+), 112 deletions(-)
> 

