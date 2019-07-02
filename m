Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6884EC5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 06:17:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2269121841
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 06:17:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (4096-bit key) header.d=d-silva.org header.i=@d-silva.org header.b="kSD9EPjw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2269121841
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=d-silva.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3B7B8E0003; Tue,  2 Jul 2019 02:17:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AEA208E0002; Tue,  2 Jul 2019 02:17:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B1ED8E0003; Tue,  2 Jul 2019 02:17:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 797398E0002
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 02:17:05 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id d135so1700162ywd.0
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 23:17:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=dK8DFqvFq+hyqHVE6ARPEuTS5xGx4zYoemsWL1Fo1EA=;
        b=mVCnmBv1mGnKYYCThN7XAWGufrVoXgLR1iVZjwbPHKJ7LeFpzZ0AESPHWDeU+4kADE
         O8fmfNKWtyXKpB5YMyY9E+zD0z/QY+RRRQuZZkLgTRODswK6eFmhDDLA2XrqUgPfGVwz
         y2NJz6mpb4PFBUuwRyHN01VGuk9Bfy5VRWYNjGbMb7lwmqGZrWFeHw+RtLkPXj5yQ9Yo
         /irYUuyDd/Gc7n+5FHLaki9FfThygzNNPkSF6lAAmWmWuL/ZRXBk6tdTzrQ+nZ+BBH51
         lbTMZM1bAKMi1rd7jPRaW6j5T9Ah61dtxnnsO/ssQa5HWQTZQzb83ZO0E8nASd+QaSbi
         pVCg==
X-Gm-Message-State: APjAAAX+8uInIAMPAr1PS6FcUX+Hpj736kOGd1EA2YLlZbb9yp6a4UFp
	O0Ol6RAArZMLDlsH678JngljK0TiwkZHJy9JFmA7TraySawGOoBrOpR9BVEVWkWK8yDR+mO0jyr
	kYZMmlDhvMZuPVpUuCUlbSILcSBuPqoHZxk7M3PCz0b4hX4lQmmfyj4VMmVF5FCqmDw==
X-Received: by 2002:a81:aa50:: with SMTP id z16mr16193743ywk.278.1562048225165;
        Mon, 01 Jul 2019 23:17:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydn1KPKBZrb1qlwMELC0+R7KN6wT7LuXVoHvHkUMX0R+3cVaUWpVPLeOO7yw0hmTC3IcOx
X-Received: by 2002:a81:aa50:: with SMTP id z16mr16193728ywk.278.1562048224523;
        Mon, 01 Jul 2019 23:17:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562048224; cv=none;
        d=google.com; s=arc-20160816;
        b=NQWXoUioHTh2E22HBMBtH6iq1Wx8MLkchnFYkZbdSA5UT/RshEuY7PByLT+kvX192b
         lG23/ZcME8Dzj/cS55y88HALBelE4ObReX5NxDH66wI9/FNP2d2pV8O7yUGyP8arzYkv
         B9Js7VAhx4hzpHZawrar8DMKrrCCY735RpIwdMXR6eaHYjG8ZUsExx0oQ31Ez57Wk9tX
         S5H161JrzJGZFwjkTg9UmXvle9zAOUWnF38iQf72u4Ysgx7OrjQhsBQUhp79jIwUjKUq
         +V2QGGAFJp6JD0l4KopLDLJb7OX1ew0ebk7QngnfAMqjdWIlSJLPYhPSZytuFgArZInL
         1GwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=dK8DFqvFq+hyqHVE6ARPEuTS5xGx4zYoemsWL1Fo1EA=;
        b=BcwvBKcXrAgLHjbciOtdxDJB9DDW9GWCr1Sp83xfhv7Ih68Eun/DKhzkn8xFhdR9ID
         Ki9Y2xvSJEvjM0RygNotpHk3g24YXnvaS9IND0FtAaDzop9buTMaed0nGiglXWuRIulb
         6qhcuwk7BreeXUjhx/EVpzmtPKxsSOFG+Rm+PT5PWoMd2VCrSNvKC+yHYZNHUH7bMstV
         ZVoR+713xurnqYWdNpFFP4m/ueHRcCYHERA3qocNq1S3mMqi0mziQRE9fxY9CFh+9Exl
         +kJSppeHUEFy0x4zdqBYuNZLCEUgMNEiXhZQvKUmUnFjFyaWSYU4qa1UudIr8o/JWzuz
         YXtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@d-silva.org header.s=201810a header.b=kSD9EPjw;
       spf=pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) smtp.mailfrom=alastair@d-silva.org
Received: from ushosting.nmnhosting.com (ushosting.nmnhosting.com. [66.55.73.32])
        by mx.google.com with ESMTP id d3si5284727ywf.374.2019.07.01.23.17.04
        for <linux-mm@kvack.org>;
        Mon, 01 Jul 2019 23:17:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) client-ip=66.55.73.32;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@d-silva.org header.s=201810a header.b=kSD9EPjw;
       spf=pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) smtp.mailfrom=alastair@d-silva.org
