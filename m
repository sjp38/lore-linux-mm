Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id C38206B0071
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 21:17:01 -0400 (EDT)
Received: by patj18 with SMTP id j18so96943118pat.2
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 18:17:01 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id nb3si13691259pbc.151.2015.04.07.18.16.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Apr 2015 18:17:00 -0700 (PDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC PATCH 00/11] an introduction of library operating system for Linux (LibOS)
In-Reply-To: <m2wq1uq944.wl@wide.ad.jp>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp> <551164ED.5000907@nod.at> <m2twxacw13.wl@sfc.wide.ad.jp> <55117565.6080002@nod.at> <m2sicuctb2.wl@sfc.wide.ad.jp> <55118277.5070909@nod.at> <m2bnjhcevt.wl@sfc.wide.ad.jp> <55133BAF.30301@nod.at> <m2h9t7bubh.wl@wide.ad.jp> <5514560A.7040707@nod.at> <m28uejaqyn.wl@wide.ad.jp> <55152137.20405@nod.at> <m2sicnalnh.wl@sfc.wide.ad.jp> <87iodgocu4.fsf@rustcorp.com.au> <m2wq1uq944.wl@wide.ad.jp>
Date: Tue, 07 Apr 2015 10:55:51 +0930
Message-ID: <87fv8c3f1c.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hajime Tazaki <tazaki@wide.ad.jp>
Cc: richard@nod.at, linux-arch@vger.kernel.org, arnd@arndb.de, corbet@lwn.net, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, jdike@addtoit.com, mathieu.lacage@gmail.com

Hajime Tazaki <tazaki@wide.ad.jp> writes:
> is it the following ? it's really cool stuff !
>
> https://github.com/rustyrussell/pettycoin/blob/master/test/mockup.sh

Yep.  It's ugly, but it Works For Me(TM).

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
