Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9640A6B008C
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 11:06:37 -0500 (EST)
Date: Thu, 9 Dec 2010 10:05:49 -0600
From: Serge Hallyn <serge.hallyn@canonical.com>
Subject: Re: [PATCH] fs/vfs/security: pass last path component to LSM on
 inode creation
Message-ID: <20101209160549.GA2315@peq>
References: <20101208194527.13537.77202.stgit@paris.rdu.redhat.com>
 <19712.61515.201226.938553@quad.stoffel.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <19712.61515.201226.938553@quad.stoffel.home>
Sender: owner-linux-mm@kvack.org
To: John Stoffel <john@stoffel.org>
Cc: Eric Paris <eparis@redhat.com>, xfs-masters@oss.sgi.com, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org, cluster-devel@redhat.com, linux-mtd@lists.infradead.org, jfs-discussion@lists.sourceforge.net, ocfs2-devel@oss.oracle.com, reiserfs-devel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org, linux-security-module@vger.kernel.org, chris.mason@oracle.com, jack@suse.cz, akpm@linux-foundation.org, adilger.kernel@dilger.ca, tytso@mit.edu, swhiteho@redhat.com, dwmw2@infradead.org, shaggy@linux.vnet.ibm.com, mfasheh@suse.com, joel.becker@oracle.com, aelder@sgi.com, hughd@google.com, jmorris@namei.org, sds@tycho.nsa.gov, eparis@parisplace.org, hch@lst.de, dchinner@redhat.com, viro@zeniv.linux.org.uk, tao.ma@oracle.com, shemminger@vyatta.com, jeffm@suse.com, serue@us.ibm.com, paul.moore@hp.com, penguin-kernel@I-love.SAKURA.ne.jp, casey@schaufler-ca.com, kees.cook@canonical.com, dhowells@redhat.com
List-ID: <linux-mm.kvack.org>

Quoting John Stoffel (john@stoffel.org):
> >>>>> "Eric" == Eric Paris <eparis@redhat.com> writes:
> 
> Eric> SELinux would like to implement a new labeling behavior of newly
> Eric> created inodes.  We currently label new inodes based on the
> Eric> parent and the creating process.  This new behavior would also
> Eric> take into account the name of the new object when deciding the
> Eric> new label.  This is not the (supposed) full path, just the last
> Eric> component of the path.
> 
> Eric> This is very useful because creating /etc/shadow is different
> Eric> than creating /etc/passwd but the kernel hooks are unable to
> Eric> differentiate these operations.  We currently require that
> Eric> userspace realize it is doing some difficult operation like that
> Eric> and than userspace jumps through SELinux hoops to get things set
> Eric> up correctly.  This patch does not implement new behavior, that
> Eric> is obviously contained in a seperate SELinux patch, but it does
> Eric> pass the needed name down to the correct LSM hook.  If no such
> Eric> name exists it is fine to pass NULL.
> 
> I've looked this patch over, and maybe I'm missing something, but how
> does knowing the name of the file really tell you anything, esp when
> you only get the filename, not the path?  What threat are you
> addressing with this change?  

Like you, I keep thinking back to this patch and going back and forth.
But to answer your question:  in some cases, the name of the file
(plus the context of the directory in which it is created) can tell
you what assumptions userspace will make about it.  And userspace most
definately is a part of the TCB, i.e. /bin/passwd and /bin/login.

-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
