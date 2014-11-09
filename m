Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 940596B00D6
	for <linux-mm@kvack.org>; Sun,  9 Nov 2014 17:32:29 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id r20so8831873wiv.4
        for <linux-mm@kvack.org>; Sun, 09 Nov 2014 14:32:28 -0800 (PST)
Received: from mail.logic.tuwien.ac.at (dovecot.logic.tuwien.ac.at. [128.130.175.61])
        by mx.google.com with ESMTPS id e9si26505923wjy.35.2014.11.09.14.32.28
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 09 Nov 2014 14:32:28 -0800 (PST)
Date: Mon, 10 Nov 2014 07:32:26 +0900
From: Norbert Preining <preining@logic.at>
Subject: Re: Early test: hangs in mm/compact.c w. Linus's 12d7aacab56e9ef185c
Message-ID: <20141109223226.GR11838@auth.logic.tuwien.ac.at>
References: <12996532.NCRhVKzS9J@xorhgos3.pefnos>
 <3583067.00bS4AInhm@xorhgos3.pefnos>
 <545BEA3B.40005@suse.cz>
 <3443150.6EQzxj6Rt9@xorhgos3.pefnos>
 <545E96BD.5040103@suse.cz>
 <20141109082746.GA3402@amd>
 <545F3724.7070502@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <545F3724.7070502@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Pavel Machek <pavel@ucw.cz>, "P. Christeas" <xrg@linux.gr>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, lkml <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, Markus Trippelsdorf <markus@trippelsdorf.de>

Hi Vlastimil, hi all,

On Sun, 09 Nov 2014, Vlastimil Babka wrote:
> I don't want to send untested fix, and wasn't able to reproduce the bug
> myself. I think Norbert could do it rather quickly so I hope he can tell
> us soon.

Sorry, weekend means I am away from my laptop for extended times,
and I wanted to give it a bit of stress testing.

No problems till now, no hangs, all working as expected with
your latest patch.

Thanks a lot

Norbert

------------------------------------------------------------------------
PREINING, Norbert                               http://www.preining.info
JAIST, Japan                                 TeX Live & Debian Developer
GPG: 0x860CDC13   fp: F7D8 A928 26E3 16A1 9FA0  ACF0 6CAC A448 860C DC13
------------------------------------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
