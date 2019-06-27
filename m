Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 143AAC48BD3
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 00:52:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8FAA20B1F
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 00:52:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (4096-bit key) header.d=d-silva.org header.i=@d-silva.org header.b="DsrHWido"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8FAA20B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=d-silva.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 531006B0006; Wed, 26 Jun 2019 20:52:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E25E8E0003; Wed, 26 Jun 2019 20:52:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3830A8E0002; Wed, 26 Jun 2019 20:52:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 140FE6B0006
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 20:52:15 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id i70so213663ybg.5
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 17:52:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=i+H/H9wCnZqScAUWwbdeP50L+N6zG96srbbEN1lHw9M=;
        b=MJT7Z1VaJ1OQaQpU7PMy5f5RJOvzIP7KhQG/zUwpbbS7saboFyqm12jwd6pnwzVlH7
         oVZ0tlFx5oQ4PY+A28+vYmJWSBS4bPQwZmp+jd/rUgW4VKRNtu5E5pQA/zsxDXCbGotQ
         scyhwzUAbLUg5db+nG1XKcTZid0BZjgWwASlQWxclDI/G+z0W51SuxHRIOfUyjek+Lvf
         AiBjN7n+wOvoSgEku9JmScCHLSHESPe2jCa9nh01AptIBSrTrt0UScv9mCkO+KkTnVh3
         6b+oaWFonnRXcMlNhyeSEUQXW0T0Dz/nPsJv6pUVeygeOmHY928MfH29R9kdBCnll1fi
         F9YA==
X-Gm-Message-State: APjAAAWj41ZJVuwvxi9E7lJxDlf6O3u72ndVd+BwDSwvRjjgsAtTEe0L
	CDPsYmVEdj4ZUiVo+q7olcCvWPaDkEQkjT8H360FuXI7bV3Yskk5ET9Gdg6kpddBOjA37m0QCJ1
	tYG3yFblHbUHmETMMC1XEym1ANLkzStDUzGCc3qc9E7WFKWVZDX9RhogZkvI6KlBFrg==
X-Received: by 2002:a25:7156:: with SMTP id m83mr913666ybc.386.1561596734799;
        Wed, 26 Jun 2019 17:52:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIsdwMmYu6JpB9ELRAAXtYU3iSqpemcQjWpXdM33FDqKRCGVEf/QLKZldDCIxDjYACPRta
X-Received: by 2002:a25:7156:: with SMTP id m83mr913650ybc.386.1561596734308;
        Wed, 26 Jun 2019 17:52:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561596734; cv=none;
        d=google.com; s=arc-20160816;
        b=eRjA4xrslxiXl3VTnnWdL5wGWqs5IDx9AcWdbN+Ny5+ODGFrPyxrDX+b6ly1qMNzok
         gOx6i4bj8QrrmQalDdiwIt8gML6hiQIk5+FROJ0m5FSYssntNmr1KFvLiRbuYk6YL/lz
         cdq1JM0mUn8LBJ6a95drB9DG+SaK0gxsROej9JUl1x5qnZtyC3ZEHmDCQfJL4/NvhEao
         a/hk99P+5w6tgIi8IJC3t/hJzcLa+PLhbiQ+jS4ql02gBbbTI9ZjnlsSI0KGSg93m+uy
         Fwn4xcKAoVKCbF3rZD3fGAOKWAZ6HFOSHlRd3zFdztOTTGJq3VZSMmPxETUsrIwHT9Fw
         5Tfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=i+H/H9wCnZqScAUWwbdeP50L+N6zG96srbbEN1lHw9M=;
        b=yLy2lK4h2rLK80j1cbPVouMxHMkVcHavYclH6Pp/8tBRuhIj/jJ85tOfyYw24wy0d/
         SNNqMK7Kc3eAd+EGSKUvb0tZzIDo22iyqEqPNc0ZReAvbnP2FxsZ3FftI32dUoBmotju
         uCKqWCUzLZ1Lut+hUqap0j9TW12loz2sbd0+sFQcr9uVVoNRzFezKB/H+RgQCsytT9Za
         wl/n4vMpHj/UftkYvEeU3q+b/CjO4UIl/qYPAXBGtpxWpLvAYKzZafc3Ec73vEQ0Cs9s
         YMZxbqjY/WOoSyEMeqarW/p+85xW3E3cJho3DEiYCIG4TSKWITjSt8DarJM1BEw1NK8/
         ZQcw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@d-silva.org header.s=201810a header.b=DsrHWido;
       spf=pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) smtp.mailfrom=alastair@d-silva.org
