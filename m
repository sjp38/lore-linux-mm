Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F19096B0092
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 10:06:38 -0500 (EST)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <19712.61515.201226.938553@quad.stoffel.home>
Date: Thu, 9 Dec 2010 10:05:47 -0500
From: "John Stoffel" <john@stoffel.org>
Subject: Re: [PATCH] fs/vfs/security: pass last path component to LSM on inode
 creation
In-Reply-To: <20101208194527.13537.77202.stgit@paris.rdu.redhat.com>
References: <20101208194527.13537.77202.stgit@paris.rdu.redhat.com>
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@redhat.com>
Cc: xfs-masters@oss.sgi.com, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org, cluster-devel@redhat.com, linux-mtd@lists.infradead.org, jfs-discussion@lists.sourceforge.net, ocfs2-devel@oss.oracle.com, reiserfs-devel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org, linux-security-module@vger.kernel.org, chris.mason@oracle.com, jack@suse.cz, akpm@linux-foundation.org, adilger.kernel@dilger.ca, tytso@mit.edu, swhiteho@redhat.com, dwmw2@infradead.org, shaggy@linux.vnet.ibm.com, mfasheh@suse.com, joel.becker@oracle.com, aelder@sgi.com, hughd@google.com, jmorris@namei.org, sds@tycho.nsa.gov, eparis@parisplace.org, hch@lst.de, dchinner@redhat.com, viro@zeniv.linux.org.uk, tao.ma@oracle.com, shemminger@vyatta.com, jeffm@suse.com, serue@us.ibm.com, paul.moore@hp.com, penguin-kernel@I-love.SAKURA.ne.jp, casey@schaufler-ca.com, kees.cook@canonical.com, dhowells@redhat.com
List-ID: <linux-mm.kvack.org>

>>>>> "Eric" == Eric Paris <eparis@redhat.com> writes:

Eric> SELinux would like to implement a new labeling behavior of newly
Eric> created inodes.  We currently label new inodes based on the
Eric> parent and the creating process.  This new behavior would also
Eric> take into account the name of the new object when deciding the
Eric> new label.  This is not the (supposed) full path, just the last
Eric> component of the path.

Eric> This is very useful because creating /etc/shadow is different
Eric> than creating /etc/passwd but the kernel hooks are unable to
Eric> differentiate these operations.  We currently require that
Eric> userspace realize it is doing some difficult operation like that
Eric> and than userspace jumps through SELinux hoops to get things set
Eric> up correctly.  This patch does not implement new behavior, that
Eric> is obviously contained in a seperate SELinux patch, but it does
Eric> pass the needed name down to the correct LSM hook.  If no such
Eric> name exists it is fine to pass NULL.

I've looked this patch over, and maybe I'm missing something, but how
does knowing the name of the file really tell you anything, esp when
you only get the filename, not the path?  What threat are you
addressing with this change?  

So what happens when I create a file /home/john/shadow, does selinux
(or LSM in general) then run extra checks because the filename is
'shadow' in your model?  

I *think* the overhead shouldn't be there if SELINUX is disabled, but
have you confirmed this?  How you run performance tests before/after
this change when doing lots of creations of inodes to see what sort of
performance changes might be there?

Thanks,
John

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
