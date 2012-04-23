Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 49EA16B0044
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 17:37:51 -0400 (EDT)
Received: by iajr24 with SMTP id r24so5352iaj.14
        for <linux-mm@kvack.org>; Mon, 23 Apr 2012 14:37:50 -0700 (PDT)
Date: Mon, 23 Apr 2012 14:37:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm:vmstat - Removed debug fs entries on failure of
 file creation and made extfrag_debug_root dentry local
In-Reply-To: <1335216593-8890-1-git-send-email-sasikanth.v19@gmail.com>
Message-ID: <alpine.DEB.2.00.1204231437370.11602@chino.kir.corp.google.com>
References: <1335216593-8890-1-git-send-email-sasikanth.v19@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasikantha babu <sasikanth.v19@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 24 Apr 2012, Sasikantha babu wrote:

> Removed debug fs files and directory on failure. Since no one using "extfrag_debug_root" dentry outside of function
> extfrag_debug_init made it local to the function.
> 
> Signed-off-by: Sasikantha babu <sasikanth.v19@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