Received: from ushosting.nmnhosting.com (ushosting.nmnhosting.com. [66.55.73.32])
        by mx.google.com with ESMTP id j207si179501ywj.59.2019.06.26.17.52.14
        for <linux-mm@kvack.org>;
        Wed, 26 Jun 2019 17:52:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) client-ip=66.55.73.32;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@d-silva.org header.s=201810a header.b=DsrHWido;
       spf=pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) smtp.mailfrom=alastair@d-silva.org
Received: from mail2.nmnhosting.com (unknown [202.169.106.97])
	by ushosting.nmnhosting.com (Postfix) with ESMTPS id 84AB62DC005B;
	Wed, 26 Jun 2019 20:52:13 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=d-silva.org;
	s=201810a; t=1561596733;
	bh=e3ADJwfA6t0sBRcoRZyK9kX07Ioi4er/mJ665+7Q8Ig=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=DsrHWidoX5Aqd+bpgeRHA0G0YHP7sXuAJiwPE5gJUOzci098HotAInkFcMjsT/YN7
	 SI3UNuXoc/t4Y41zWiB3tADVwkwSgWSgSXaxeZ/6UiqXj6gDrAmx4UjO6sKqUx6cao
	 bo9ienJHM/UiopRop7DgCsOV0MGLf2Y7t+pNLV58gHHYF9kXSdNP0gZOwaGUm4mg7r
	 KXqFlTlusei4k8sjM1pjoCSIdHQ5gT538EhyOVQYYQZoTZQzpOS7H4weGYGUQ1uO0H
	 Vhxc15wTIVtIevbbKezWLlSUiAclivCLNq3Y5M1jWPzhFtrFVnhKOkwFxpIEIwPUyo
	 9NupOCJlOOKEbmrSbY7tKiasZTj20HEhskmhMcAkRVakCU+wJeAw5LIqXD21DJYuiF
	 OqHLL1MNjSaDusclE56RkmfomCpU4u0Oj9fLMpX1/8L08yfDs3UGoDnzjz7pB9k64s
	 aJHRqCStrFqIpvpl4LExXvc2lZ8e7RG5RSwTJVHHbAqgR3XWCBQ96lIpLEbJIz8v9T
	 0pWInnqTsfc+r3dHBDXo8LcFF4jNdViyasxrQDjbxF5yLGZXqY42CHprL0NuaT3nbT
	 8n6keTtnbViGAWerKi1H6eEnD/zn4abzzRmc64I9u4Ykf6wWvG03NgVPboVhLaWv4b
	 8vJVIQbf9iWiOtLoFE9jtCZo=
Received: from adsilva.ozlabs.ibm.com (static-82-10.transact.net.au [122.99.82.10] (may be forged))
	(authenticated bits=0)
	by mail2.nmnhosting.com (8.15.2/8.15.2) with ESMTPSA id x5R0prWE037614
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NO);
	Thu, 27 Jun 2019 10:52:09 +1000 (AEST)
	(envelope-from alastair@d-silva.org)
Message-ID: <ecf246b3b9c7069a04e0046e1aa906c7f6322960.camel@d-silva.org>
Subject: Re: [PATCH v2 0/3] mm: Cleanup & allow modules to hotplug memory
From: "Alastair D'Silva" <alastair@d-silva.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "Rafael J. Wysocki"
 <rafael@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Pavel
 Tatashin <pasha.tatashin@oracle.com>,
        Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>,
        Mike Rapoport <rppt@linux.ibm.com>, Baoquan
 He <bhe@redhat.com>,
        Wei Yang <richard.weiyang@gmail.com>,
        Logan Gunthorpe
 <logang@deltatee.com>, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org
Date: Thu, 27 Jun 2019 10:51:53 +1000
In-Reply-To: <20190626075753.GA24711@infradead.org>
References: <20190626061124.16013-1-alastair@au1.ibm.com>
	 <20190626075753.GA24711@infradead.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.2 (3.32.2-1.fc30) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (mail2.nmnhosting.com [10.0.1.20]); Thu, 27 Jun 2019 10:52:09 +1000 (AEST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-06-26 at 00:57 -0700, Christoph Hellwig wrote:
> On Wed, Jun 26, 2019 at 04:11:20PM +1000, Alastair D'Silva wrote:
> >   - Drop mm/hotplug: export try_online_node
> >         (not necessary)
> 
> With this the subject line of the cover letter seems incorrect now :)
> 

Indeed :)

I left it as I was unsure whether changing the series title would make
it harder to track revisions.


-- 
Alastair D'Silva           mob: 0423 762 819
skype: alastair_dsilva    
Twitter: @EvilDeece
blog: http://alastair.d-silva.org


