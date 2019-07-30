Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F4EEC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 21:56:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6DC82067D
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 21:56:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6DC82067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 510648E0003; Tue, 30 Jul 2019 17:56:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A8D28E0001; Tue, 30 Jul 2019 17:56:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BF468E0003; Tue, 30 Jul 2019 17:56:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 07DAE8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 17:56:01 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 91so36064722pla.7
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 14:56:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=P02YqgmHTBcIJHjlAhI3pmvYr3xQglXD30+9G24hZL0=;
        b=SQ/Ug/nBDx20Dkq6C2leXhpp04OkPY6SC0IfmXtBi8FsJiBnDVdTplH1zjGpsXccXC
         KuzHi8xztb4o0Z/1+su5FoeDsXv56HFPbqoTvPYTgNlN6Mr52o/q6QPpm4Sty8srhkn1
         ID3Km1BpcbRQq0DzlYFUpBLZ/BvbxV0Y/qt2Mb7DfK6fh+WLnkCV5/4YoU0Ey2zEQwcZ
         s422wFTWzk7qIpsgpuuDawTHElCisX3W1qNJSKc+xLQLwdUFX9ZfqfxEZaHgn0MZ3uTG
         mmC5dk6/mO/kvf9k9JHFd8D9JIzCE9GwgIsujeoSDyUejaAGDIGfLTtngv+99CyXgc1w
         BNGg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVzRAq1MA0JLg+wj4TF7GTSbzGRcTBkOpM7aAXr7EX8GdWDYF4+
	Nubrg57i+r+y3+zMNU7HJxENVoJogLt3k39Ugo3BKgEEXC737x0ZnJc8CqbNZhzTbCgv+Y+WODj
	WjdsXFfmEtprQxnOUybGkr/HyjtVjExEEBhOg2QHRKPw8gCyteS9bbb7Q9X2Yv6c=
X-Received: by 2002:a17:902:9f81:: with SMTP id g1mr115217786plq.17.1564523760660;
        Tue, 30 Jul 2019 14:56:00 -0700 (PDT)
X-Received: by 2002:a17:902:9f81:: with SMTP id g1mr115217718plq.17.1564523759229;
        Tue, 30 Jul 2019 14:55:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564523759; cv=none;
        d=google.com; s=arc-20160816;
        b=iVBvodRLyeSchMyHQl+ofBG3WzNggJRPkHIV1T6E9CpOchp/Ja0hU6CX9YqrNWFopu
         C1CLBUm0FDxGqZBYsTYelmjeElkz8cbhlG6xVogJ4s7XuS8Tcsilg6FYm1qHPslcB5g8
         5wtpSK9WZ0ZFi04VaaXVCZGlR/l4l8dPJYBZkZ7Txqraf65IY+y01sS7F60oDk2ryKEH
         liRy9mlRHLKkZFOV9+oUZOPLausL+3LfuDEOFeMaGLU8XJcq3REcXpuXXBk1FwqcXpAf
         elsFT8/BCF4nx4ZTt3zZd2BmpGP0B8Y6HoqRSCvHlX6mTzFYnFuSLJKcHPuV0f3AQntB
         J+Hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=P02YqgmHTBcIJHjlAhI3pmvYr3xQglXD30+9G24hZL0=;
        b=WF8iePchLBcxfiDae3nJNgo0zmuRXxV8TljIY3Qcai/uSd5WO6T18d7+kWWnOdIE7Q
         w6rbw4xFFrZ8DQYrZOE47gfZwWdohs7Vcvkg4AO0VNBIqvmBTAx+qOhMTk8pdNGri4uB
         Sn56OOkbf68dwuXxqa6+Cuv96ZONyOz44EIxOhUtGNSBzvtDc3CnTAWyPLWTH5xIl6qW
         wFbn4f6ikBGwSvYSYvnP5bMOk3sokHkGSfiKYRtjWGjKgY35lrj9vg4b9ORADj3ZyYfs
         lREpEkylXZmpIWabm6ZmVvmBnNoKi66uxXW84leu1dLi5xi6rXuN5TUOwAUxaHoQAw3h
         mL6w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s96sor78225970pjc.17.2019.07.30.14.55.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 14:55:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqz8Qg9AJa69GLSc54Bruvm9B0nwsdP1exUGkKtJJa+hTb+D8UM8ML0vxMYEeIaRb8/cZOPIqA==
