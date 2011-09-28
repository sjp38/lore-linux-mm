Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A9CC49000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 20:59:17 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 862783EE0BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 09:59:13 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5576445DEB8
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 09:59:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 35B7E45DEB5
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 09:59:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2306B1DB803E
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 09:59:13 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D62251DB8040
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 09:59:12 +0900 (JST)
Date: Wed, 28 Sep 2011 09:58:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 1/7] Basic kernel memory functionality for the Memory
 Controller
Message-Id: <20110928095826.eb8ebc8c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4E81084F.9010208@parallels.com>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com>
	<1316393805-3005-2-git-send-email-glommer@parallels.com>
	<20110926193451.b419f630.kamezawa.hiroyu@jp.fujitsu.com>
	<4E81084F.9010208@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name

On Mon, 26 Sep 2011 20:18:39 -0300
Glauber Costa <glommer@parallels.com> wrote:

> On 09/26/2011 07:34 AM, KAMEZAWA Hiroyuki wrote:
> > On Sun, 18 Sep 2011 21:56:39 -0300
> > Glauber Costa<glommer@parallels.com>  wrote:
"If parent sets use_hierarchy==1, children must have the same kmem_independent value
> > with parant's one."
> >
> > How do you think ? I think a hierarchy must have the same config.
> BTW, Kame:
> 
> Look again (I forgot myself when I first replied to you)
> Only in the root cgroup those files get registered.
> So shouldn't be a problem, because children won't even
> be able to see them.
> 
> Do you agree with this ?
> 

agreed.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
