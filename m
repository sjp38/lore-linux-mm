Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id F04436B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 19:18:44 -0400 (EDT)
Date: Thu, 31 May 2012 02:20:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
Message-ID: <20120530232004.GA15423@shutemov.name>
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com>
 <alpine.DEB.2.00.1205301433490.9716@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1205301433490.9716@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, bsingharora@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org

On Wed, May 30, 2012 at 02:38:25PM -0700, David Rientjes wrote:
> Why?  Because the information exported by /proc/meminfo is considered by 
> applications to be static whereas the limit of a memcg may change without 
> any knowledge of the application.

Memory hotplug does the same, right?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
