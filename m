Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 474286B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 08:55:13 -0400 (EDT)
Received: by obdfc2 with SMTP id fc2so18271259obd.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 05:55:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r8si1592611obf.7.2015.03.25.05.55.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 05:55:12 -0700 (PDT)
Date: Wed, 25 Mar 2015 13:53:10 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v3] prctl: avoid using mmap_sem for exe_file
	serialization
Message-ID: <20150325125310.GA18293@redhat.com>
References: <20150320144715.24899.24547.stgit@buzz> <1427134273.2412.12.camel@stgolabs.net> <20150323191055.GA10212@redhat.com> <55119B3B.5020403@yandex-team.ru> <20150324181016.GA9678@redhat.com> <CALYGNiP15BLtxMmMnpEu94jZBtce7tCtJnavrguqFr1d2XxH_A@mail.gmail.com> <20150324190229.GC11834@redhat.com> <1427247055.2412.23.camel@stgolabs.net> <55127E2A.4040204@yandex-team.ru> <1427280150.2412.26.camel@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427280150.2412.26.camel@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 03/25, Davidlohr Bueso wrote:
>
> Changes from v2: use correct exe_file (sigh), per Konstantin.

Looks good, thanks!

Acked-by: Oleg Nesterov <oleg@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
