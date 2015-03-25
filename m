Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6888F6B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 08:50:40 -0400 (EDT)
Received: by wibbg6 with SMTP id bg6so22347938wib.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 05:50:39 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bj5si4262378wjc.22.2015.03.25.05.50.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Mar 2015 05:50:38 -0700 (PDT)
Message-ID: <1427287827.7390.7.camel@stgolabs.net>
Subject: Re: [PATCH v3] prctl: avoid using mmap_sem for exe_file
 serialization
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Wed, 25 Mar 2015 05:50:27 -0700
In-Reply-To: <55129735.9030204@yandex-team.ru>
References: <20150320144715.24899.24547.stgit@buzz>
	 <1427134273.2412.12.camel@stgolabs.net> <20150323191055.GA10212@redhat.com>
			 <55119B3B.5020403@yandex-team.ru> <20150324181016.GA9678@redhat.com>
	 <CALYGNiP15BLtxMmMnpEu94jZBtce7tCtJnavrguqFr1d2XxH_A@mail.gmail.com>
	 <20150324190229.GC11834@redhat.com> <1427247055.2412.23.camel@stgolabs.net>
		 <55127E2A.4040204@yandex-team.ru> <1427280150.2412.26.camel@stgolabs.net>
	 <55129735.9030204@yandex-team.ru>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, 2015-03-25 at 14:08 +0300, Konstantin Khlebnikov wrote:
> Reviewed-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Thanks.

> If this is preparation for future rework of mmap_sem maybe we could
> postpone committing this patch.

Personally, I think this patch is fine to commit for v4.1, along with
your rcu one, regardless of my mmap_sem work (which is still a wip).
Furthermore we've already got all the exe_file users updated now in
next, so I'd like to wrap this exe_file thing up if nobody has any
objections.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
