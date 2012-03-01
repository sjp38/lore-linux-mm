Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 3C1D16B004A
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 18:29:57 -0500 (EST)
Date: Thu, 1 Mar 2012 18:29:42 -0500
From: Ted Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 00/11 v2] Push file_update_time() into .page_mkwrite
Message-ID: <20120301232942.GH32588@thunk.org>
References: <1330602103-8851-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1330602103-8851-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, dchinner@redhat.com, Jaya Kumar <jayalk@intworks.biz>, Sage Weil <sage@newdream.net>, ceph-devel@vger.kernel.org, Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, v9fs-developer@lists.sourceforge.net, Miklos Szeredi <miklos@szeredi.hu>, fuse-devel@lists.sourceforge.net, Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Thu, Mar 01, 2012 at 12:41:34PM +0100, Jan Kara wrote:
> 
> To fix the issue, this patch set changes page fault code to call
> file_update_time() only when ->page_mkwrite() callback is not provided. If the
> callback is provided, it is the responsibility of the filesystem to perform
> update of i_mtime / i_ctime if needed. We also push file_update_time() call
> to all existing ->page_mkwrite() implementations if the time update does not
> obviously happen by other means. If you know your filesystem does not need
> update of modification times in ->page_mkwrite() handler, please speak up and
> I'll drop the patch for your filesystem.

I don't know if this introductory text is going to be saved anywhere
permanent, such as the merge commit (since git now has the ability to
have much more informative merge descriptions).  But if it is going to
be preserved, it might be worth mentioning that if the filesystem uses
block_page_mkpage(), it will handled automatically for them since the
patch series does push the call to file_update_time(0 into
__block_page_mkpage().

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
