Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 00A208D0039
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 07:23:30 -0500 (EST)
MIME-Version: 1.0
Message-ID: <1299759429.7046.1.camel@oralap>
Date: Thu, 10 Mar 2011 04:17:09 -0800 (PST)
From: "Ricardo M. Correia" <ricardo.correia@oracle.com>
Subject: Re: [Bug 30702] New: vmalloc(GFP_NOFS) can callback file system
 evict_inode, inducing deadlock.
References: <bug-30702-27@https.bugzilla.kernel.org/>
 <20110309142311.1d8073fe.akpm@linux-foundation.org>
In-Reply-To: <20110309142311.1d8073fe.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: prasadjoshi124@gmail.com, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

Hi Andrew, Prasad,

On Wed, 2011-03-09 at 14:23 -0800, Andrew Morton wrote:
> Ricardo has been working on this.  See the thread at
> http://marc.info/?l=linux-mm&m=128942194520631&w=4

Sorry, but I am no longer working on this and unfortunately it's
unlikely that I will continue working on it in the future... :-(

Best regards,
Ricardo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
