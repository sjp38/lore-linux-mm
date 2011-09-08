Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 969546B0186
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 06:09:33 -0400 (EDT)
Date: Thu, 8 Sep 2011 12:09:23 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH] memcg: drain all stocks for the cgroup before read usage
Message-ID: <20110908100923.GD1316@redhat.com>
References: <1315098933-29464-1-git-send-email-kirill@shutemov.name>
 <20110905085913.8f84278e.kamezawa.hiroyu@jp.fujitsu.com>
 <20110905101607.cd946a46.nishimura@mxp.nes.nec.co.jp>
 <20110907213340.GA7690@shutemov.name>
 <20110908091914.6daeab1e.kamezawa.hiroyu@jp.fujitsu.com>
 <20110908004906.GA8499@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110908004906.GA8499@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 08, 2011 at 03:49:07AM +0300, Kirill A. Shutemov wrote:
> On Thu, Sep 08, 2011 at 09:19:14AM +0900, KAMEZAWA Hiroyuki wrote:
> > > Should we have field 'ram' (or 'memory') for rss+cache in memory.stat?
> > 
> > Why do you think so ?
> 
> It may be useful for scripting purpose. Just an idea.

$ awk '/^cache/{mem+=$2} /^rss/{mem+=$2} END{print(mem)}' /sys/fs/cgroup/memory/memory.stat 
1904500736

Am I missing something here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
