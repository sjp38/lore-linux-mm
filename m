Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,TRACKER_ID autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 673F4C7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 16:11:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A6A721849
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 16:11:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="nnb8r1VU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A6A721849
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A31F08E000A; Thu, 18 Jul 2019 12:11:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BC7B8E0007; Thu, 18 Jul 2019 12:11:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AA948E000A; Thu, 18 Jul 2019 12:11:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 384998E0007
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 12:11:38 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l14so20273481edw.20
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 09:11:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3obEXF97WrsMpoUnrYdgG1Tyxfg+JoWnkuCsTAUEfHc=;
        b=qIQTXPnQwfPuytHT9U3WdhVBSgeFVFK1CLz2moIJhc1gL8rF9gvtR8KwQKdJkSQ0gr
         RWdmSYr1WoJEyY0vTNNvGB2eP6CpbGnFz3OR1PYWusfDND35IeIT551CYhQuJ9wg3r1m
         B8d62+bBuOQKP5ATfsL12aHrxDfyHbLRH4colLT+oDuvKSAw4igVtI4OBtH0iDqKBXvD
         j35PVj2vpfuBUVUv38jCsiw7I/xVAXjvgA6gwYyVDwyatCOgk1xVWyUebIG5yr8ko8+m
         pt7p6qQAZ7A5b85Va5Ub0HyDMovB2XKnMvdgQZXUBFpF4WlYoez2ZsgagOphXPcALG64
         Og7Q==
X-Gm-Message-State: APjAAAXoMPlHiPiy2lOf/GIDTuFDtPv3Uv8Oi3NRCcQ/nInkGWVerm9P
	qLIhGbCHD3jZzbsK+Z5jo2VVbwk8U0JebRZQ0N4WXE4XpidJSf6foDeIZ2pZZ8172d74ghcko3Y
	Y9r4znPskudoOD54n+If56Cj/zm55Fc3jVXll5mMjNf5LlTEIrXDoaA176oXkg0D6vA==
X-Received: by 2002:a50:fa83:: with SMTP id w3mr41588611edr.47.1563466297794;
        Thu, 18 Jul 2019 09:11:37 -0700 (PDT)
X-Received: by 2002:a50:fa83:: with SMTP id w3mr41588557edr.47.1563466297157;
        Thu, 18 Jul 2019 09:11:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563466297; cv=none;
        d=google.com; s=arc-20160816;
        b=rXPJusf4R5bOEybRg6rgRDtHoImBaPSy7zNa0lC19C2ufk5/Q3TEEsWW0qS480+f2J
         r5YoRNfvtWu7fchoViIVpvV/d0nSVh6Ok0NkFYxq3VoiVS31t9IDQN6bYk+o461DINx0
         +lPUepGspRwcooOU7VHSikjKNokhfeGYntObRnSO61s0uj5f32Zqa6y6BPITq/XMQS36
         FGIKzo70RdswXXprFkM7M+vFG+Uo5QATnyNRr/K81TVwNNqAsQfM3PVjFU6KdL0vpcTA
         XR3OPkP91eRjDBO/OQDGza/Lpm5lQKJrN1vMXnIQoL+GVfX7Jbxx7PeuiOSfR0uW/yAL
         mlVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3obEXF97WrsMpoUnrYdgG1Tyxfg+JoWnkuCsTAUEfHc=;
        b=LZpwSx4DVGVpIRSNwcIDhrjP27eE6h18ZvQp38+8NSKcOLw5qijZvdxN/EWGXkDcFA
         D3sDP61Zp0OTvnENF5inXXwH4M1mnf4zRldoQhSNHOlvimuIt/B/PGXuDyKFBQXkxn19
         MnFxlbpU9qzt/brzyRJQpVhE6ywJ/ncbjqs1+FgWkVOG6LgGbTyXJJRWtqXN3iUBbZ6j
         Eus3Ov9SNOhH0VActra7fjBV05UWjPJ4Zb1xcd8kz9HgFE2KPSJndOmx/bfTbgUcMaDb
         MHBVeZs6f0UPw+Z16jOflF/YZ8fvvuvFZbJjRRsT3bmMZS6e5Z3s4/JbrzDKrntZmS+U
         MR1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=nnb8r1VU;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b21sor21818156edc.13.2019.07.18.09.11.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jul 2019 09:11:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=nnb8r1VU;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3obEXF97WrsMpoUnrYdgG1Tyxfg+JoWnkuCsTAUEfHc=;
        b=nnb8r1VUxoT6Rh7UeZIiyvzQQn0SURlNnsdRcOMXX44NSPsaHqRzm9+BeyWexTq/oK
         98G5MVKnJIUPNWlSW8LoCOppPVI1fyXgjw5MSgUIrawtI1raTD5tKRhgZSMmE1UJromJ
         JREvbh0Pub5P6qZwdP8UlTPAVo8NsB6Ycrw7u2aDcUEaNSRh0gTllpY7sBURLVHjg9+e
         vLMXQz1To95LrzSRCyx7wgBwAb40UW1Sx+H/KUFdPi2alc6fxxUiXC1N2xS0o6KMM0MR
         1J5XUiJ8pwJjJk5G10IHEWpfRfXIbnqd8BFcqGMOAHG+lTa4Xjr6sOR7Omu7U8OIPGry
         jF2A==
