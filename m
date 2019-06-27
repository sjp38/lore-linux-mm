Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC5E2C48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 00:51:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79E0920665
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 00:51:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (4096-bit key) header.d=d-silva.org header.i=@d-silva.org header.b="Tl3RrQYL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79E0920665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=d-silva.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFA6B6B0003; Wed, 26 Jun 2019 20:51:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAB6B8E0003; Wed, 26 Jun 2019 20:51:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B70FA8E0002; Wed, 26 Jun 2019 20:51:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 925716B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 20:51:22 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id q79so665929ywg.13
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 17:51:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=LoaYtMcAXKs6uO6gzAuujC0HF/HDtLH3jx83uKn7A+k=;
        b=gXommPF561ZJYgatkR5cIh1Cf9C1r5d7CjtbIGOHBbaHhgg+CmAOy5OhP+Xc2XczWV
         uJjyo1n0HwXUKfAfr5bPpQdopFtEJwicwAcY6FVByJGTO2S0lKvbfK86HVKHxJvJ2Bbv
         i97d0Ltb1myZfI00+apmbCRvHMv2qdBxhzu+hcQSTlK5vqdlOlS7lSXy8igdjvvNooKG
         hfBUpRV017zL8cfEU5jwm2gfY/Ag84P7z2fMi90s3nH+aJtGDkqwUPRSzcx0jaf3lEAm
         V5q6mDuepexYSCIiarTQ6NoLSXiAHIMoYxoZlxfT65LUnTM8FLibvgHNHyhgNoJmRVrR
         3xxQ==
X-Gm-Message-State: APjAAAWu4lm2Iw+C5qm1bg5wBYgeUEZmk7zsEZ/kWN+n8ZUqgulFC1fK
	4p8zypCwHhhStQubWcWg14XkBLJ6+FLgbx6QrkxC8h+f9xF/ZkFjwQBj9yRRd5Uh9xugFgN/VOv
	yseHUiiFd7jto+cc8bLDbeKp9VVASqbLXvlP6ofqVXN3W3XqpeXlODAFZv3iRNKMojw==
X-Received: by 2002:a81:708d:: with SMTP id l135mr580281ywc.225.1561596682359;
        Wed, 26 Jun 2019 17:51:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOT5BmY/LQuSq21jZxecw+yliqS4BOp7M1QiKzEgn6InPy3lawrRP3RIesW528bRB1NCOq
X-Received: by 2002:a81:708d:: with SMTP id l135mr580268ywc.225.1561596681600;
        Wed, 26 Jun 2019 17:51:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561596681; cv=none;
        d=google.com; s=arc-20160816;
        b=gFVtUnoD8c1hm1ge5XR3pjGW4BNDe+DQWmqPrTnNxLAztXjOjHP9XbDURCdEEiXqT+
         tmJjBV50idGnpou1TTR9LKqV/ysiUECA9gxkUFhaFv74WU88Q0XwYODOwMhTXKkqUiTA
         qwPZAwyclI/0cwivj0Rf8tBoaebLpUlbkCVjDUti+ckyPob0PXOzMk15wlzPqKjjqj+I
         Rollgu5wz+e/mxy8Rjz00r0kkD1VTNWyuCkOQjspqdUCIjpVI+y64aTMEkOsIPRqWR++
         is2YY1mJYCAngkfzozef7eIAMT8nLzF2JBkcEetUp70oAsJw9ex4nAaxBatFT36HkQZ0
         D21w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=LoaYtMcAXKs6uO6gzAuujC0HF/HDtLH3jx83uKn7A+k=;
        b=b1bevdfoHYkqf6g7tgn0uLImTeJ7J+f8eObLgFFM+7DI8y2be1x+KO6J7Oi7ydg1CC
         3k3f2jwsWJ2KOXpLCWkTvdEPehsK0O+Z87vayaqZEmHR09CuAWlWWjgIcNgB6C5ZaX5g
         wpuqjyMWxdoTwzVrmtQHkigbf+j92I6tU1NcLRluI9cex3nTNkWv5jS5iZQ1aZpC+x9G
         +xXAO9EYVD5Y+iDK8cg28L8yqAfEsOyixlo/eKOt4a7qqhL/8eZ4U8CZSJMVq6awfPYf
         oQn4fRFaW60NpB76uqUDgMxhNsBfgg/3jVeU6AHWIMtCdQ/PEh1E85kD863WQwdtFPB+
         57Jg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@d-silva.org header.s=201810a header.b=Tl3RrQYL;
       spf=pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) smtp.mailfrom=alastair@d-silva.org
Received: from ushosting.nmnhosting.com (ushosting.nmnhosting.com. [66.55.73.32])
        by mx.google.com with ESMTP id x190si192345ywg.102.2019.06.26.17.51.21
        for <linux-mm@kvack.org>;
        Wed, 26 Jun 2019 17:51:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) client-ip=66.55.73.32;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@d-silva.org header.s=201810a header.b=Tl3RrQYL;
       spf=pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) smtp.mailfrom=alastair@d-silva.org
