Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id E76D56B004D
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 06:53:41 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id c4so2220229eek.14
        for <linux-mm@kvack.org>; Fri, 02 Nov 2012 03:53:40 -0700 (PDT)
Message-ID: <5093A631.5020209@suse.cz>
Date: Fri, 02 Nov 2012 11:53:37 +0100
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: kswapd0: excessive CPU usage
References: <507688CC.9000104@suse.cz> <106695.1349963080@turing-police.cc.vt.edu> <5076E700.2030909@suse.cz> <118079.1349978211@turing-police.cc.vt.edu> <50770905.5070904@suse.cz> <119175.1349979570@turing-police.cc.vt.edu> <5077434D.7080008@suse.cz> <50780F26.7070007@suse.cz> <20121012135726.GY29125@suse.de> <507BDD45.1070705@suse.cz> <20121015110937.GE29125@suse.de> <5093A3F4.8090108@redhat.com>
In-Reply-To: <5093A3F4.8090108@redhat.com>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zdenek Kabelac <zkabelac@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 11/02/2012 11:44 AM, Zdenek Kabelac wrote:
>>> Yes, applying this instead of the revert fixes the issue as well.
> 
> I've applied this patch on 3.7.0-rc3 kernel - and I still see excessive
> CPU usage - mainly  after  suspend/resume
> 
> Here is just simple  kswapd backtrace from running kernel:

Yup, this is what we were seeing with the former patch only too. Try to
apply the other one too:
https://patchwork.kernel.org/patch/1673231/

For me I would say, it is fixed by the two patches now. I won't be able
to report later, since I'm leaving to a conference tomorrow.

> kswapd0         R  running task        0    30      2 0x00000000
...
>  [<ffffffff81141e2a>] shrink_slab+0xba/0x510

thanks,
-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
