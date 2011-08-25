Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 73B546B0169
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 13:11:44 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <8a95a804-7ba3-416e-9ba5-8da7b9cabba5@default>
Date: Thu, 25 Aug 2011 10:11:11 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Subject: [PATCH V7 1/4] mm: frontswap: swap data structure
 changes
References: <20110823145755.GA23174@ca-server1.us.oracle.com
 20110825143312.a6fe93d5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110825143312.a6fe93d5.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com

> From: KAMEZAWA Hiroyuki [mailto:kamezawa.hiroyu@jp.fujitsu.com]
> Subject: Re: Subject: [PATCH V7 1/4] mm: frontswap: swap data structure c=
hanges

Hi Kamezawa-san --

Domo arigato for the review and feedback!

> Hmm....could you modify mm/swapfile.c and remove 'static' in the same pat=
ch ?

I separated out this header patch because I thought it would
make the key swap data structure changes more visible.  Are you
saying that it is more confusing?  Or does your compiler
have a problem after only this patch is applied? (My
compiler is fine with it.)

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
