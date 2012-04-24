Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id F396F6B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 04:47:06 -0400 (EDT)
Date: Tue, 24 Apr 2012 09:47:03 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v2] mm:vmstat - Removed debug fs entries on failure of
 file creation and made extfrag_debug_root dentry local
Message-ID: <20120424084703.GC3095@csn.ul.ie>
References: <1335216593-8890-1-git-send-email-sasikanth.v19@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1335216593-8890-1-git-send-email-sasikanth.v19@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasikantha babu <sasikanth.v19@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 24, 2012 at 02:59:53AM +0530, Sasikantha babu wrote:
> Removed debug fs files and directory on failure. Since no one using "extfrag_debug_root" dentry outside of function
> extfrag_debug_init made it local to the function.
> 
> Signed-off-by: Sasikantha babu <sasikanth.v19@gmail.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
