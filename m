Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 1EDC06B004D
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 15:17:20 -0500 (EST)
Date: Tue, 6 Mar 2012 17:15:37 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [patch] mm, mempolicy: dummy slab_node return value for bugless
 kernels
Message-ID: <20120306201536.GA2613@x61.redhat.com>
References: <alpine.DEB.2.00.1203041341340.9534@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1203041341340.9534@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Sun, Mar 04, 2012 at 01:43:32PM -0800, David Rientjes wrote:
> BUG() is a no-op when CONFIG_BUG is disabled, so slab_node() needs a
> dummy return value to avoid reaching the end of a non-void function.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
Nice catch!

Reviewed-by: Rafael Aquini <aquini@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
