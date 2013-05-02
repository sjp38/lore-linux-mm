Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 545C56B026A
	for <linux-mm@kvack.org>; Thu,  2 May 2013 18:00:44 -0400 (EDT)
Date: Thu, 2 May 2013 15:00:31 -0700
From: Joel Becker <jlbec@evilplan.org>
Subject: Re: [PATCH v3 06/18] ocfs2: use ->invalidatepage() length argument
Message-ID: <20130502220030.GC26770@localhost>
References: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
 <1365498867-27782-7-git-send-email-lczerner@redhat.com>
 <20130423141604.GE31170@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130423141604.GE31170@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Lukas Czerner <lczerner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Mark Fasheh <mfasheh@suse.com>, ocfs2-devel@oss.oracle.com

Acked-by: Joel Becker <jlbec@evilplan.org>

On Tue, Apr 23, 2013 at 10:16:04AM -0400, Theodore Ts'o wrote:
> On Tue, Apr 09, 2013 at 11:14:15AM +0200, Lukas Czerner wrote:
> > ->invalidatepage() aop now accepts range to invalidate so we can make
> > use of it in ocfs2_invalidatepage().
> > 
> > Signed-off-by: Lukas Czerner <lczerner@redhat.com>
> > Cc: Joel Becker <jlbec@evilplan.org>
> 
> +Mark Fasheh, ocfs2-devel
> 
> To the ocfs2 development team,
> 
> Since half of this patch series modifies ext4 extensively, and changes
> to the other file systems are relatively small, I plan to carry the
> invalidatepage patch set in the ext4 tree for the next development
> cycle (i.e., not the upcoming merge window, but the next one).  To
> that end, it would be great if you take a look at this patch set and
> send us an Acked-by signoff.
> 
> Thanks!!
> 
> 						- Ted

-- 

"Ninety feet between bases is perhaps as close as man has ever come
 to perfection."
	- Red Smith

			http://www.jlbec.org/
			jlbec@evilplan.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
