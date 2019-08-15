Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04DFAC3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:27:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA2612089E
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:27:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="WDkCTyvJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA2612089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C1A66B0008; Thu, 15 Aug 2019 16:27:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54B1A6B000C; Thu, 15 Aug 2019 16:27:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 412506B026A; Thu, 15 Aug 2019 16:27:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0018.hostedemail.com [216.40.44.18])
	by kanga.kvack.org (Postfix) with ESMTP id 1A6CA6B0008
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:27:24 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id C32E3181AC9AE
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:27:23 +0000 (UTC)
X-FDA: 75825797166.08.fuel32_7abb96efcfd31
X-HE-Tag: fuel32_7abb96efcfd31
X-Filterd-Recvd-Size: 4780
Received: from mail-qk1-f196.google.com (mail-qk1-f196.google.com [209.85.222.196])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:27:23 +0000 (UTC)
Received: by mail-qk1-f196.google.com with SMTP id u190so2914486qkh.5
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:27:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=19kUjThyL93UzoFUD+sDXbhnnY/kB4Q4ZpZxPxHnCnk=;
        b=WDkCTyvJUR9kzGzkv9RhO/TgJXUobdIBDnZhctfrukG1MPh0gO+sRxM9SOc0beAXwp
         71DXELXxjcgZUDezoX51IYEcduNfYTWeesRhE25sMvmrNtDRGdCrt1enEmISteraTO0O
         lmYxf9n7+9HfrzbDV1CWlN5KMnzuye7yZmbHJUXbCAVue3n/XF13L/HHCLVfbebc8dyy
         wOwif/zXDbh3Clzv2PQj4NmLCizwSU+QGXc/0wbE8bSJqynbOv+SGJd8NXnmGXbl1U78
         nftbNS+4wV7MbwnPwm7cnZWNnyj2RIG06/Pk69jMSzWM3pHcSXux3UyoLc3OvczOR8m6
         jufg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=19kUjThyL93UzoFUD+sDXbhnnY/kB4Q4ZpZxPxHnCnk=;
        b=Vdex0GCrViUtM43yP8YOtzHl7t10Iv0GkEEph1FH4HciRW/ae9BkR7/tEcd6jnor6q
         3ZU/d0qCe8dHevbU/HaCNiJEFv2QbfV3n9SUp8ZMnVgsoD+D/WuAr2tmKsifNToF42bI
         T97xmOL2Uo0ZkCeKncjb4fFHb7SboQx7pIztQHIokPEXM3kRj/DKPN0pDGf2ZJ6yV5Lx
         W7l/4L7xIeAru3K7FkhzG0tEfWbLKjGWbhg4HNLoqMG/z7v9wW+CChlxK/rBvb3EhDbV
         KKoxPe/p3lh7oagygOOhJS2YO0e9J4Gju76SUzaS8UCkqju/IkqEOtB1PsjoYUS0YQsU
         SxtQ==
X-Gm-Message-State: APjAAAXHaQ0sJPlacDVdt5vY2VDy5IU2gFa84Lf3wDpu+66US1FClZ5U
	YrWMmk9tpKyT9a6yLI/Auug7CQ==
X-Google-Smtp-Source: APXvYqz+UPGFBXoX6A+UqJ5T9m9LbRff6OjnB4zgWzUGY/zA50mAxWfQ5PnYDlZwMg7P0H6sXMvVqQ==
X-Received: by 2002:a37:f902:: with SMTP id l2mr5716280qkj.218.1565900842813;
        Thu, 15 Aug 2019 13:27:22 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id t29sm2031508qtt.42.2019.08.15.13.27.22
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Aug 2019 13:27:22 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hyMLB-0000Tn-Rm; Thu, 15 Aug 2019 17:27:21 -0300
Date: Thu, 15 Aug 2019 17:27:21 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: Michal Hocko <mhocko@kernel.org>, Feng Tang <feng.tang@intel.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Kees Cook <keescook@chromium.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Linux MM <linux-mm@kvack.org>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Rientjes <rientjes@google.com>, Wei Wang <wvw@google.com>,
	Daniel Vetter <daniel.vetter@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>
Subject: Re: [Intel-gfx] [PATCH 2/5] kernel.h: Add non_block_start/end()
Message-ID: <20190815202721.GV21596@ziepe.ca>
References: <20190815132127.GI9477@dhcp22.suse.cz>
 <20190815141219.GF21596@ziepe.ca>
 <20190815155950.GN9477@dhcp22.suse.cz>
 <20190815165631.GK21596@ziepe.ca>
 <20190815174207.GR9477@dhcp22.suse.cz>
 <20190815182448.GP21596@ziepe.ca>
 <20190815190525.GS9477@dhcp22.suse.cz>
 <20190815191810.GR21596@ziepe.ca>
 <20190815193526.GT9477@dhcp22.suse.cz>
 <CAKMK7uH42EgdxL18yce-7yay=x=Gb21nBs3nY7RA92Nsd-HCNA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKMK7uH42EgdxL18yce-7yay=x=Gb21nBs3nY7RA92Nsd-HCNA@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 10:16:43PM +0200, Daniel Vetter wrote:

> So if someone can explain to me how that works with lockdep I can of
> course implement it. But afaics that doesn't exist (I tried to explain
> that somewhere else already), and I'm no really looking forward to
> hacking also on lockdep for this little series.

Hmm, kind of looks like it is done by calling preempt_disable()

Probably the debug option is CONFIG_DEBUG_PREEMPT, not lockdep?

Jason

