Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 392EA6B00B3
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 10:55:53 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id b13so367292wgh.29
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 07:55:52 -0700 (PDT)
Received: from lxorguk.ukuu.org.uk (lxorguk.ukuu.org.uk. [81.2.110.251])
        by mx.google.com with ESMTPS id v2si3525991eel.16.2014.04.02.07.55.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Apr 2014 07:55:52 -0700 (PDT)
Date: Wed, 2 Apr 2014 15:55:07 +0100
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
Message-ID: <20140402155507.1d976144@alan.etchedpixels.co.uk>
In-Reply-To: <20140401121920.50d1dd96c2145acc81561b82@linux-foundation.org>
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
	<20140331143217.c6ff958e1fd9944d78507418@linux-foundation.org>
	<1396306773.18499.22.camel@buesod1.americas.hpqcorp.net>
	<20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org>
	<1396308332.18499.25.camel@buesod1.americas.hpqcorp.net>
	<20140331170546.3b3e72f0.akpm@linux-foundation.org>
	<533A5CB1.1@jp.fujitsu.com>
	<20140401121920.50d1dd96c2145acc81561b82@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Davidlohr Bueso <davidlohr@hp.com>, Manfred Spraul <manfred@colorfullife.com>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Gotou, Yasunori" <y-goto@jp.fujitsu.com>, chenhanxiao <chenhanxiao@cn.fujitsu.com>, Gao feng <gaofeng@cn.fujitsu.com>

> Why aren't people just setting the sysctl to a petabyte?  What problems
> would that lead to?

Historically - hanging on real world desktop systems when someone
accidentally creates a giant SHM segment and maps it.

If you are running with vm overcmmit set to actually do checks then it
*shouldn't* blow up nowdays.

More to the point wtf are people still using prehistoric sys5 IPC APIs
not shmemfs/posix shmem ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
