Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9629000C2
	for <linux-mm@kvack.org>; Fri,  8 Jul 2011 12:18:08 -0400 (EDT)
Date: Fri, 8 Jul 2011 17:17:22 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] fs/vfs/security: pass last path component to LSM on
 inode creation
Message-ID: <20110708161722.GG11013@ZenIV.linux.org.uk>
References: <20101208194527.13537.77202.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101208194527.13537.77202.stgit@paris.rdu.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Paris <eparis@redhat.com>
Cc: xfs-masters@oss.sgi.com, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org, cluster-devel@redhat.com, linux-mtd@lists.infradead.org, jfs-discussion@lists.sourceforge.net, ocfs2-devel@oss.oracle.com, reiserfs-devel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org, linux-security-module@vger.kernel.org, jack@suse.cz, penguin-kernel@I-love.SAKURA.ne.jp, jeffm@suse.com, jmorris@namei.org, dhowells@redhat.com, adilger.kernel@dilger.ca, shaggy@linux.vnet.ibm.com, shemminger@vyatta.com, hch@lst.de, hughd@google.com, joel.becker@oracle.com, chris.mason@oracle.com, aelder@sgi.com, kees.cook@canonical.com, sds@tycho.nsa.gov, paul.moore@hp.com, mfasheh@suse.com, dchinner@redhat.com, eparis@parisplace.org, swhiteho@redhat.com, tao.ma@oracle.com, tytso@mit.edu, casey@schaufler-ca.com, serue@us.ibm.com, akpm@linux-foundation.org, dwmw2@infradead.org

On Wed, Dec 08, 2010 at 02:45:27PM -0500, Eric Paris wrote:
> SELinux would like to implement a new labeling behavior of newly created
> inodes.  We currently label new inodes based on the parent and the creating
> process.  This new behavior would also take into account the name of the
> new object when deciding the new label.  This is not the (supposed) full path,
> just the last component of the path.
> 
> This is very useful because creating /etc/shadow is different than creating
> /etc/passwd but the kernel hooks are unable to differentiate these
> operations.  We currently require that userspace realize it is doing some
> difficult operation like that and than userspace jumps through SELinux hoops
> to get things set up correctly.  This patch does not implement new
> behavior, that is obviously contained in a seperate SELinux patch, but it
> does pass the needed name down to the correct LSM hook.  If no such name
> exists it is fine to pass NULL.

-ETOOFUCKINGUGLY...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
