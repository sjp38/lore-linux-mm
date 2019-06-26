Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E35E8C4646B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:27:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BF9C208E3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:27:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (4096-bit key) header.d=d-silva.org header.i=@d-silva.org header.b="Q21Tz7lR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BF9C208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=d-silva.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 451906B0003; Wed, 26 Jun 2019 02:27:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 401618E0005; Wed, 26 Jun 2019 02:27:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EFB08E0002; Wed, 26 Jun 2019 02:27:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1115D6B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:27:53 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id 75so2938837ywb.3
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:27:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=bKtMuDo5CBGijAA2QTa7J4u84nOp4WnkLSmd5PHCa6c=;
        b=hzWj4jY6JA3ixASjAlIl0xFrOouPZwfNwnrDTP0Z0W/Wp12tImiDzO2ICROACHxKaS
         zTnKnFnQGpRkx+aBC/moYAbZ72yngEUBc7Jth1bBKtx1TblTwNs+HetR59FuFJbW6q9B
         RR9E5lkH115VJJhAKFcA1oGFbEtG/66kHR1XTXLWkB9dUb43+GbhM7uLHCAP5T3YEx3E
         3yAWWcjXGt/QWmS1iAdDNkfVZAQxbzUktMZYhMhfLBzOjcUKjFFArV3BYyFO5q1eBUgd
         1hbfPpzOqxw0RpH6yrAMU0HVyXrE7XOET3rQThjFWuffBB95qhg7pSlrIcWSFTtvBSu9
         UrnA==
X-Gm-Message-State: APjAAAX6lk3nw29JbfqprhVx6NS1gSx7MlBEQ9Fl0JKIe+lUcq1TnxVK
	AuSsCuJXSsHL4c7AoUpEQR+5nhjOaSLvUvDbQIJqYhAeSVIXO12Nvs28FqO9g/1cXJxntvkx7Ui
	uSwml/I1OCULeOrSbWI8F84d16Mn9BgTng+loux6r094WZvB4qzaObl8VJ+tGEuuivw==
X-Received: by 2002:a81:794f:: with SMTP id u76mr1545927ywc.438.1561530472762;
        Tue, 25 Jun 2019 23:27:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrKetUB6Z2SfYBd3DP0J9b0xjJhCBMX8jo8rUvWNGr93D+Hy3jkYSp5zfZkVWS6fcQVMwT
X-Received: by 2002:a81:794f:: with SMTP id u76mr1545915ywc.438.1561530472237;
        Tue, 25 Jun 2019 23:27:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561530472; cv=none;
        d=google.com; s=arc-20160816;
        b=bY/9FtlI+1nZknGtmsR54xAtUVejxmAUmHX9XVpA4AVkvf7D0s9irDXdduFHJoiIbC
         DRluTdV0Z115CcWWHRNLz+alRY7oPTc3knXeIf+moBXyOVIuwUiFXhByygelVGDEK3jR
         +7IIAp/N7xukWo/JACyMAljY0zutHP5tOm63GjCcOhl2/G7eMW3/ZcRTwmYvD0jZjIfn
         oaIJ4ja8MwpfUje2bsCEJPP1GeCCBkuT7Sn0pMEe11oUEUYjTRKogRitUi+Q9Fzi0Vfc
         XEIukRj7cO+5LGYLVsxzGlVZu4GtEXJemaIhTfEqIBsSXcRnDs7qkS4zzz03RIoy1JnL
         ARMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=bKtMuDo5CBGijAA2QTa7J4u84nOp4WnkLSmd5PHCa6c=;
        b=JaXseaIVy0ljjc9RZ2M2DPjZY3oGlR0lJJ3dgpC8zG08O3uUsddBLYKXq0jgIP0AvG
         ylLcNvS6x5tjw+03GbuXWkJtaWp07GUygiCWIVjhpDk2qMel/cAOLZnd3VpkHWPc7xm3
         1LbNlCTgy01d/Fl8o/heGUcK/tEZavhZttg2BbDxB0uLo+5m35WxmTf9k+EeUl8LFrFW
         GcOfCkM9V2KafyK38QxmfXcpWJwd3iuiju9dyOqi0JifngafcJQrvTpPKyIn9l77gqAW
         Xo8o5ovj6XLl0v3aoh6W36quxvrRHe5ud5DarmZ5fXYhzqNektYBIo6h40Ur5/EKKZhY
         cXsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@d-silva.org header.s=201810a header.b=Q21Tz7lR;
       spf=pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) smtp.mailfrom=alastair@d-silva.org
Received: from ushosting.nmnhosting.com (ushosting.nmnhosting.com. [66.55.73.32])
        by mx.google.com with ESMTP id z15si1358681ybm.157.2019.06.25.23.27.52
        for <linux-mm@kvack.org>;
        Tue, 25 Jun 2019 23:27:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) client-ip=66.55.73.32;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@d-silva.org header.s=201810a header.b=Q21Tz7lR;
       spf=pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) smtp.mailfrom=alastair@d-silva.org
