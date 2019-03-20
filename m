Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99487C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 12:20:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B0142075C
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 12:20:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B0142075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6E6D6B0003; Wed, 20 Mar 2019 08:20:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F38B6B0006; Wed, 20 Mar 2019 08:20:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8951B6B0007; Wed, 20 Mar 2019 08:20:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0426B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 08:20:18 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o27so825008edc.14
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 05:20:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dXFvDyITa9NwkF6sB26uyWuSNb1aa4yRdxMiNFZX7Ec=;
        b=i3rvtV2t7j0aOld6xNnP8RuEIXDRf9mHZdQ6cSf29+NL6l57bGM9z+9zT4TL56iwg0
         mKefoSTbX7a2HiZz3f/+3S4+OIDyZ5pzezH0gk/jGYEyKiCXjORUsjSajHy9mpRKc4J0
         b4mF/qsD78YXmGCxa4B6qyjtX5czUp13EN5MEJ3KT6xTracA3M154R19aDGjgnWAWeCr
         vvbHnWGjlFaN+RjJuyaqXCsps24wxXT0NVRdVXezwwVhiFsGKHJfRgX4lSBtAemqrb17
         FMlt7aYegjzFyYnBbT/lnl/oVGEQukjEAxIVWc69jcO0qHa9hgQFzr4IZ5sQxZOlzHbI
         aptA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAULP73guAoZj/mqH0kIKEhvJPU/ZiWMEqzxHRTv9u8MuWETwc0D
	zM7flJrbzEXx+giONPDosxPXqKkNMeBMz0V2EP1u8qEK48NADtwAfcIq1ybsQz13ecB4ipYdjps
	MXZEkoQLvGXFPxjYG0JIRPWY4TMAJ/X7+ftHGNscc4P0I8+6L27VGcEXQOB93XNE=
X-Received: by 2002:a50:f39a:: with SMTP id g26mr20478577edm.151.1553084417717;
        Wed, 20 Mar 2019 05:20:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMDOjt3XJNyMK1qmXXrLcN6Rq/1YSB/trj2ZlKPdjGqRdRIPbt6F/qyqk31pi/St6yz0rC
X-Received: by 2002:a50:f39a:: with SMTP id g26mr20478520edm.151.1553084416566;
        Wed, 20 Mar 2019 05:20:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553084416; cv=none;
        d=google.com; s=arc-20160816;
        b=YNQRanUOXBaj82jz5Ry0xSOjQqnSgwQIMOkduXkwXhDmDzajQhcdtduNw4Gvbomu4L
         2ujOkjB8RsqNpMyPLa0sWdBfd8/CjaubES30XYRULGcEfXQg5JYed8lwYx11c3uPcdyi
         olJe/BnWF/GxSrGtR9As4vILqYuKZTiFHDi5aosBd60YafOtmOfKquCjEQg/c7gOfrlI
         NjZbR9orBrrJVFtdALPL/M+yVG1HvlU2oTpguuWdKvULNlM6s32/u/+bz/PWintyMZNl
         gpaxjEIqRD3RGJA1LzIol7z0WbSqc2MIPTcxW5Koj/kcfIJTw0SE4LrCsj1nqDPwL9li
         2pdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dXFvDyITa9NwkF6sB26uyWuSNb1aa4yRdxMiNFZX7Ec=;
        b=tYOuJUjT9mrvOKuEIYg0ePWvqLKxlAVV1vrlLAPMeloslnNiNBKYXGDgc8bKJds8En
         Yt0UiugHFOuphwqwyXBjlEJBHmyHRwBDSU0SY9KjumhLNHm0uIRZusuNQmw4autZJugN
         /n+8nLwNCj4PAK9qwsyGgKfyn2VIWJHTPYU3nkSvmR0Q4SixHx9zs1X0N57EvOfN/Y7G
         Ypj6iNMB77XzXP9YOTMjZVqFCsPhV0XjQyPuNXTkLEMsyEAdmCuhzKg2pgTYgYxZTwwD
         RidcbPmuQJiTm99PE6912IqCsrL2jr1qgCq49ipOGW3QIHPLuu8as7Zd/rXPWZNISyj7
         x/TA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id j3si569980eja.2.2019.03.20.05.20.16
        for <linux-mm@kvack.org>;
        Wed, 20 Mar 2019 05:20:16 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 6683C4622; Wed, 20 Mar 2019 13:20:15 +0100 (CET)
Date: Wed, 20 Mar 2019 13:20:15 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Matthew Wilcox <willy@infradead.org>
Cc: Baoquan He <bhe@redhat.com>, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, pasha.tatashin@oracle.com,
	mhocko@suse.com, rppt@linux.vnet.ibm.com, richard.weiyang@gmail.com,
	linux-mm@kvack.org
Subject: Re: [PATCH 1/3] mm/sparse: Clean up the obsolete code comment
Message-ID: <20190320122011.stuoqugpjdt3d7cd@d104.suse.de>
References: <20190320073540.12866-1-bhe@redhat.com>
 <20190320111959.GV19508@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320111959.GV19508@bombadil.infradead.org>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 04:19:59AM -0700, Matthew Wilcox wrote:
> On Wed, Mar 20, 2019 at 03:35:38PM +0800, Baoquan He wrote:
> >  /*
> > - * returns the number of sections whose mem_maps were properly
> > - * set.  If this is <=0, then that means that the passed-in
> > - * map was not consumed and must be freed.
> > + * sparse_add_one_section - add a memory section
> > + * @nid:	The node to add section on
> > + * @start_pfn:	start pfn of the memory range
> > + * @altmap:	device page map
> > + *
> > + * Return 0 on success and an appropriate error code otherwise.
> >   */
> 
> I think it's worth documenting what those error codes are.  Seems to be
> just -ENOMEM and -EEXIST, but it'd be nice for users to know what they
> can expect under which circumstances.
> 
> Also, -EEXIST is a bad errno to return here:
> 
> $ errno EEXIST
> EEXIST 17 File exists
> 
> What file?  I think we should be using -EBUSY instead in case this errno
> makes it back to userspace:
> 
> $ errno EBUSY
> EBUSY 16 Device or resource busy

We return -EEXIST in case the section we are trying to add is already
there, and that error is being caught by __add_pages(), which ignores the
error in case is -EXIST and keeps going with further sections.

Sure we can change that for -EBUSY, but I think -EEXIST makes more sense,
plus that kind of error is never handed back to userspace.

-- 
Oscar Salvador
SUSE L3

