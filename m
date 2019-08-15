Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8970DC433FF
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 07:02:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4885F2084D
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 07:02:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="S1ek6ieq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4885F2084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC7526B0003; Thu, 15 Aug 2019 03:02:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B77556B0005; Thu, 15 Aug 2019 03:02:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A66686B0007; Thu, 15 Aug 2019 03:02:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0194.hostedemail.com [216.40.44.194])
	by kanga.kvack.org (Postfix) with ESMTP id 86B1D6B0003
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 03:02:54 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 29CBD8248AA4
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 07:02:54 +0000 (UTC)
X-FDA: 75823769868.03.start28_5375f8b836c26
X-HE-Tag: start28_5375f8b836c26
X-Filterd-Recvd-Size: 5133
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 07:02:53 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id a21so1297461edt.11
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 00:02:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=sender:date:from:to:cc:subject:message-id:mail-followup-to
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=bLd8iBYFMq4wTFjkCmL3dJr6BJW6TqxkGakc0u927MY=;
        b=S1ek6ieqqCXxXcQ8v2TmGNi0QSaBD7Oz0rcz+gP77p7QRYhaeKnJXJgY2bZosfH15d
         Ni8hW8n9vyDdI0rL0Qm9rLHR5UDjl09kQnr8hnGPoA79FnzKbeknAY4iOyGTaRNFkybF
         h/NhNGD3n/tideJHRXRVf+P4Mmd3i1RRm//8Y=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :mail-followup-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bLd8iBYFMq4wTFjkCmL3dJr6BJW6TqxkGakc0u927MY=;
        b=Bxw/6yZee1ALbD/qB9te4GzDTgctsuMNt7/3nbytDLInZAY7TGIK8bCJ2sz6lX4obJ
         nr3YhM15AvYeQ9pB6nS4OEfAU7r7/NMZ022mFA98VXnCIcdw/WTSDD5P7PH0Xl9vfNcA
         +nEAa4nN8TSbhGOc4AE4XF4t6eu/PFNtgYsidFPqaFClHav7lmUDG20ogai79q1MRf5x
         AVJcgFI2jnxSWo8N1Q0DGoxt58rfkgbROSDUVLGL++5ktISP+UPGwAmqJAsvvQqUNpOT
         UDDECEcLSHnKNmYMu1qu9GFtXGn5r+vZK1a29Dp6EQmQcj5LMuqHeLIwJJefjYD/92ud
         Sy7g==
X-Gm-Message-State: APjAAAVT4DadbXIf4BT4hRQfGlWI488QIOrD9zLIcWEhX3xFxjyroVpW
	pyZvw8Yq6xOGYLj9zAQ7LzZpWA==
X-Google-Smtp-Source: APXvYqyy/rWJ7w566iUlFN1PbwXLJFUFl4vKsTEUf/2XNHZ/bMokuW0qAhlyp5n+kCjaGg6bKwGpzw==
X-Received: by 2002:a17:906:2401:: with SMTP id z1mr3038125eja.292.1565852572404;
        Thu, 15 Aug 2019 00:02:52 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id us11sm256760ejb.43.2019.08.15.00.02.51
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 15 Aug 2019 00:02:51 -0700 (PDT)
Date: Thu, 15 Aug 2019 09:02:49 +0200
From: Daniel Vetter <daniel@ffwll.ch>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 3/5] mm, notifier: Catch sleeping/blocking for !blockable
Message-ID: <20190815070249.GB7444@phenom.ffwll.local>
Mail-Followup-To: Jason Gunthorpe <jgg@ziepe.ca>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Daniel Vetter <daniel.vetter@intel.com>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-4-daniel.vetter@ffwll.ch>
 <20190815000029.GC11200@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815000029.GC11200@ziepe.ca>
X-Operating-System: Linux phenom 4.19.0-5-amd64 
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 09:00:29PM -0300, Jason Gunthorpe wrote:
> On Wed, Aug 14, 2019 at 10:20:25PM +0200, Daniel Vetter wrote:
> > We need to make sure implementations don't cheat and don't have a
> > possible schedule/blocking point deeply burried where review can't
> > catch it.
> > 
> > I'm not sure whether this is the best way to make sure all the
> > might_sleep() callsites trigger, and it's a bit ugly in the code flow.
> > But it gets the job done.
> > 
> > Inspired by an i915 patch series which did exactly that, because the
> > rules haven't been entirely clear to us.
> 
> I thought lockdep already was able to detect:
> 
>  spin_lock()
>  might_sleep();
>  spin_unlock()
> 
> Am I mistaken? If yes, couldn't this patch just inject a dummy lockdep
> spinlock?

Hm ... assuming I didn't get lost in the maze I think might_sleep (well
___might_sleep) doesn't do any lockdep checking at all. And we want
might_sleep, since that catches a lot more than lockdep.

Maybe you mixed it up with the hard/softirq context stuff that lockdep
tracks and complains about if you get it wrong?
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

