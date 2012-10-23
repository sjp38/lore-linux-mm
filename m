Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id CEBBA6B005A
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 06:52:35 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id fl17so4818414vcb.14
        for <linux-mm@kvack.org>; Tue, 23 Oct 2012 03:52:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121023110434.021d100b@ilfaris>
References: <CAGPN=9Qx1JAr6CGO-JfoR2ksTJG_CLLZY_oBA_TFMzA_OSfiFg@mail.gmail.com>
	<20121022173315.7b0da762@ilfaris>
	<20121022214502.0fde3adc@ilfaris>
	<20121022170452.cc8cc629.akpm@linux-foundation.org>
	<alpine.LNX.2.00.1210222059120.1136@eggly.anvils>
	<20121023110434.021d100b@ilfaris>
Date: Tue, 23 Oct 2012 13:52:34 +0300
Message-ID: <CAJL_dMvUktOx9BqFm5jn2JbWbL_RWH412rdU+=rtDUvkuaPRUw@mail.gmail.com>
Subject: Re: Major performance regressions in 3.7rc1/2
From: Anca Emanuel <anca.emanuel@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julian Wollrath <jwollrath@web.de>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Patrik Kullman <patrik.kullman@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

I have the same problem.
Reverting
https://github.com/torvalds/linux/commit/957f822a0ab95e88b146638bad6209bbc315bedd
solves the problem for me.

Here is dmesg: http://pastebin.com/r78Rcrf5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
