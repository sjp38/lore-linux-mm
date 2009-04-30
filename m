Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A35356B0047
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 10:33:44 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 4so1531374qwk.44
        for <linux-mm@kvack.org>; Thu, 30 Apr 2009 07:34:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5da0588e0904300722p538cb174xcc01bbe85dd58ec8@mail.gmail.com>
References: <20090414071152.GC23528@wotan.suse.de>
	 <20090415183847.d4fa1efb.akpm@linux-foundation.org>
	 <20090428185739.GE6377@localdomain>
	 <20090429071233.GC3398@wotan.suse.de>
	 <20090429002418.fd9072a6.akpm@linux-foundation.org>
	 <20090429074511.GD3398@wotan.suse.de>
	 <1241008762.6336.5.camel@heimdal.trondhjem.org>
	 <20090429082733.f69b45c1.akpm@linux-foundation.org>
	 <1241023514.12464.2.camel@heimdal.trondhjem.org>
	 <5da0588e0904300722p538cb174xcc01bbe85dd58ec8@mail.gmail.com>
Date: Thu, 30 Apr 2009 10:33:54 -0400
Message-ID: <5da0588e0904300733t313b9168s634dfd51fc8a5b60@mail.gmail.com>
Subject: Re: [patch] mm: close page_mkwrite races (try 3)
From: Rince <rincebrain@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Ravikiran G Thirumalai <kiran@scalex86.org>, Sage Weil <sage@newdream.net>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 30, 2009 at 10:22 AM, Rince <rincebrain@gmail.com> wrote:
> four patches mentioned

Hm, somehow I missed that the NFS 3-liner above wasn't included in the
four patches.

Let's see how this goes. Apologies for the misunderstanding. :)

- Rich

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
