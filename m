Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 145896B0005
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 15:26:39 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id q63so453774wrb.16
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 12:26:39 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 39sor3189868wry.65.2018.01.25.12.20.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jan 2018 12:20:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAOQ4uxhyZNghjQU5atNv5xtgdHzA75UayphCyQDzxjM8GDTv3Q@mail.gmail.com>
References: <20171030124358.GF23278@quack2.suse.cz> <76a4d544-833a-5f42-a898-115640b6783b@alibaba-inc.com>
 <20171031101238.GD8989@quack2.suse.cz> <20171109135444.znaksm4fucmpuylf@dhcp22.suse.cz>
 <10924085-6275-125f-d56b-547d734b6f4e@alibaba-inc.com> <20171114093909.dbhlm26qnrrb2ww4@dhcp22.suse.cz>
 <afa2dc80-16a3-d3d1-5090-9430eaafc841@alibaba-inc.com> <20171115093131.GA17359@quack2.suse.cz>
 <CALvZod6HJO73GUfLemuAXJfr4vZ8xMOmVQpFO3vJRog-s2T-OQ@mail.gmail.com>
 <CAOQ4uxg-mTgQfTv-qO6EVwfttyOy+oFyAHyFDKTQsDOkQPyyfA@mail.gmail.com>
 <20180124103454.ibuqt3njaqbjnrfr@quack2.suse.cz> <CAOQ4uxhDpBBUrr0JWRBaNQTTaUeJ4=gnM0iij2KivaGgp1ggtg@mail.gmail.com>
 <CALvZod4PyqfaqgEswegF5uOjNwVwbY1C4ptJB0Ouvgchv2aVFg@mail.gmail.com> <CAOQ4uxhyZNghjQU5atNv5xtgdHzA75UayphCyQDzxjM8GDTv3Q@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 25 Jan 2018 12:20:03 -0800
Message-ID: <CALvZod5H4eL=YtZ3zkGG3p8gD+3=qnC3siUw1zpKL+128KufAA@mail.gmail.com>
Subject: Re: [PATCH v2] fs: fsnotify: account fsnotify metadata to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Yang Shi <yang.s@alibaba-inc.com>, Michal Hocko <mhocko@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jan 24, 2018 at 11:51 PM, Amir Goldstein <amir73il@gmail.com> wrote:
>
> There is a nicer alternative, instead of failing the file access,
> an overflow event can be queued. I sent a patch for that and Jan
> agreed to the concept, but thought we should let user opt-in for this
> change:
> https://marc.info/?l=linux-fsdevel&m=150944704716447&w=2
>
> So IMO, if user opts-in for OVERFLOW instead of ENOMEM,
> charging the listener memcg would be non controversial.
> Otherwise, I cannot say that starting to charge the listener memgc
> for events won't break any application.
>

Thanks Amir, I will send out patches soon for directed charging for
fsnotify. Also are you planning to work on the opt-in overflow for the
above case? Should I wait for your patch?

thanks,
Shakeel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
