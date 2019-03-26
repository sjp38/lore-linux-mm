Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC8F8C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 22:57:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 735182075D
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 22:57:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 735182075D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1121C6B0007; Tue, 26 Mar 2019 18:57:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09B1E6B0008; Tue, 26 Mar 2019 18:57:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA46E6B000A; Tue, 26 Mar 2019 18:57:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id BC70B6B0007
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 18:57:21 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id z123so13015121qka.20
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 15:57:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fVGwnRBdurLn27T8ngkVd4W+0eLjNB+djt312owdy50=;
        b=JrHICms+0d4XV+XS1gmHy3RgNqqC9hWP59YCFFTGnWJfCZaB/+mmWzzmhGXgJv3yER
         AcD30t0IOlgLbE2ait+mnrJ2FznbqIb6b5zVpU+r63kZ616PIJUeTh3kFmvhwNhcjaIf
         Di2e8zdVshth1pRhN45sonhTCve0Lt0zh5KddQH9ami9ZosOR0T+X36LhsShlLnMeury
         9cNpnR/wNvsfyXYdmD6J8BhIfW8HCQnS9mFf6YBQzkR6hqLSlqchBiAWBGMczF8Cl0JT
         NBBKOECHWQpFiUdYnqH4/wHDPQ6km6vFdnNbaWg0mt4Zem7DVnPJUht9HavexwUkr5g6
         PEkg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWW6BcMxcaOq6KTNSVN/oEqv7xF390GYyesQxzoIuNs9rBECV3c
	eq0H5Itg9jqhSxBdcB1J/sy2pnaYFCJtT1ZmYHzI/jAdKH7UqgSB/pdRpXf1r5a47DwXOQc8l9T
	hIDWKVliw3Hn+Xvj141PG5m+IdYq1WuOIJOXe3/W5ectf/yJOjI/M849afy+Oon+/6Q==
X-Received: by 2002:ac8:2f11:: with SMTP id j17mr28740513qta.334.1553641041545;
        Tue, 26 Mar 2019 15:57:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4eZ92gCK/cvDyoBxtLpst163Rkh8Fa5bVXFhpF8c0UX4uckyFDHl/ydxFktAMfti7B9Ka
X-Received: by 2002:ac8:2f11:: with SMTP id j17mr28740484qta.334.1553641040894;
        Tue, 26 Mar 2019 15:57:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553641040; cv=none;
        d=google.com; s=arc-20160816;
        b=hD8M4iaLsakBlwdwIOlKKYswMuvEgPNlTJPAvGnjjTP7ervrLGMi5keN7tFc+NoC+A
         JfWOIm18aWSyUgHbxed/hIzfZ0i/TpyLp0q0jj5qpeY/L4rWi/otTStL1AEne06kP8iu
         +DfYuss/AHS0BWyQAP38M9+Pygy8LimDlo1akjLf8x9S5tkVTgy2Y0zxQAd9L601Qkt+
         F7S2RCx6u+p3bQxJWJL6Ocnv9qPnnbTCIFEutOUgjKAcsL5QQVWs0frLpd6ZoVlnaOw8
         yB9x9xs+myBnb6xnnZRDssz7aeD+ytZ91EtW7qqiMWdMtOUP9Gm9vd661JmSSA/QVz8Q
         FMUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fVGwnRBdurLn27T8ngkVd4W+0eLjNB+djt312owdy50=;
        b=u1YQyGTwoO6NEUbnXL+e07wKTDooGE9RFqoK4MIl4bwwD6hrgn6iWppbwKyWpQdP7j
         AY9m4GTAwDVWc8+a7UftPCoVxgVnTEqzgzPeBrWxeB+7TnSUYaRvK9VJFDKjReY5ey74
         2L7cU2j5Ox/1WYFEsmMvQ+rIEOpbxFSMOyEH5dfLl9v3TC1DAU+AfvNhkGJIVAJhPJlz
         +anJcYIe/AtHIn1aouPWAwGCs93nOfA9rpLJBp+E0tdt+w+qjZJ20xAjKgmFTSYQo26L
         3xTaUWQkHNLJIw6tM3xM6TDMvTY5uslzR3LVRleIzj2txqaXiuuSil279a1laFZP+x/P
         zDNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h9si1352854qke.72.2019.03.26.15.57.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 15:57:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 015B830FE5B3;
	Tue, 26 Mar 2019 22:57:20 +0000 (UTC)
Received: from localhost (ovpn-12-27.pek2.redhat.com [10.72.12.27])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 59F4519C7B;
	Tue, 26 Mar 2019 22:57:19 +0000 (UTC)
Date: Wed, 27 Mar 2019 06:57:16 +0800
From: Baoquan He <bhe@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, rppt@linux.ibm.com, osalvador@suse.de,
	willy@infradead.org, william.kucharski@oracle.com
Subject: Re: [PATCH v2 2/4] mm/sparse: Optimize sparse_add_one_section()
Message-ID: <20190326225716.GY3659@MiWiFi-R3L-srv>
References: <20190326090227.3059-1-bhe@redhat.com>
 <20190326090227.3059-3-bhe@redhat.com>
 <20190326092936.GK28406@dhcp22.suse.cz>
 <20190326100817.GV3659@MiWiFi-R3L-srv>
 <20190326101710.GN28406@dhcp22.suse.cz>
 <20190326134522.GB21943@MiWiFi-R3L-srv>
 <20190326140348.GQ28406@dhcp22.suse.cz>
 <20190326141803.GX3659@MiWiFi-R3L-srv>
 <20190326143145.GR28406@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326143145.GR28406@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Tue, 26 Mar 2019 22:57:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Michal,

On 03/26/19 at 03:31pm, Michal Hocko wrote:
> > > > OK, I am fine to drop it. Or only put the section existence checking
> > > > earlier to avoid unnecessary usemap/memmap allocation?
> > > 
> > > DO you have any data on how often that happens? Should basically never
> > > happening, right?
> > 
> > Oh, you think about it in this aspect. Yes, it rarely happens.
> > Always allocating firstly can increase efficiency. Then I will just drop
> > it.
> 
> OK, let me try once more. Doing a check early is something that makes
> sense in general. Another question is whether the check is needed at
> all. So rather than fiddling with its placement I would go whether it is
> actually failing at all. I suspect it doesn't because the memory hotplug
> is currently enforced to be section aligned. There are people who would
> like to allow subsection or section unaligned aware hotplug and then
> this would be much more relevant but without any solid justification
> such a patch is not really helpful because it might cause code conflicts
> with other work or obscure the git blame tracking by an additional hop.
> 
> In short, if you want to optimize something then make sure you describe
> what you are optimizing how it helps.

I must be dizzy last night when thinking and replying mails, I thought
about it a while, got a point you may mean. Now when I check mail and
rethink about it, that reply may make misunderstanding. It doesn't
actually makes sense to optimize, just a little code block moving. I now
agree with you that it doesn't optimize anything and may impact people's
code change. Sorry about that.

Thanks
Baoquan

