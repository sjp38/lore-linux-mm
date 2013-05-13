Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 876136B0082
	for <linux-mm@kvack.org>; Mon, 13 May 2013 15:20:55 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id hn14so939504wib.8
        for <linux-mm@kvack.org>; Mon, 13 May 2013 12:20:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1368472103-3427-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1368472103-3427-1-git-send-email-cody@linux.vnet.ibm.com>
Date: Mon, 13 May 2013 22:20:53 +0300
Message-ID: <CAOJsxLF7xCiJmNn71zuNPGx1WzSj2BKeMVGXctfzvZODqVVU-A@mail.gmail.com>
Subject: Re: [PATCH RESEND v3 00/11] mm: fixup changers of per cpu pageset's
 ->high and ->batch
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Simon Jeons <simon.jeons@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Cody,

On Mon, May 13, 2013 at 10:08 PM, Cody P Schafer
<cody@linux.vnet.ibm.com> wrote:
> "Problems" with the current code:
>  1. there is a lack of synchronization in setting ->high and ->batch in
>     percpu_pagelist_fraction_sysctl_handler()
>  2. stop_machine() in zone_pcp_update() is unnecissary.
>  3. zone_pcp_update() does not consider the case where percpu_pagelist_fraction is non-zero

Maybe it's just me but I find the above problem description confusing.
How does the problem manifest itself? How did you find about it? Why
do we need to fix all three problems in the same patch set?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
