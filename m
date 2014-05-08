Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 04F466B00EA
	for <linux-mm@kvack.org>; Thu,  8 May 2014 09:54:13 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id l6so2924494qcy.3
        for <linux-mm@kvack.org>; Thu, 08 May 2014 06:54:13 -0700 (PDT)
Received: from qmta14.emeryville.ca.mail.comcast.net (qmta14.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:212])
        by mx.google.com with ESMTP id x1si492966qal.211.2014.05.08.06.54.13
        for <linux-mm@kvack.org>;
        Thu, 08 May 2014 06:54:13 -0700 (PDT)
Date: Thu, 8 May 2014 08:54:10 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch v2] mm, slab: suppress out of memory warning unless debug
 is enabled
In-Reply-To: <alpine.DEB.2.02.1405071500030.25024@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1405080853421.22626@gentwo.org>
References: <alpine.DEB.2.02.1405071418410.8389@chino.kir.corp.google.com> <20140507142925.b0e31514d4cd8d5857b10850@linux-foundation.org> <alpine.DEB.2.02.1405071431580.8454@chino.kir.corp.google.com> <20140507144858.9aee4e420908ccf9334dfdf2@linux-foundation.org>
 <alpine.DEB.2.02.1405071500030.25024@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 7 May 2014, David Rientjes wrote:

> Suppress this out of memory warning if the allocator is configured without debug
> supported.  The page allocation failure warning will indicate it is a failed
> slab allocation, the order, and the gfp mask, so this is only useful to diagnose
> allocator issues.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