X-Received: by 2002:a17:90a:ab01:: with SMTP id m1mr31609955pjq.69.1564523758593;
        Tue, 30 Jul 2019 14:55:58 -0700 (PDT)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c091:500::2:6988])
        by smtp.gmail.com with ESMTPSA id m101sm53084226pjb.7.2019.07.30.14.55.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 14:55:57 -0700 (PDT)
Date: Tue, 30 Jul 2019 17:55:35 -0400
From: Dennis Zhou <dennis@kernel.org>
To: sathyanarayanan kuppuswamy <sathyanarayanan.kuppuswamy@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>,
	Uladzislau Rezki <urezki@gmail.com>, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v1 1/1] mm/vmalloc.c: Fix percpu free VM area search
 criteria
Message-ID: <20190730215535.GA67664@dennisz-mbp.dhcp.thefacebook.com>
References: <20190729232139.91131-1-sathyanarayanan.kuppuswamy@linux.intel.com>
 <20190730204643.tsxgc3n4adb63rlc@pc636>
 <d121eb22-01fd-c549-a6e8-9459c54d7ead@intel.com>
 <9fdd44c2-a10e-23f0-a71c-bf8f3e6fc384@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9fdd44c2-a10e-23f0-a71c-bf8f3e6fc384@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 02:13:25PM -0700, sathyanarayanan kuppuswamy wrote:
> 
> On 7/30/19 1:54 PM, Dave Hansen wrote:
> > On 7/30/19 1:46 PM, Uladzislau Rezki wrote:
> > > > +		/*
> > > > +		 * If required width exeeds current VA block, move
> > > > +		 * base downwards and then recheck.
> > > > +		 */
> > > > +		if (base + end > va->va_end) {
> > > > +			base = pvm_determine_end_from_reverse(&va, align) - end;
> > > > +			term_area = area;
> > > > +			continue;
> > > > +		}
> > > > +
> > > >   		/*
> > > >   		 * If this VA does not fit, move base downwards and recheck.
> > > >   		 */
> > > > -		if (base + start < va->va_start || base + end > va->va_end) {
> > > > +		if (base + start < va->va_start) {
> > > >   			va = node_to_va(rb_prev(&va->rb_node));
> > > >   			base = pvm_determine_end_from_reverse(&va, align) - end;
> > > >   			term_area = area;
> > > > -- 
> > > > 2.21.0
> > > > 
> > > I guess it is NUMA related issue, i mean when we have several
> > > areas/sizes/offsets. Is that correct?
> > I don't think NUMA has anything to do with it.  The vmalloc() area
> > itself doesn't have any NUMA properties I can think of.  We don't, for
> > instance, partition it into per-node areas that I know of.
> > 
> > I did encounter this issue on a system with ~100 logical CPUs, which is
> > a moderate amount these days.
> 
> I agree with Dave. I don't think this issue is related to NUMA. The problem
> here is about the logic we use to find appropriate vm_area that satisfies
> the offset and size requirements of pcpu memory allocator.
> 
> In my test case, I can reproduce this issue if we make request with offset
> (ffff000000) and size (600000).
> 
> > 
> -- 
> Sathyanarayanan Kuppuswamy
> Linux kernel developer
> 

I misspoke earlier. I don't think it's numa related either, but I think
you could trigger this much more easily this way as it could skip more
viable vma space because it'd have to find more holes.

But it seems that pvm_determine_end_from_reverse() will return the free
vma below the address if it is aligned so:

    base + end > va->va_end

will always be true and then push down the searching va instead of using
that va first.

Thanks,
Dennis