Received: from mail2.nmnhosting.com (unknown [202.169.106.97])
	by ushosting.nmnhosting.com (Postfix) with ESMTPS id 564052DC0076;
	Wed, 26 Jun 2019 02:27:51 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=d-silva.org;
	s=201810a; t=1561530471;
	bh=OS25pYQAzwyq/F3INQW54JWjpNG6XHKsOQWiwDyVPqw=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=Q21Tz7lR78e1eemh5m852Ojib2t93ty4XFBF7dCSVVis3DHkZzvrUOFHElfcxKdLv
	 q/t/wHkAcJTNEW0HCTFTfr2/1bFZkpoEXTNoVWPzqKVYTCxmYHZMZrtrNAlVlAbKF/
	 70JKnrt1+j9MfeFV605Z5onDRpjOz5nNq+BFQr5rekm48xyZnlOnaIkbEXEpwCBl+k
	 Epz3Vjzb8AjDIU/bLCG8ruewcAhawikBevodxWFoCUuERO64y09eYCcjOndShCmIgT
	 SjqcBms2oRSr9wG6P2VS7YBLXdMpADrF4xeismseo+DV1As/fdHSyXJ07QRxVB7bF1
	 h09ETdy6rxazcdLd090RnGVi1a9GVlTeG8Ui2qRxCv4/HkoGO6COIFM8ZM7BIrCUmc
	 nfzMMShBzd4ZyBHhQJLFTSkb+zPFzWoDkF8OeE5rQW5u0ISLKXuMtBSWVoCSLSIHMl
	 fmfRiW2EtlIbZOY4ccuXdCY1XQPUYCqfvJoFvko5OXXrCRzwTIX1JUWy4vrDb5p6V/
	 aN+ixIv4VdyliDdu4t/TRSRV2T8SkMh3WuZv57BpOsjKJ36e5cCJZZHJJ95uJWZGxl
	 LENT0oVU7VEkN+q3p7xwugpmcPhWPxmOCpFOwgNvjmpHVbsZTz+qnatEKr0PQ6fb7D
	 G86MLOLS5xE4BFdAZ040YlAQ=
Received: from adsilva.ozlabs.ibm.com (static-82-10.transact.net.au [122.99.82.10] (may be forged))
	(authenticated bits=0)
	by mail2.nmnhosting.com (8.15.2/8.15.2) with ESMTPSA id x5Q6RUtW031358
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NO);
	Wed, 26 Jun 2019 16:27:45 +1000 (AEST)
	(envelope-from alastair@d-silva.org)
Message-ID: <d4af66721ea53ce7df2d45a567d17a30575672b2.camel@d-silva.org>
Subject: Re: [PATCH v2 1/3] mm: Trigger bug on if a section is not found in
 __section_nr
From: "Alastair D'Silva" <alastair@d-silva.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "Rafael J. Wysocki"
 <rafael@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Pavel
 Tatashin <pasha.tatashin@oracle.com>,
        Oscar Salvador <osalvador@suse.de>, Mike Rapoport <rppt@linux.ibm.com>,
        Baoquan He <bhe@redhat.com>, Wei Yang
 <richard.weiyang@gmail.com>,
        Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org
Date: Wed, 26 Jun 2019 16:27:30 +1000
In-Reply-To: <20190626062113.GF17798@dhcp22.suse.cz>
References: <20190626061124.16013-1-alastair@au1.ibm.com>
	 <20190626061124.16013-2-alastair@au1.ibm.com>
	 <20190626062113.GF17798@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.2 (3.32.2-1.fc30) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (mail2.nmnhosting.com [10.0.1.20]); Wed, 26 Jun 2019 16:27:47 +1000 (AEST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-06-26 at 08:21 +0200, Michal Hocko wrote:
> On Wed 26-06-19 16:11:21, Alastair D'Silva wrote:
> > From: Alastair D'Silva <alastair@d-silva.org>
> > 
> > If a memory section comes in where the physical address is greater
> > than
> > that which is managed by the kernel, this function would not
> > trigger the
> > bug and instead return a bogus section number.
> > 
> > This patch tracks whether the section was actually found, and
> > triggers the
> > bug if not.
> 
> Why do we want/need that? In other words the changelog should contina
> WHY and WHAT. This one contains only the later one.
>  

Thanks, I'll update the comment.

During driver development, I tried adding peristent memory at a memory
address that exceeded the maximum permissable address for the platform.

This caused __section_nr to silently return bogus section numbers,
rather than complaining.

-- 
Alastair D'Silva           mob: 0423 762 819
skype: alastair_dsilva    
Twitter: @EvilDeece
blog: http://alastair.d-silva.org


