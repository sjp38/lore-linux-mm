Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05866C282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:11:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C347F217FA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:11:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C347F217FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 537E28E0004; Tue, 12 Feb 2019 10:11:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E5E58E0001; Tue, 12 Feb 2019 10:11:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AEB98E0004; Tue, 12 Feb 2019 10:11:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DA83C8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:11:48 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id d9so2527795edl.16
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 07:11:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lpURf7rgaQmoInyoKWiegYoDwQQ6vc3wBdDLEHbPQ9Y=;
        b=iHsr1DyUHmXex+oE/MC5OnxF4W6tLiF5E5BI8B7C776mdzXbnKk4ns+Polp8E3ug4L
         limEv8RdG4xLxF8ZhqC21uteNe5KpatnpudGz1RvhrshLgpgmDrtoGVSeWOnoezpeMst
         Z9nJAy2S29ruDA0cE/qBn70F+FCPmR+gH8E1W0h8kHLuVElHqZXK701bIDd0ZKzWJWwc
         kiy0QqPnVavY1ymuy51ZHiA0qTi/4nQ9CSUHxrgWlL9U+m0zl93pmfmFJeQN2yKAnjrK
         p4NAd+tzpurqDTTLzj5Lf63Dmsxp9JPGsY9WAVR5zFjhlk0ZbO8wHb3YTs3MPnNHfKHf
         oYZw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZP1G8+LUeDJibRkjFU1KzNny50rhX+J0MDL9f76eiD61FyLCNR
	HRjRXJqmKsvirl8Of5+W+kflt2ZMaStvDp0LeUNUpIapuk4RDduCWvl4kfVzmnu3wjAXYfFaW3K
	VQg6f9Yc9MRabztG41BTrOzyn8GJpFMY0sShtPOJ/F1ZrZO/LdC33ARyiNr/PgTI=
X-Received: by 2002:a17:906:5e43:: with SMTP id b3mr3029759eju.209.1549984308403;
        Tue, 12 Feb 2019 07:11:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY0Cyun25t5d3PAM+b9o8w72u2/fYZgBwdDhGIozEbdoIAZ0/XOhKBM2E8a92LgBnN5hQMs
X-Received: by 2002:a17:906:5e43:: with SMTP id b3mr3029693eju.209.1549984307192;
        Tue, 12 Feb 2019 07:11:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549984307; cv=none;
        d=google.com; s=arc-20160816;
        b=MRFDXN46mm9PQH3Zz9OJ1WbUwZj7DISpan5JGUoAr+MtPrwzOEB5HrhE5w9nkGxH5R
         DqT621bsRENmlRKbIbY1MNzocXSc6U9pALfoJBkbVBkTnUPql9Yah2eLkCB7Bqe3fb7l
         9LkRHvWwSxpCfH4KwfFgvw+c5rIz0G8Bg6l8H9K449uqT7g8qQo1nn5mjZKi4eIUtZ89
         rKlNBQUsw8QdyG3FgcR8uzvhO8w2b30IOuFKsfsomy4NAg8TMiHR1T2cPnJ0UdwIFz62
         T0rchBKJNkesrVL3TS28lW81DDOH/+WesM4CsPZwAOCYuKoZuEoUujphhv6c1hca4ynH
         1vFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lpURf7rgaQmoInyoKWiegYoDwQQ6vc3wBdDLEHbPQ9Y=;
        b=IZI2HYxOcKiZqeMsa4AJVdEV/0iHV5ocMXwWzA+AyW8OGzCR4XHBnqeDlMcWlq0/QC
         1+bNMUwKvK9nYv+GgZq6Eia47VHym1YaRTfNvb247TnL5/TkqRoGDPwG/RmrtJhpgf+A
         4VqsNQEgb8ZUWot/SEhAJ3fZLrmQKFz4JMtKPk+nlyB3ar6JYmn3FVvTJthc3K30TgJV
         7lRu7cdGZtY8XnmB4J3mo2LV0M29g05Ya6QKxbIS/E9z294WwJHXADwvHGgPrGuUDT0g
         6gM2fRf7PqfP789O4hVOTSzKmYUPO6gD/GBzf8SslWWpu9+0oxonNEgC5AuYfrVKdwgw
         koyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d13si613876ejy.63.2019.02.12.07.11.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 07:11:47 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B8A77ACEA;
	Tue, 12 Feb 2019 15:11:46 +0000 (UTC)
Date: Tue, 12 Feb 2019 16:11:46 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, rafael@kernel.org,
	akpm@linux-foundation.org, osalvador@suse.de
Subject: Re: [PATCH v2] mm/memory-hotplug: Add sysfs hot-remove trigger
Message-ID: <20190212151146.GA15609@dhcp22.suse.cz>
References: <49ef5e6c12f5ede189419d4dcced5dc04957c34d.1549906631.git.robin.murphy@arm.com>
 <20190212083310.GM15609@dhcp22.suse.cz>
 <faca65d7-6d4b-7e4f-5b36-4fdf3710b0e3@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <faca65d7-6d4b-7e4f-5b36-4fdf3710b0e3@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-02-19 14:54:36, Robin Murphy wrote:
> On 12/02/2019 08:33, Michal Hocko wrote:
> > On Mon 11-02-19 17:50:46, Robin Murphy wrote:
> > > ARCH_MEMORY_PROBE is a useful thing for testing and debugging hotplug,
> > > but being able to exercise the (arguably trickier) hot-remove path would
> > > be even more useful. Extend the feature to allow removal of offline
> > > sections to be triggered manually to aid development.
> > > 
> > > Since process dictates the new sysfs entry be documented, let's also
> > > document the existing probe entry to match - better 13-and-a-half years
> > > late than never, as they say...
> > 
> > The probe sysfs is quite dubious already TBH. Apart from testing, is
> > anybody using it for something real? Do we need to keep an API for
> > something testing only? Why isn't a customer testing module enough for
> > such a purpose?
> 
> From the arm64 angle, beyond "conventional" servers where we can hopefully
> assume ACPI, I can imagine there being embedded/HPC setups (not all as
> esoteric as that distributed-memory dRedBox thing), as well as virtual
> machines, that are DT-based with minimal runtime firmware. I'm none too keen
> on the idea either, but if such systems want to support physical hotplug
> then driving it from userspace might be the only reasonable approach. I'm
> just loath to actually document it as anything other than a developer
> feature so as not to give the impression that I consider it anything other
> than a last resort for production use.

This doesn't sound convicing to add an user API.

> I do note that my x86 distro kernel
> has ARCH_MEMORY_PROBE enabled despite it being "for testing".

Yeah, there have been mistakes done in the API land & hotplug in the
past.

> > In other words, why do we have to add an API that has to be maintained
> > for ever for a testing only purpose?
> 
> There's already half the API being maintained, though, so adding the
> corresponding other half alongside it doesn't seem like that great an
> overhead, regardless of how it ends up getting used.

As already said above. The hotplug user API is not something to follow
for the future development. So no, we are half broken let's continue is
not a reasonable argument.

> Ultimately, though,
> it's a patch I wrote because I needed it, and if everyone else is adamant
> that it's not useful enough then fair enough - it's at least in the list
> archives now so I can sleep happy that I've done my "contributing back" bit
> as best I could :)

I am not saing this is not useful. It is. But I do not think we want to
make it an official api without a strong usecase. And then we should
think twice to make the api both useable and reasonable. A kernel module
for playing sounds like more than sufficient.
-- 
Michal Hocko
SUSE Labs

