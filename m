Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A5CD86B0087
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 13:06:41 -0500 (EST)
Subject: Re: [PATCH] fs/vfs/security: pass last path component to LSM on
 inode creation
From: Eric Paris <eparis@redhat.com>
In-Reply-To: <19713.5738.653711.301814@quad.stoffel.home>
References: <20101208194527.13537.77202.stgit@paris.rdu.redhat.com>
	 <19712.61515.201226.938553@quad.stoffel.home>
	 <1291909941.3072.70.camel@localhost.localdomain>
	 <19713.5738.653711.301814@quad.stoffel.home>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 09 Dec 2010 13:05:21 -0500
Message-ID: <1291917921.12683.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: John Stoffel <john@stoffel.org>
Cc: xfs-masters@oss.sgi.com, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org, cluster-devel@redhat.com, linux-mtd@lists.infradead.org, jfs-discussion@lists.sourceforge.net, ocfs2-devel@oss.oracle.com, reiserfs-devel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org, linux-security-module@vger.kernel.org, chris.mason@oracle.com, jack@suse.cz, akpm@linux-foundation.org, adilger.kernel@dilger.ca, tytso@mit.edu, swhiteho@redhat.com, dwmw2@infradead.org, shaggy@linux.vnet.ibm.com, mfasheh@suse.com, joel.becker@oracle.com, aelder@sgi.com, hughd@google.com, jmorris@namei.org, sds@tycho.nsa.gov, eparis@parisplace.org, hch@lst.de, dchinner@redhat.com, viro@zeniv.linux.org.uk, shemminger@vyatta.com, jeffm@suse.com, paul.moore@hp.com, penguin-kernel@I-love.SAKURA.ne.jp, casey@schaufler-ca.com, kees.cook@canonical.com, dhowells@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 2010-12-09 at 12:48 -0500, John Stoffel wrote:
> >>>>> "Eric" == Eric Paris <eparis@redhat.com> writes:
> 
> Eric> On Thu, 2010-12-09 at 10:05 -0500, John Stoffel wrote:
> >> >>>>> "Eric" == Eric Paris <eparis@redhat.com> writes:
> 
> Eric> This patch adds a 4th piece of information, the name of the
> Eric> object being created.  An obvious situation where this will be
> Eric> useful is devtmpfs (although you'll find other examples in the
> Eric> above thread).  devtmpfs when it creates char/block devices is
> Eric> unable to distinguish between kmem and console and so they are
> Eric> created with a generic label.  hotplug/udev is then called which
> Eric> does some pathname like matching and relabels them to something
> Eric> more specific.  We've found that many people are able to race
> Eric> against this particular updating and get spurious denials in
> Eric> /dev.  With this patch devtmpfs will be able to get the labels
> Eric> correct to begin with.
> 
> So your Label based access controls are *also* based on pathnames?
> Right?

Access decisions are still based solely on the label.  This patch can
influence how new objects get their label, which makes the access
decisions indirectly path based.  You'll find a reasonable summary and
commentary on lwn in this weeks security section.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
