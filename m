Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E391C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:43:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C6172089E
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:43:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="DWYPEU+O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C6172089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAD208E0006; Fri, 21 Jun 2019 10:43:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5E358E0001; Fri, 21 Jun 2019 10:43:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 923E38E0006; Fri, 21 Jun 2019 10:43:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 71FE68E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 10:43:53 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id y184so7739708qka.15
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 07:43:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=HyLTo1H3x89cnTVP/KrI5aPMZqdvKCPXXVZOA+DwKL4=;
        b=nhJ+PYbaf3MqtCEzwlIbm0n3L8P31rzc7mr92U7dJpukY6xTjXYQHBoFl6au/BLoq7
         277EFlSsHdANihENq/EWPaxNVTzdh38oUwWKFfVT5I/JKfSC5y1YnW9VRUnnfm3MgDyW
         Md/Go1Q9Or9mfsxDXG8xWnrBaYu/WdH7h+eDWuEK0RszNRaKByQrgt5IVhEdjd7X6Vw6
         Ki6MkCukOLJx57abwtoaO3WScdKkhrxp54+aYsTdJLrYlOnKAnNsROjYJaZtWsivimnb
         dz8Clb2FqzZLgAPT+aK4SN6nPJoiP3t7IjlSr9e8PnGTcRzRGpavzWMwmK84pf8HZEUe
         8qTw==
X-Gm-Message-State: APjAAAXf1W9UZjTG8jhbGtb3dGdHbqyAztaUdDMf03+HpvAheUAO5dDE
	h4QRuxBNlNrTU3VR3c9VHm4dSv4AfG9WDYQRRhsWHMESQpwsxMcJAMA/rxC3NW1bn0A2QK+Tacb
	/oTqh87K94PJ+OH/ALWnyjtLD2xVAfsajnjRLBl5KK4i+hfFeGCzgdO6ea2XxY7McOA==
X-Received: by 2002:ae9:eb09:: with SMTP id b9mr5717952qkg.420.1561128233257;
        Fri, 21 Jun 2019 07:43:53 -0700 (PDT)
X-Received: by 2002:ae9:eb09:: with SMTP id b9mr5717915qkg.420.1561128232819;
        Fri, 21 Jun 2019 07:43:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561128232; cv=none;
        d=google.com; s=arc-20160816;
        b=BGq9EyDG4qQ2xXXKVs6XN5gE8yMoiPGt+OVFeXqnNE4OZJVWs8C6RTGOboxuNqczS4
         3OdwHyYT+oKIuwT0mjaObpoIVWRNsRHQ9HXJOZo6GE+xYaa7fUvZa1d6WSuGqAYDzXa3
         in3T9nZkspNxqPergJgtL3HK2pS66yh6BLgWdfB6IbFmCmX7/YZ4J4H3SLKsZOUnmXCq
         EMFl/mZ4IYWZjSNodm8CU9/cInP339mAUn/G2OA5Bde4E74K5T3IXAog3RW5/v+GcLBq
         1LHqeR9nl4c+796KPk/hqTD0uIuPfRE15w6nlfh8VDNF143zWyjsZxO3QLc5hnYTNsCB
         xsOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=HyLTo1H3x89cnTVP/KrI5aPMZqdvKCPXXVZOA+DwKL4=;
        b=mtUVZshCbs1vsWEzezQrDLnF3yEDXCTMN+jJbLVeif7pF7iuTv87AG+Y0FtjMTzEuX
         p4P8AjxqWgCFcMG5qDbiE02q5Tj1CK+RMgCbU97iFQuyszoQKHtowGyyZIVukZn9S3UQ
         0qB4Xhpt1dwAu08fMHzs+zq71bo1P9JgTvuKgWuvs9Fgu6HR7DgFAlGicVPPpO3zUzLC
         82stpoYSPTL33J9qPtd0fpKwPN3t8jhoh0Fpkjp7/fRyvXBN97EdDy3eK1Tjdyn2mUKq
         nCpOQzpZTSH0VOSYbNaF0ll5iX/gDt5CuD19jU7YHggEvek8evb1Z8nF/5yk4CynQ5HW
         2JjA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=DWYPEU+O;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q41sor4415312qta.24.2019.06.21.07.43.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 07:43:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=DWYPEU+O;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=HyLTo1H3x89cnTVP/KrI5aPMZqdvKCPXXVZOA+DwKL4=;
        b=DWYPEU+O6hqxRZYo+qz30J5H/UJHIhDajRUaRnLPSd6vJcB6+cO10pe7lygHrzVfbj
         ylkZm9xQxBbaknOOEP50RPqZEIKs31Kv5m61QSa+a2j9L/tziw3EvpbXFBlYITisHOrc
         JH/mxK8KzRvGMQq7eEjJ0D1tfo1cCUkuw78siy8VrSJQvLItPReOk3pNZ79bl/uzqGdA
         xZjcp0ZATPU+rLVHRBIhFoOyYspIjuFb0uCU0LU9axGWIFyYR3JZqqXVHth78E5v4p4y
         7AeI6a+ZKHqzF3V2D6NrgjTVx68650ZaAGsz9YLXObQshjM/K+Dt60BoO4AIuRM7+FIQ
         tXag==
X-Google-Smtp-Source: APXvYqyhH+glrRwKSiAA7qbVYeB5QwqXO/U6RS0ZU2dwiG6C6t5mG7HajTG9DMxfijl7dMFHJHUwBg==
X-Received: by 2002:ac8:1ba9:: with SMTP id z38mr28772211qtj.176.1561128232588;
        Fri, 21 Jun 2019 07:43:52 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id a11sm1411650qkn.26.2019.06.21.07.43.52
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 21 Jun 2019 07:43:52 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1heKlb-0000wZ-Mn; Fri, 21 Jun 2019 11:43:51 -0300
Date: Fri, 21 Jun 2019 11:43:51 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: switch the remaining architectures to use generic GUP v3
Message-ID: <20190621144351.GR19891@ziepe.ca>
References: <20190611144102.8848-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190611144102.8848-1-hch@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 04:40:46PM +0200, Christoph Hellwig wrote:
> Hi Linus and maintainers,
> 
> below is a series to switch mips, sh and sparc64 to use the generic
> GUP code so that we only have one codebase to touch for further
> improvements to this code.  I don't have hardware for any of these
> architectures, and generally no clue about their page table
> management, so handle with care.

I like this series, ther are alot of people talking about work for GUP
and this will make any of that so much easier to do.

Jason

