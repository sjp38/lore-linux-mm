Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AB1896B0012
	for <linux-mm@kvack.org>; Wed, 25 May 2011 03:36:13 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 093FA3EE0B5
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:36:10 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E345C45DF53
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:36:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CA69B45DF57
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:36:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BDFE41DB802C
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:36:09 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B2391DB803C
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:36:09 +0900 (JST)
Message-ID: <4DDCB160.8040009@jp.fujitsu.com>
Date: Wed, 25 May 2011 16:36:00 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] set_migratetype_isolate: remove unused variable.
References: <20110524133414.GA11674@nb-core2.darkstar.lan>	<BANLkTikEz0k8WTCAW9x7dYK2i3mm4c7tLA@mail.gmail.com> <BANLkTi=X1APdoMPE-P+xr-ADv8ivx90z-g@mail.gmail.com>
In-Reply-To: <BANLkTi=X1APdoMPE-P+xr-ADv8ivx90z-g@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kronos.it@gmail.com
Cc: minchan.kim@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

(2011/05/25 16:28), Luca Tettamanti wrote:
> On Wed, May 25, 2011 at 12:29 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
>> On Tue, May 24, 2011 at 10:34 PM, Luca Tettamanti <kronos.it@gmail.com> wrote:
>>> Signed-off-by: Luca Tettamanti <kronos.it@gmail.com>
>> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>>
>> If it's trivial, please write log body down.
> 
> Ok, I'll keep that in mind.

If you fix zero patch description issue,
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Anyway, nice catch!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
