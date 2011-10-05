Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 004EE900149
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 04:57:58 -0400 (EDT)
Received: by bkbzs2 with SMTP id zs2so2289339bkb.14
        for <linux-mm@kvack.org>; Wed, 05 Oct 2011 01:57:56 -0700 (PDT)
Subject: Re: [PATCH v5 6/8] tcp buffer limitation: per-cgroup limit
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <4E8C1064.3030902@parallels.com>
References: <1317730680-24352-1-git-send-email-glommer@parallels.com>
	 <1317730680-24352-7-git-send-email-glommer@parallels.com>
	 <1317732535.2440.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E8C1064.3030902@parallels.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 05 Oct 2011 10:58:10 +0200
Message-ID: <1317805090.2473.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org

Le mercredi 05 octobre 2011 A  12:08 +0400, Glauber Costa a A(C)crit :
> On 10/04/2011 04:48 PM, Eric Dumazet wrote:

> > 2) Could you add const qualifiers when possible to your pointers ?
> 
> Well, I'll go over the patches again and see where I can add them.
> Any specific place site you're concerned about?

Everywhere its possible : 

It helps reader to instantly knows if a function is about to change some
part of the object or only read it, without reading function body.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