Received: from mail2.nmnhosting.com (unknown [202.169.106.97])
	by ushosting.nmnhosting.com (Postfix) with ESMTPS id 387CD2DC005B;
	Wed, 26 Jun 2019 20:51:20 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=d-silva.org;
	s=201810a; t=1561596680;
	bh=uXs8jdup5M6WacVJmioLChNfDgHR/3okK/USi+R0dJs=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=Tl3RrQYL0XioL8sGGAMZBRqWknudnM9mAtU2K09D59jGWKY1oaqG76hAVZzT4ZFsG
	 CdriFls73SRvMfs8XdqBzB+aEccVYcPFLx1zHLAN2oddkR63Z1Ad/xR9obufNHYcU/
	 e0BMwHNWSWq/+vuTetXa3ZqNyvoZGML0FvIadxo/SZakXjxnBqk5H8JovNOewoJJKX
	 0vEznj4A1qeRVXV6uI6YXMZgEwIf2uTFpmM3VszuBa5cVS6DikxekEEtjYrghYFF9p
	 2beN+y05fYBmu+H9V/jUAMIt2bOC+7NpLGwj5BM1RdPiGZF+S/xkcDYlzltyWoVRqO
	 /MDvJL4Vjfi6uVAdATYbUqSQfeCVZQzj/+yGsLYLo+zCHBG2az4Od5L1qTSTnjeVox
	 Pl/Li2nYdNBA751qpkGfrndceNwtSLFtv6JufV2iGBCD0Q3OBGe4AJO8UsVYcnIvTG
	 KsqpxnBuIQL3dcWTj3nhWPbsHpjZgAygXmqNDAqFMt0ZJNyYjliYYAdwUFcO66T7FK
	 F8IB/CGWrHaCTADGIREZ2Chrq7ht4IrTjW3TO2GYKVt6r8EkShVOuiaynIIrTt4bQm
	 Kj8pEb3VMD9TbUch5JJkfC+yLnGxDOrk73z7LzcmwJhDEoQTZ6gG5WkA3vQBa6Moaw
	 XVOvw/BrkBRL6P7EOVFi4FkY=
Received: from adsilva.ozlabs.ibm.com (static-82-10.transact.net.au [122.99.82.10] (may be forged))
	(authenticated bits=0)
	by mail2.nmnhosting.com (8.15.2/8.15.2) with ESMTPSA id x5R0owXw037609
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NO);
	Thu, 27 Jun 2019 10:51:13 +1000 (AEST)
	(envelope-from alastair@d-silva.org)
Message-ID: <e66e43b1fdfbff94ab23a23c48aa6cbe210a3131.camel@d-silva.org>
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
Date: Thu, 27 Jun 2019 10:50:57 +1000
In-Reply-To: <20190626065751.GK17798@dhcp22.suse.cz>
References: <20190626061124.16013-1-alastair@au1.ibm.com>
	 <20190626061124.16013-2-alastair@au1.ibm.com>
	 <20190626062113.GF17798@dhcp22.suse.cz>
	 <d4af66721ea53ce7df2d45a567d17a30575672b2.camel@d-silva.org>
	 <20190626065751.GK17798@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.2 (3.32.2-1.fc30) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (mail2.nmnhosting.com [10.0.1.20]); Thu, 27 Jun 2019 10:51:15 +1000 (AEST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-06-26 at 08:57 +0200, Michal Hocko wrote:
> On Wed 26-06-19 16:27:30, Alastair D'Silva wrote:
> > On Wed, 2019-06-26 at 08:21 +0200, Michal Hocko wrote:
> > > On Wed 26-06-19 16:11:21, Alastair D'Silva wrote:
> > > > From: Alastair D'Silva <alastair@d-silva.org>
> > > > 
> > > > If a memory section comes in where the physical address is
> > > > greater
> > > > than
> > > > that which is managed by the kernel, this function would not
> > > > trigger the
> > > > bug and instead return a bogus section number.
> > > > 
> > > > This patch tracks whether the section was actually found, and
> > > > triggers the
> > > > bug if not.
> > > 
> > > Why do we want/need that? In other words the changelog should
> > > contina
> > > WHY and WHAT. This one contains only the later one.
> > >  
> > 
> > Thanks, I'll update the comment.
> > 
> > During driver development, I tried adding peristent memory at a
> > memory
> > address that exceeded the maximum permissable address for the
> > platform.
> > 
> > This caused __section_nr to silently return bogus section numbers,
> > rather than complaining.
> 
> OK, I see, but is an additional code worth it for the non-development
> case? I mean why should we be testing for something that shouldn't
> happen normally? Is it too easy to get things wrong or what is the
> underlying reason to change it now?
> 

It took me a while to identify what the problem was - having the BUG_ON
would have saved me a few hours.

I'm happy to just have the BUG_ON 'nd drop the new error return (I
added that in response to Mike Rapoport's comment that the original
patch would still return a bogus section number).


-- 
Alastair D'Silva           mob: 0423 762 819
skype: alastair_dsilva    
Twitter: @EvilDeece
blog: http://alastair.d-silva.org