Received: from mail2.nmnhosting.com (unknown [202.169.106.97])
	by ushosting.nmnhosting.com (Postfix) with ESMTPS id 1248A2DC009C;
	Tue,  2 Jul 2019 02:17:02 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=d-silva.org;
	s=201810a; t=1562048223;
	bh=jmxTkz+xmGtAbS/yxNUR0tOcP0AiHxZIRt4HYUN6bgk=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=kSD9EPjwIJGSwPftuuH7di/739+wc8CPJufU+o7Nxfbv/sW0LijKap+FV5L7IUGNj
	 Fh3kViYh+G3msOxmrYk9XqF0G8vzK8I0gQgEQd6bNj9+q8oEVSUV2iD8cTcaejcimR
	 f5fwty3mfgNOE9FoRuiA+LG5q1eG667ByT/ysbwvjtsMGhswLAqOEHzcDUyWzJ7FOO
	 b+7go36ost7erc7qQcrtKbWKq1Bjl3kF3JrHGslsqhjdpLgzSKihqhTiCelqVG/W6Y
	 nsiRvodaITT2+dQohTEPyMEdh7yAjyVLQRgaDGbTcQtCYjrPJmkqk6hWS9f/yjV9vG
	 t4WV+6GEFpJmuwjxRRE44fQIY2v2YkLB502ZdT0bM6H45kNQlPUyNXkJrdGfoG5LQv
	 X8lqNfUHEj8NMIKO1Q2ceUMdk+/xeYN8vHnMHQZGu/nkvo8H7aFuSaVozHxZruOFBZ
	 gWth5ksRUmjbFGE87MShayptzaSeFsCq73NZlNW8yLUj601d1h7ouLWlCefXxWojWt
	 CrBnSX2+yYfthxDIKP6bmPEowSLCwGu492zEFKlAXON4NrodnBBpiBjOS38fmSmJHr
	 8gN7PFYReFT8Q/qlkbz3ijuIjrUsIlm+PpbWbfiAbyNAwgE0S0+BYlrGM5V0O4sE06
	 /tvbJOSAf0xysB78lETKU1bU=
Received: from adsilva.ozlabs.ibm.com (static-82-10.transact.net.au [122.99.82.10] (may be forged))
	(authenticated bits=0)
	by mail2.nmnhosting.com (8.15.2/8.15.2) with ESMTPSA id x626GgYG086222
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NO);
	Tue, 2 Jul 2019 16:16:58 +1000 (AEST)
	(envelope-from alastair@d-silva.org)
Message-ID: <caa5673459fef4152e0aea7e1a30d6027a81e652.camel@d-silva.org>
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
Date: Tue, 02 Jul 2019 16:16:42 +1000
In-Reply-To: <20190702061310.GA978@dhcp22.suse.cz>
References: <20190626061124.16013-1-alastair@au1.ibm.com>
	 <20190626061124.16013-2-alastair@au1.ibm.com>
	 <20190626062113.GF17798@dhcp22.suse.cz>
	 <d4af66721ea53ce7df2d45a567d17a30575672b2.camel@d-silva.org>
	 <20190626065751.GK17798@dhcp22.suse.cz>
	 <e66e43b1fdfbff94ab23a23c48aa6cbe210a3131.camel@d-silva.org>
	 <20190627080724.GK17798@dhcp22.suse.cz>
	 <833b9675bc363342827cb8f7c76ebb911f7f960d.camel@d-silva.org>
	 <20190701104658.GA6549@dhcp22.suse.cz>
	 <7f0ac9250e6fe6318aaf0685be56b121a978ce1b.camel@d-silva.org>
	 <20190702061310.GA978@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.2 (3.32.2-1.fc30) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (mail2.nmnhosting.com [10.0.1.20]); Tue, 02 Jul 2019 16:16:59 +1000 (AEST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-07-02 at 08:13 +0200, Michal Hocko wrote:
> On Tue 02-07-19 14:13:25, Alastair D'Silva wrote:
> > On Mon, 2019-07-01 at 12:46 +0200, Michal Hocko wrote:
> > > On Fri 28-06-19 10:46:28, Alastair D'Silva wrote:
> > > [...]
> > > > Given that there is already a VM_BUG_ON in the code, how do you
> > > > feel
> > > > about broadening the scope from 'VM_BUG_ON(!root)' to
> > > > 'VM_BUG_ON(!root
> > > > > > (root_nr == NR_SECTION_ROOTS))'?
> > > 
> > > As far as I understand the existing VM_BUG_ON will hit when the
> > > mem_section tree gets corrupted. This is a different situation to
> > > an
> > > incorrect section given so I wouldn't really mix those two. And I
> > > still
> > > do not see much point to protect from unexpected input parameter
> > > as
> > > this
> > > is internal function as already pointed out.
> > > 
> > 
> > Hi Michael,
> > 
> > I was able to hit this problem as the system firmware had assigned
> > the
> > prototype pmem device an address range above the 128TB limit that
> > we
> > originally supported. This has since been lifted to 2PB with patch
> > 4ffe713b7587b14695c9bec26a000fc88ef54895.
> > 
> > As it stands, we cannot move this range lower as the high bits are
> > dictated by the location the card is connected.
> > 
> > Since the physical address of the memory is not controlled by the
> > kernel, I believe we should catch (or at least make it easy to
> > debug)
> > the sitution where external firmware allocates physical addresses
> > beyond that which the kernel supports.
> 
> Just make it clear, I am not against a sanitization. I am objecting
> to
> put it into __section_nr because this is way too late. As already
> explained, you already must have a bogus mem_section object in hand.
> Why cannot you add a sanity check right there when the memory is
> added?
> Either when the section is registered or even sooner in
> arch_add_memory.
> 

Good point, I was thinking of a libnvdimm enhancement to check that the
end address is in range, but a more generic solution is better.

-- 
Alastair D'Silva           mob: 0423 762 819
skype: alastair_dsilva    
Twitter: @EvilDeece
blog: http://alastair.d-silva.org


