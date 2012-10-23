Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 7A0066B0070
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 18:42:20 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so3328766pad.14
        for <linux-mm@kvack.org>; Tue, 23 Oct 2012 15:42:19 -0700 (PDT)
Date: Tue, 23 Oct 2012 15:42:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Major performance regressions in 3.7rc1/2
In-Reply-To: <CAJL_dMvUktOx9BqFm5jn2JbWbL_RWH412rdU+=rtDUvkuaPRUw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1210231541350.1221@chino.kir.corp.google.com>
References: <CAGPN=9Qx1JAr6CGO-JfoR2ksTJG_CLLZY_oBA_TFMzA_OSfiFg@mail.gmail.com> <20121022173315.7b0da762@ilfaris> <20121022214502.0fde3adc@ilfaris> <20121022170452.cc8cc629.akpm@linux-foundation.org> <alpine.LNX.2.00.1210222059120.1136@eggly.anvils>
 <20121023110434.021d100b@ilfaris> <CAJL_dMvUktOx9BqFm5jn2JbWbL_RWH412rdU+=rtDUvkuaPRUw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anca Emanuel <anca.emanuel@gmail.com>
Cc: Julian Wollrath <jwollrath@web.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Patrik Kullman <patrik.kullman@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, 23 Oct 2012, Anca Emanuel wrote:

> I have the same problem.
> Reverting
> https://github.com/torvalds/linux/commit/957f822a0ab95e88b146638bad6209bbc315bedd
> solves the problem for me.
> 

If you don't revert anything and do

	echo 0 > /proc/sys/vm/zone_reclaim_mode

after boot, does this also fix the issue?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
