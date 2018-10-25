Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B0A3C6B028D
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 07:26:15 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id c33-v6so8809402qta.20
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 04:26:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l30sor8262772qve.17.2018.10.25.04.26.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Oct 2018 04:26:14 -0700 (PDT)
MIME-Version: 1.0
References: <CADa=ObrwYaoNFn0x06mvv5W1F9oVccT5qjGM8qFBGNPoNuMUNw@mail.gmail.com>
 <20181022083322.GE32333@dhcp22.suse.cz> <20181022150815.GA4287@tower.DHCP.thefacebook.com>
 <20181022170146.GI18839@dhcp22.suse.cz>
In-Reply-To: <20181022170146.GI18839@dhcp22.suse.cz>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Thu, 25 Oct 2018 07:26:02 -0400
Message-ID: <CA+1xoqe-Q-vZ1TjyvRNfycnzr-Q3OWQa3WnWOgOvskWi9CC7cw@mail.gmail.com>
Subject: Re: Memory management issue in 4.18.15
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: guro@fb.com, Sasha Levin <alexander.levin@microsoft.com>, dairinin@gmail.com, "linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>, riel@surriel.com, hannes <hannes@cmpxchg.org>, vdavydov.dev@gmail.com, shakeelb@google.com, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>, sashal@kernel.org

On Mon, Oct 22, 2018 at 1:01 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 22-10-18 15:08:22, Roman Gushchin wrote:
> [...]
> > RE backporting: I'm slightly surprised that only one patch of the memcg
> > reclaim fix series has been backported. Either all or none makes much more
> > sense to me.
>
> Yeah, I think this is AUTOSEL trying to be clever again. I though it has
> been agreed that MM is quite good at marking patches for stable and so
> it was not considered by the machinery. Sasha?

I've talked about it briefly with Andrew, and he suggested that I'll
send him the list of AUTOSEL commits separately to avoid the noise, so
we'll try that and see what happens.


--
Thanks.
Sasha
