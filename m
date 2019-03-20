Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D551C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 12:37:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A50E213F2
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 12:37:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A50E213F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2E176B0006; Wed, 20 Mar 2019 08:37:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB60F6B0007; Wed, 20 Mar 2019 08:37:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA5976B0008; Wed, 20 Mar 2019 08:37:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 78D4B6B0006
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 08:37:49 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h27so846133eda.8
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 05:37:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xyJwayRb68V6HNNjxxEp1T8lIGN5MRbXxNPLvt0ylio=;
        b=B9TG/TvTCTNy+jIhVGLUtnv7Uf3mbjLVuqU+wxkVXiFpIsYA9+AyBehnZNLVM1ju+5
         p8gYl6RDxth3padPTr1f2+zO5RrJsGnp0ShIeqamCXEGdrMZikb96F5fzlc7Vsch8Nyc
         ppSqUC+TlAWJAQTOyShzkiXY1LxJHsApYXV+hRXbB+zMHGxV4js1Z+j92SefzoBrrkuI
         V0jq5Vq89tK28boc17cXe3c+MHbTYsW7nvlMf2KMY8iS8JGhYplSMfbEWWAx5iiirt4D
         9KEujlpYxqaeeqrYvv0S4Fqs2Glz657i02mxyC6pWBEnIKFN2d4zYF7wRq8++wLvN+6t
         FHww==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXrIGHBgbJUy7mN4sj1lE0R+12p1/TtUpC7zoHLQqxScOF622AX
	ZzssjfplYIkaaFW53Se5Iy67wFaQxOpCzzhYQYZvG6WmA5/9Ieka2cToEbBx2x1lDo2WJ6E3GZL
	cDOw0qtsK3Wa4kJvqCnLMioT+GB8igXmbPPxjxo6xMC+xJBfBxu13jgWkURQdCgY=
X-Received: by 2002:a17:906:1c98:: with SMTP id g24mr10251032ejh.178.1553085469063;
        Wed, 20 Mar 2019 05:37:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygtefLFvmDKGpUqG2Qhuj4Q+e0lz2nY+EoH2Gt9Yw3d04AD/GDmDTQeYXaKRFinpVPHwPL
X-Received: by 2002:a17:906:1c98:: with SMTP id g24mr10251009ejh.178.1553085468290;
        Wed, 20 Mar 2019 05:37:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553085468; cv=none;
        d=google.com; s=arc-20160816;
        b=h+ysTH58Fjo4INWV6uxR35Hc9M9+aWbua2WpBzicaaHjdr25P9+pf4+MNwSxuITR5c
         bFCc0PWpY8gvJ+3jj7Bt1CWnkcrQdA1EJIW/49baawuGI+Jg36Aq93c+Y/7dER1DZEA2
         K1c7gmpIyp9zlgFNYGzFklkEqssT1m6irHQ+UmrROJwOqO0dkwa8AlLjI9p0zTtY/vFS
         nYn+2Iq4NWDY1rs7I6PX19xHI10xO/6/t+X3r5kNGQSAm4NNECy7+EgVudA9OU1qmjCt
         r25+TJKWynNUFgaOidecOpncb/zslZjSO/8JtOl4NxJ3tzWhR7qoka+MkCNvHDIZWDq9
         R7SA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xyJwayRb68V6HNNjxxEp1T8lIGN5MRbXxNPLvt0ylio=;
        b=LXk6jvZ6Yn/u/pckJfyDQIVuus4dHV+h+TJxP6aBZCT4CQfoS9ZaxC4WZJwoJ7+ngB
         kQv6wtPUZwTbmYwAqAXN6L86ktiz64T9rCgfvZDMqX/Ef2Sw//VBMQiwS+I3ZTg2bq2R
         19jT8ic9HT02BMZYlIfPi4QTB5tzzJq7hlZOM0EqvPAbnYDZ82MAnrjE/uyEOosxPLG4
         bk22Q0SC/PJ6/VK3NEh4ACeXrTOjiEE/xtnBwuPN9ALuJw1EYXNttJmNLOAn2uysACTd
         Y7SZ56fk4NEsplt91N6Vzx+VtNSPAiZtEPPKxE5HBK+duCwjpdZF8f0GGE0u06hGIk6V
         KYHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id 58si808486eds.7.2019.03.20.05.37.48
        for <linux-mm@kvack.org>;
        Wed, 20 Mar 2019 05:37:48 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 9F981462C; Wed, 20 Mar 2019 13:37:47 +0100 (CET)
Date: Wed, 20 Mar 2019 13:37:47 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Matthew Wilcox <willy@infradead.org>
Cc: Baoquan He <bhe@redhat.com>, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, pasha.tatashin@oracle.com,
	mhocko@suse.com, rppt@linux.vnet.ibm.com, richard.weiyang@gmail.com,
	linux-mm@kvack.org
Subject: Re: [PATCH 1/3] mm/sparse: Clean up the obsolete code comment
Message-ID: <20190320123747.vzreusrqx74zkdfm@d104.suse.de>
References: <20190320073540.12866-1-bhe@redhat.com>
 <20190320111959.GV19508@bombadil.infradead.org>
 <20190320122011.stuoqugpjdt3d7cd@d104.suse.de>
 <20190320122243.GX19508@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320122243.GX19508@bombadil.infradead.org>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 05:22:43AM -0700, Matthew Wilcox wrote:
> On Wed, Mar 20, 2019 at 01:20:15PM +0100, Oscar Salvador wrote:
> > On Wed, Mar 20, 2019 at 04:19:59AM -0700, Matthew Wilcox wrote:
> > > On Wed, Mar 20, 2019 at 03:35:38PM +0800, Baoquan He wrote:
> > > >  /*
> > > > - * returns the number of sections whose mem_maps were properly
> > > > - * set.  If this is <=0, then that means that the passed-in
> > > > - * map was not consumed and must be freed.
> > > > + * sparse_add_one_section - add a memory section
> > > > + * @nid:	The node to add section on
> > > > + * @start_pfn:	start pfn of the memory range
> > > > + * @altmap:	device page map
> > > > + *
> > > > + * Return 0 on success and an appropriate error code otherwise.
> > > >   */
> > > 
> > > I think it's worth documenting what those error codes are.  Seems to be
> > > just -ENOMEM and -EEXIST, but it'd be nice for users to know what they
> > > can expect under which circumstances.
> > > 
> > > Also, -EEXIST is a bad errno to return here:
> > > 
> > > $ errno EEXIST
> > > EEXIST 17 File exists
> > > 
> > > What file?  I think we should be using -EBUSY instead in case this errno
> > > makes it back to userspace:
> > > 
> > > $ errno EBUSY
> > > EBUSY 16 Device or resource busy
> > 
> > We return -EEXIST in case the section we are trying to add is already
> > there, and that error is being caught by __add_pages(), which ignores the
> > error in case is -EXIST and keeps going with further sections.
> > 
> > Sure we can change that for -EBUSY, but I think -EEXIST makes more sense,
> > plus that kind of error is never handed back to userspace.
> 
> Not returned to userspace today.  It's also bad precedent for other parts
> of the kernel where errnos do get returned to userspace.

Yes, I get your point, but I do not really see -EBUSY fitting here.
Actually, we do have the same kind of situation when dealing with resources.
We return -EEXIST in register_memory_resource() in case the resource we are
trying to add conflicts with another one.

I think that -EEXIST is more intuitive in that code path, but I am not going to
insist.

-- 
Oscar Salvador
SUSE L3