X-Google-Smtp-Source: APXvYqw2EEs0Sl3L+PvArw6obe2M4a4Esh+Ohl1Z2Anp/tQxrPnwrWF0NvTuCVtLVZYl71EJ+CdQj7ghlr5+XD6jjJ4=
X-Received: by 2002:a50:922a:: with SMTP id i39mr41307612eda.219.1563466296738;
 Thu, 18 Jul 2019 09:11:36 -0700 (PDT)
MIME-Version: 1.0
References: <20190718024133.3873-1-leonardo@linux.ibm.com> <1563430353.3077.1.camel@suse.de>
 <0e67afe465cbbdf6ec9b122f596910cae77bc734.camel@linux.ibm.com> <20190718155704.GD30461@dhcp22.suse.cz>
In-Reply-To: <20190718155704.GD30461@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 18 Jul 2019 12:11:25 -0400
Message-ID: <CA+CK2bBU72owYSXH10LTU8NttvCASPNTNOqFfzA3XweXR3gOTw@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm/memory_hotplug: Adds option to hot-add memory in ZONE_MOVABLE
To: Michal Hocko <mhocko@kernel.org>
Cc: Leonardo Bras <leonardo@linux.ibm.com>, Oscar Salvador <osalvador@suse.de>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.ibm.com>, 
	Pavel Tatashin <pasha.tatashin@oracle.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Pasha Tatashin <Pavel.Tatashin@microsoft.com>, 
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000039, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 11:57 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 18-07-19 12:50:29, Leonardo Bras wrote:
> > On Thu, 2019-07-18 at 08:12 +0200, Oscar Salvador wrote:
> > > We do already have "movable_node" boot option, which exactly has that
> > > effect.
> > > Any hotplugged range will be placed in ZONE_MOVABLE.
> > Oh, I was not aware of it.
> >
> > > Why do we need yet another option to achieve the same? Was not that
> > > enough for your case?
> > Well, another use of this config could be doing this boot option a
> > default on any given kernel.
> > But in the above case I agree it would be wiser to add the code on
> > movable_node_is_enabled() directly, and not where I did put.
> >
> > What do you think about it?
>
> No further config options please. We do have means a more flexible way
> to achieve movable node onlining so let's use it. Or could you be more
> specific about cases which cannot use the command line option and really
> need a config option to workaround that?

Hi Michal,

Just trying to understand, if kernel parameters is the preferable
method, why do we even have

MEMORY_HOTPLUG_DEFAULT_ONLINE

It is just strange that we have a config to online memory by default
without kernel parameter, but no way to specify how to online it. It
just looks as incomplete interface to me. Perhaps this config should
be removed as well?

Pasha

