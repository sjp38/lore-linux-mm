Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 576888D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 18:23:28 -0500 (EST)
Message-ID: <4D6D7FEA.80800@cesarb.net>
Date: Tue, 01 Mar 2011 20:23:22 -0300
From: Cesar Eduardo Barros <cesarb@cesarb.net>
MIME-Version: 1.0
Subject: Re: [PATCH 00/24] Refactor sys_swapon
References: <4D56D5F9.8000609@cesarb.net> <20110301182051.GB3664@mgebm.net>
In-Reply-To: <20110301182051.GB3664@mgebm.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@mgebm.net>
Cc: linux-mm@kvack.org

Em 01-03-2011 15:20, Eric B Munson escreveu:
> On Sat, 12 Feb 2011, Cesar Eduardo Barros wrote:
>
>> This patch series refactors the sys_swapon function.
>
> I have been working on reviewing/testing this set and I cannot get it
> to apply to Linus' tree, what is this set based on?

According to the git tree from which I generated these patches, it was 
based on v2.6.38-rc4.

Commit 8074b26 (mm: fix refcounting in swapon) is what probably is 
causing you conflicts. I was planning to rebase and repost this patch 
series this weekend because of it.

I just did a quick rebase to Linus' current tree, and will post the 
whole set as a reply to this email. I have not even compile tested it, 
but the change is so small that, unless I made a typo when fixing the 
merge conflicts, it should work the same. The patches affected are 08 
(context only), 10, and 13.

-- 
Cesar Eduardo Barros
cesarb@cesarb.net
cesar.barros@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
