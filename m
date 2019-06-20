Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2CAAC48BE4
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 14:16:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B5ED2084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 14:16:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="AQ386KG/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B5ED2084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 200A88E0003; Thu, 20 Jun 2019 10:16:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B1678E0001; Thu, 20 Jun 2019 10:16:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A1188E0003; Thu, 20 Jun 2019 10:16:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D44318E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:16:54 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id j36so1834422pgb.20
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 07:16:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=9iRebO6DLKsf5fGTm7JWX4wTJr9M2g78lVVOWiI329U=;
        b=CcpHNqo2kh9dioS1NmuMwihN2soMOGWkfykDDYKl3pgiYi5ARtAGpwb01VrDJLjiTH
         lHxvKwkrWLYk9pEHzmSkHYd41zBlk6MG3/UTp5GSLQmLLke86pdQgefG8n+Hphj9DZ5k
         BK4j+Ko0sx0ygXTSr9h6for1sf5c/VIGJivJvTDd3HPtA8t7W8S6QyH19xc1+gchQVx9
         sl0rQVEO1MGzsRyivIVBpb9gNRf/zUk+f7GAJ9aw2SB0l1JGAe3D/bjowltqYyV7Rqkd
         6JUpAa08ZiWKTpyPQAd4nvucIyOqC2UvBgkrnLTR6I2wTvSo2rnZ8nohc8QaV+aQivBm
         ahJg==
X-Gm-Message-State: APjAAAXMAkKYRy4cnoS1bHs94g+B9VK+cy1JO/jJsjlsOdDteFEieDq2
	TZoDnVgob7IL333t3scwO/qmPLYNOiIl+RATJsTotVwy9S8AU3hb1Rb12CiK/G64tQJcxQWJ87H
	w73V0O66Bk7+s7t+7w7oVU8nB6uL3Z5V2Ix+HW+IOsZevyHJCu+804qLTcGcKK3zHPw==
X-Received: by 2002:a62:4dc5:: with SMTP id a188mr132712411pfb.8.1561040214418;
        Thu, 20 Jun 2019 07:16:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlB3E1A5qU/2pL3XB3Vl/ZkRPiVUr4RMgonQkDc3B17qGkLRsNP3mSZTOwYOkG68HIBjgl
X-Received: by 2002:a62:4dc5:: with SMTP id a188mr132712308pfb.8.1561040213156;
        Thu, 20 Jun 2019 07:16:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561040213; cv=none;
        d=google.com; s=arc-20160816;
        b=F8at4eB+nTO0Nst/mdunjfnsFRE6OzzoSRjWBUYl+Jn8mWPMoc/e7hSp09ll7DQcnP
         zHDOXVX49AcAn3zbpD+Db30ozru4xYwMuclQXHw9tZyQEDb0E3rgztdO8U6OxlZzFcb1
         aQm3Z/qJBMQvZ77IAIjkvKLUKbOpvjAQ0jdGjveGkQLB3/9XxJtYrnvBCO4lkG4xhIY2
         2KXywZ4bkJB4Ip/a9R5r4X6Ows5Q9uI8pfTF06yVgMlDbJHI7SOuFCRk0wacZoF3m1P2
         IdJk8kTEVCId8hSZ0L8UUHVJniXcIdp5FQf2FOdxDHEsDUOH+4rmuerANSxlOFQYnHO1
         7yTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=9iRebO6DLKsf5fGTm7JWX4wTJr9M2g78lVVOWiI329U=;
        b=o76EXP3jHuokUiAU+wJb4vXrFsRwQpGukX5/hImYPXR+YpBFhbxLhWGYjwy+Vu6ZxU
         Qf785vZfoMcaAHI4bC1puUBiKBNyDn4H1pO1FU3wlWvWg0vbJxGieuTqPGhpA9YjYhSn
         KJmZ9N0X2e6z3hF8fHWoFTmDDkAjCH7M9xmO5Y8ekji8YGpPfIsbzA/aMG8ENYejJZcq
         nIHNAw6rIMgTtBzwGF3VBRPDtRrY9tnuSfl9D1AMMYOx8xqguYYZ/tl+cx0XAZQcJy54
         3fGvoOQ/n5KKModQp1es5wdcvFqlS8PSMsVlzR7+1c/1TSN65W6B/LBsxQgcFcweARkd
         cshQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="AQ386KG/";
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k137si5943191pga.59.2019.06.20.07.16.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 07:16:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="AQ386KG/";
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1D7FE20679;
	Thu, 20 Jun 2019 14:16:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561040212;
	bh=9iRebO6DLKsf5fGTm7JWX4wTJr9M2g78lVVOWiI329U=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=AQ386KG/y054gecT++bUjaurqIH56NLWa099TjUwJEjpUaMR3NnklNkw5IMY91nvl
	 A4T5XvHW8nMYJyYDdXM4XASK/i/EyvBfTEpJL7WaHAcrUkt93Ey/qGxp0yy+QrtgYz
	 uO66rXsb1iNid4qAoefbvCvX+fgVNlFzyk3aD3DI=
Date: Thu, 20 Jun 2019 16:16:50 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: akpm@linux-foundation.org, aneesh.kumar@linux.ibm.com,
	jstancek@redhat.com, mgorman@suse.de, minchan@kernel.org,
	namit@vmware.com, npiggin@gmail.com, peterz@infradead.org,
	will.deacon@arm.com, stable@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RESEND 5.1-stable PATCH] mm: mmu_gather: remove
 __tlb_reset_range() for force flush
Message-ID: <20190620141650.GB9832@kroah.com>
References: <1560805037-35324-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560805037-35324-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 04:57:17AM +0800, Yang Shi wrote:
> commit 7a30df49f63ad92318ddf1f7498d1129a77dd4bd upstream

THanks for the backport, now queued up.

greg k-h

