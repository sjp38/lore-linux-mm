Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id BC6F66B006C
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 03:59:58 -0400 (EDT)
Received: by lahi5 with SMTP id i5so304489lah.14
        for <linux-mm@kvack.org>; Thu, 07 Jun 2012 00:59:56 -0700 (PDT)
Message-ID: <4FD05F75.1050108@openvz.org>
Date: Thu, 07 Jun 2012 11:59:49 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: 3.4-rc7: BUG: Bad rss-counter state mm:ffff88040b56f800 idx:1
 val:-59
References: <4FBC1618.5010408@fold.natur.cuni.cz> <20120522162835.c193c8e0.akpm@linux-foundation.org> <20120522162946.2afcdb50.akpm@linux-foundation.org> <20120523172146.GA27598@redhat.com> <4FC52F17.20709@openvz.org> <20120530171158.GA8614@redhat.com>
In-Reply-To: <20120530171158.GA8614@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>, LKML <linux-kernel@vger.kernel.org>, "markus@trippelsdorf.de" <markus@trippelsdorf.de>, "hughd@google.com" <hughd@google.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Oleg Nesterov wrote:
> On 05/30, Konstantin Khlebnikov wrote:
>>
>> I don't remember why I dislike your patch.
>> For now I can only say ACK )
>
> Great.
>
> Thanks Konstantin, thanks Martin!
>
> I'll write the changelog and send the patch tomorrow.

Ding! Week is over, or I missed something? )

>
> Oleg.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
