Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E97508D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 16:33:26 -0500 (EST)
Message-ID: <4CE055A4.5010403@aljex.com>
Date: Sun, 14 Nov 2010 16:33:24 -0500
From: "Brian K. White" <brian@aljex.com>
MIME-Version: 1.0
Subject: Re: fadvise DONTNEED implementation (or lack thereof)
References: <20101109162525.BC87.A69D9226@jp.fujitsu.com>	<877hgmr72o.fsf@gmail.com>	<20101114140920.E013.A69D9226@jp.fujitsu.com> <87y68wiipy.fsf@gmail.com>
In-Reply-To: <87y68wiipy.fsf@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: rsync@lists.samba.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11/14/2010 12:20 AM, Ben Gamari wrote:
> On Sun, 14 Nov 2010 14:09:29 +0900 (JST), KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>  wrote:
>> Because we have an alternative solution already. please try memcgroup :)
>>
> Alright, fair enough. It still seems like there are many cases where
> fadvise seems more appropriate, but memcg should at least satisfy my
> personal needs so I'll shut up now. Thanks!
>
> - Ben

Could someone expand on this a little?

The "there are no users of this feature" argument is indeed a silly one. 
I've only wanted the ability to perform i/o without poisoning the cache 
since oh, 10 or more years ago at least. It really hurts my users since 
they are all direct login interactive db app users. No load balancing 
web interface can hide the fact when a box goes to a crawl.

How would one use memcgroup to prevent a backup or other large file 
operation from wiping out the cache with used-once garbage?

(note for rsync in particular, how does this help rsync on other platforms?)

-- 
bkw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
