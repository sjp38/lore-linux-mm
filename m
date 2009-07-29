Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EBE7D6B00AE
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 19:25:21 -0400 (EDT)
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id n6TNPPrV007298
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 00:25:26 +0100
Received: from yxe28 (yxe28.prod.google.com [10.190.2.28])
	by spaceape7.eur.corp.google.com with ESMTP id n6TNPM7V012292
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 16:25:23 -0700
Received: by yxe28 with SMTP id 28so2088321yxe.10
        for <linux-mm@kvack.org>; Wed, 29 Jul 2009 16:25:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090729161341.269b90e3.akpm@linux-foundation.org>
References: <alpine.DEB.2.00.0907282125260.554@chino.kir.corp.google.com>
	 <20090729161341.269b90e3.akpm@linux-foundation.org>
Date: Wed, 29 Jul 2009 16:25:22 -0700
Message-ID: <6599ad830907291625k697f17d3h87d054d796c59407@mail.gmail.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 29, 2009 at 4:13 PM, Andrew Morton<akpm@linux-foundation.org> w=
rote:
>
> Do we really need to do all that string hacking? =A0All it does is reads
> a plain old integer from userspace.

It would be nice to have the equivalent of the cgroupfs read_u64 and
write_u64 methods, where you just supply a function that
accepts/returns the appropriate value, and all the buffer munging is
done in the generic code.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
