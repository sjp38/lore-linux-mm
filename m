Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDDF5C3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 15:51:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CF47214DA
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 15:51:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="L2rOWfFT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CF47214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED9046B0008; Tue, 27 Aug 2019 11:51:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EAE856B000A; Tue, 27 Aug 2019 11:51:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9CE16B000C; Tue, 27 Aug 2019 11:51:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0126.hostedemail.com [216.40.44.126])
	by kanga.kvack.org (Postfix) with ESMTP id AEF1F6B0008
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 11:51:15 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 0BB4D758E
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 15:51:03 +0000 (UTC)
X-FDA: 75868646406.19.shock40_90671a5a7c24
X-HE-Tag: shock40_90671a5a7c24
X-Filterd-Recvd-Size: 15157
Received: from smtprelay.test.hostedemail.com (mail.test.hostedemail.com [216.40.41.5])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 15:51:01 +0000 (UTC)
Received: from forelay.test.hostedemail.com (10.5.29.251.rfc1918.com [10.5.29.251])
	by smtprelay01.test.hostedemail.com (Postfix) with ESMTP id A3C9211D54
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 15:51:01 +0000 (UTC)
Received: from forelay.prod.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by fograve01.test.hostedemail.com (Postfix) with ESMTP id 7D27023810
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 15:51:01 +0000 (UTC)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 72B43181AC9C6
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 15:49:51 +0000 (UTC)
X-FDA: 75868643382.23.crate26_902a07b520846
X-HE-Tag: crate26_902a07b520846
X-Filterd-Recvd-Size: 14164
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 15:49:50 +0000 (UTC)
Received: from tleilax.poochiereds.net (68-20-15-154.lightspeed.rlghnc.sbcglobal.net [68.20.15.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 833FF2184D;
	Tue, 27 Aug 2019 15:49:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566920989;
	bh=bbgW62YNwOw6nr0OoLy9qjvU2nnCXSu3OBPYD+Bupp4=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=L2rOWfFTV9ZENo9sY6rTomCTkAVi6eVgtVnTG5LG9plQ1qzOy8kmqkEIkcKlJccsb
	 6oQCfNdLugesaJKgynlWsJQg7kb5LVkyYTK4cR8c58Kwfjmh9eQhwGZ7v/8NIZG3RI
	 XOEmwVN1iC+LyMlqc3dSWBw7KJ+TXshlVw7j4UqM=
Message-ID: <dfc0fea49dfc77cb7631abb76e1e64ed745d25dd.camel@kernel.org>
Subject: Re: [PATCH v8] Add flags option to get xattr method paired to
 __vfs_getxattr
From: Jeff Layton <jlayton@kernel.org>
To: Mark Salyzyn <salyzyn@android.com>, linux-kernel@vger.kernel.org
Cc: kernel-team@android.com, Jan Kara <jack@suse.cz>, Stephen Smalley
 <sds@tycho.nsa.gov>, linux-security-module@vger.kernel.org, 
 stable@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Gao Xiang
 <gaoxiang25@huawei.com>, Chao Yu <yuchao0@huawei.com>, Greg Kroah-Hartman
 <gregkh@linuxfoundation.org>, Eric Van Hensbergen <ericvh@gmail.com>, 
 Latchesar Ionkov <lucho@ionkov.net>, Dominique Martinet
 <asmadeus@codewreck.org>, David Howells <dhowells@redhat.com>, Chris Mason
 <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>, David Sterba
 <dsterba@suse.com>, Sage Weil <sage@redhat.com>, Ilya Dryomov
 <idryomov@gmail.com>, Steve French <sfrench@samba.org>, Tyler Hicks
 <tyhicks@canonical.com>, Jan Kara <jack@suse.com>,  Theodore Ts'o
 <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jaegeuk Kim
 <jaegeuk@kernel.org>, Miklos Szeredi <miklos@szeredi.hu>, Bob Peterson
 <rpeterso@redhat.com>, Andreas Gruenbacher <agruenba@redhat.com>, David
 Woodhouse <dwmw2@infradead.org>, Richard Weinberger <richard@nod.at>, Dave
 Kleikamp <shaggy@kernel.org>,  Tejun Heo <tj@kernel.org>, Trond Myklebust
 <trond.myklebust@hammerspace.com>, Anna Schumaker
 <anna.schumaker@netapp.com>, Mark Fasheh <mark@fasheh.com>, Joel Becker
 <jlbec@evilplan.org>, Joseph Qi <joseph.qi@linux.alibaba.com>, Mike
 Marshall <hubcap@omnibond.com>, Martin Brandenburg <martin@omnibond.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Phillip Lougher
 <phillip@squashfs.org.uk>, Artem Bityutskiy <dedekind1@gmail.com>, Adrian
 Hunter <adrian.hunter@intel.com>, "Darrick J. Wong"
 <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Hugh Dickins
 <hughd@google.com>, "David S. Miller" <davem@davemloft.net>, Serge Hallyn
 <serge@hallyn.com>, James Morris <jmorris@namei.org>, Mimi Zohar
 <zohar@linux.ibm.com>, Paul Moore <paul@paul-moore.com>, Eric Paris
 <eparis@parisplace.org>, Casey Schaufler <casey@schaufler-ca.com>, "J.
 Bruce Fields" <bfields@redhat.com>, Eric Biggers <ebiggers@google.com>,
 Benjamin Coddington <bcodding@redhat.com>, Andrew Morton
 <akpm@linux-foundation.org>, Mathieu Malaterre <malat@debian.org>,
 Vyacheslav Dubeyko <slava@dubeyko.com>, Bharath Vedartham
 <linux.bhar@gmail.com>, Jann Horn <jannh@google.com>, Dave Chinner
 <dchinner@redhat.com>, Allison Henderson <allison.henderson@oracle.com>, 
 Brian Foster <bfoster@redhat.com>, Eric Sandeen <sandeen@sandeen.net>,
 linux-doc@vger.kernel.org,  linux-erofs@lists.ozlabs.org,
 devel@driverdev.osuosl.org,  v9fs-developer@lists.sourceforge.net,
 linux-afs@lists.infradead.org,  linux-btrfs@vger.kernel.org,
 ceph-devel@vger.kernel.org,  linux-cifs@vger.kernel.org,
 samba-technical@lists.samba.org,  ecryptfs@vger.kernel.org,
 linux-ext4@vger.kernel.org,  linux-f2fs-devel@lists.sourceforge.net,
 linux-fsdevel@vger.kernel.org,  cluster-devel@redhat.com,
 linux-mtd@lists.infradead.org,  jfs-discussion@lists.sourceforge.net,
 linux-nfs@vger.kernel.org,  ocfs2-devel@oss.oracle.com,
 devel@lists.orangefs.org,  linux-unionfs@vger.kernel.org,
 reiserfs-devel@vger.kernel.org,  linux-mm@kvack.org,
 netdev@vger.kernel.org, linux-integrity@vger.kernel.org, 
 selinux@vger.kernel.org
Date: Tue, 27 Aug 2019 11:49:41 -0400
In-Reply-To: <20190827150544.151031-1-salyzyn@android.com>
References: <20190827150544.151031-1-salyzyn@android.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.4 (3.32.4-1.fc30) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-08-27 at 08:05 -0700, Mark Salyzyn wrote:
> Replace arguments for get and set xattr methods, and __vfs_getxattr
> and __vfs_setaxtr functions with a reference to the following now
> common argument structure:
> 
> struct xattr_gs_args {
> 	struct dentry *dentry;
> 	struct inode *inode;
> 	const char *name;
> 	union {
> 		void *buffer;
> 		const void *value;
> 	};
> 	size_t size;
> 	int flags;
> };
> 
> Which in effect adds a flags option to the get method and
> __vfs_getxattr function.
> 
> Add a flag option to get xattr method that has bit flag of
> XATTR_NOSECURITY passed to it.  XATTR_NOSECURITY is generally then
> set in the __vfs_getxattr path when called by security
> infrastructure.
> 
> This handles the case of a union filesystem driver that is being
> requested by the security layer to report back the xattr data.
> 
> For the use case where access is to be blocked by the security layer.
> 
> The path then could be security(dentry) ->
> __vfs_getxattr({dentry...XATTR_NOSECURITY}) ->
> handler->get({dentry...XATTR_NOSECURITY}) ->
> __vfs_getxattr({lower_dentry...XATTR_NOSECURITY}) ->
> lower_handler->get({lower_dentry...XATTR_NOSECURITY})
> which would report back through the chain data and success as
> expected, the logging security layer at the top would have the
> data to determine the access permissions and report back the target
> context that was blocked.
> 
> Without the get handler flag, the path on a union filesystem would be
> the errant security(dentry) -> __vfs_getxattr(dentry) ->
> handler->get(dentry) -> vfs_getxattr(lower_dentry) -> nested ->
> security(lower_dentry, log off) -> lower_handler->get(lower_dentry)
> which would report back through the chain no data, and -EACCES.
> 
> For selinux for both cases, this would translate to a correctly
> determined blocked access. In the first case with this change a correct avc
> log would be reported, in the second legacy case an incorrect avc log
> would be reported against an uninitialized u:object_r:unlabeled:s0
> context making the logs cosmetically useless for audit2allow.
> 
> This patch series is inert and is the wide-spread addition of the
> flags option for xattr functions, and a replacement of __vfs_getxattr
> with __vfs_getxattr({...XATTR_NOSECURITY}).
> 
> Signed-off-by: Mark Salyzyn <salyzyn@android.com>
> Reviewed-by: Jan Kara <jack@suse.cz>
> Cc: Stephen Smalley <sds@tycho.nsa.gov>
> Cc: linux-kernel@vger.kernel.org
> Cc: kernel-team@android.com
> Cc: linux-security-module@vger.kernel.org
> Cc: stable@vger.kernel.org # 4.4, 4.9, 4.14 & 4.19
> ---
> v8:
> - Documentation reported 'struct xattr_gs_flags' rather than
>   'struct xattr_gs_flags *args' as argument to get and set methods.
> 
> v7:
> - missed spots in fs/9p/acl.c, fs/afs/xattr.c, fs/ecryptfs/crypto.c,
>   fs/ubifs/xattr.c, fs/xfs/libxfs/xfs_attr.c,
>   security/integrity/evm/evm_main.c and security/smack/smack_lsm.c.
> 
> v6:
> - kernfs missed a spot
> 
> v5:
> - introduce struct xattr_gs_args for get and set methods,
>   __vfs_getxattr and __vfs_setxattr functions.
> - cover a missing spot in ext2.
> - switch from snprintf to scnprintf for correctness.
> 
> v4:
> - ifdef __KERNEL__ around XATTR_NOSECURITY to
>   keep it colocated in uapi headers.
> 
> v3:
> - poor aim on ubifs not ubifs_xattr_get, but static xattr_get
> 
> v2:
> - Missed a spot: ubifs, erofs and afs.
> 
> v1:
> - Removed from an overlayfs patch set, and made independent.
>   Expect this to be the basis of some security improvements.
> ---
>  Documentation/filesystems/Locking |  10 ++-
>  drivers/staging/erofs/xattr.c     |   8 +--
>  fs/9p/acl.c                       |  51 +++++++-------
>  fs/9p/xattr.c                     |  19 +++--
>  fs/afs/xattr.c                    | 112 +++++++++++++-----------------
>  fs/btrfs/xattr.c                  |  36 +++++-----
>  fs/ceph/xattr.c                   |  40 +++++------
>  fs/cifs/xattr.c                   |  72 +++++++++----------
>  fs/ecryptfs/crypto.c              |  20 +++---
>  fs/ecryptfs/inode.c               |  36 ++++++----
>  fs/ecryptfs/mmap.c                |  39 ++++++-----
>  fs/ext2/xattr_security.c          |  16 ++---
>  fs/ext2/xattr_trusted.c           |  15 ++--
>  fs/ext2/xattr_user.c              |  19 +++--
>  fs/ext4/xattr_security.c          |  15 ++--
>  fs/ext4/xattr_trusted.c           |  15 ++--
>  fs/ext4/xattr_user.c              |  19 +++--
>  fs/f2fs/xattr.c                   |  42 +++++------
>  fs/fuse/xattr.c                   |  23 +++---
>  fs/gfs2/xattr.c                   |  18 ++---
>  fs/hfs/attr.c                     |  15 ++--
>  fs/hfsplus/xattr.c                |  17 +++--
>  fs/hfsplus/xattr_security.c       |  13 ++--
>  fs/hfsplus/xattr_trusted.c        |  13 ++--
>  fs/hfsplus/xattr_user.c           |  13 ++--
>  fs/jffs2/security.c               |  16 ++---
>  fs/jffs2/xattr_trusted.c          |  16 ++---
>  fs/jffs2/xattr_user.c             |  16 ++---
>  fs/jfs/xattr.c                    |  33 ++++-----
>  fs/kernfs/inode.c                 |  23 +++---
>  fs/nfs/nfs4proc.c                 |  28 ++++----
>  fs/ocfs2/xattr.c                  |  52 ++++++--------
>  fs/orangefs/xattr.c               |  19 ++---
>  fs/overlayfs/inode.c              |  43 ++++++------
>  fs/overlayfs/overlayfs.h          |   6 +-
>  fs/overlayfs/super.c              |  53 ++++++--------
>  fs/posix_acl.c                    |  23 +++---
>  fs/reiserfs/xattr.c               |   2 +-
>  fs/reiserfs/xattr_security.c      |  22 +++---
>  fs/reiserfs/xattr_trusted.c       |  22 +++---
>  fs/reiserfs/xattr_user.c          |  22 +++---
>  fs/squashfs/xattr.c               |  10 +--
>  fs/ubifs/xattr.c                  |  33 +++++----
>  fs/xattr.c                        | 112 ++++++++++++++++++------------
>  fs/xfs/libxfs/xfs_attr.c          |   4 +-
>  fs/xfs/libxfs/xfs_attr.h          |   2 +-
>  fs/xfs/xfs_xattr.c                |  35 +++++-----
>  include/linux/xattr.h             |  26 ++++---
>  include/uapi/linux/xattr.h        |   7 +-
>  mm/shmem.c                        |  21 +++---
>  net/socket.c                      |  16 ++---
>  security/commoncap.c              |  29 +++++---
>  security/integrity/evm/evm_main.c |  13 +++-
>  security/selinux/hooks.c          |  28 ++++++--
>  security/smack/smack_lsm.c        |  38 ++++++----
>  55 files changed, 732 insertions(+), 734 deletions(-)
> 
> 

[...]

>  
> diff --git a/fs/ceph/xattr.c b/fs/ceph/xattr.c
> index 939eab7aa219..c4fee624291b 100644
> --- a/fs/ceph/xattr.c
> +++ b/fs/ceph/xattr.c
> @@ -1179,22 +1179,21 @@ int __ceph_setxattr(struct inode *inode, const char *name,
>  }
>  
>  static int ceph_get_xattr_handler(const struct xattr_handler *handler,
> -				  struct dentry *dentry, struct inode *inode,
> -				  const char *name, void *value, size_t size)
> +				  struct xattr_gs_args *args)
>  {
> -	if (!ceph_is_valid_xattr(name))
> +	if (!ceph_is_valid_xattr(args->name))
>  		return -EOPNOTSUPP;
> -	return __ceph_getxattr(inode, name, value, size);
> +	return __ceph_getxattr(args->inode, args->name,
> +			       args->buffer, args->size);
>  }
>  
>  static int ceph_set_xattr_handler(const struct xattr_handler *handler,
> -				  struct dentry *unused, struct inode *inode,
> -				  const char *name, const void *value,
> -				  size_t size, int flags)
> +				  struct xattr_gs_args *args)
>  {
> -	if (!ceph_is_valid_xattr(name))
> +	if (!ceph_is_valid_xattr(args->name))
>  		return -EOPNOTSUPP;
> -	return __ceph_setxattr(inode, name, value, size, flags);
> +	return __ceph_setxattr(args->inode, args->name,
> +			       args->value, args->size, args->flags);
>  }
>  
>  static const struct xattr_handler ceph_other_xattr_handler = {
> @@ -1300,25 +1299,22 @@ void ceph_security_invalidate_secctx(struct inode *inode)
>  }
>  
>  static int ceph_xattr_set_security_label(const struct xattr_handler *handler,
> -				    struct dentry *unused, struct inode *inode,
> -				    const char *key, const void *buf,
> -				    size_t buflen, int flags)
> +					 struct xattr_gs_args *args)
>  {
> -	if (security_ismaclabel(key)) {
> -		const char *name = xattr_full_name(handler, key);
> -		return __ceph_setxattr(inode, name, buf, buflen, flags);
> -	}
> +	if (security_ismaclabel(args->name))
> +		return __ceph_setxattr(args->inode,
> +				       xattr_full_name(handler, args->name),
> +				       args->value, args->size, args->flags);
>  	return  -EOPNOTSUPP;
>  }
>  
>  static int ceph_xattr_get_security_label(const struct xattr_handler *handler,
> -				    struct dentry *unused, struct inode *inode,
> -				    const char *key, void *buf, size_t buflen)
> +					 struct xattr_gs_args *args)
>  {
> -	if (security_ismaclabel(key)) {
> -		const char *name = xattr_full_name(handler, key);
> -		return __ceph_getxattr(inode, name, buf, buflen);
> -	}
> +	if (security_ismaclabel(args->name))
> +		return __ceph_getxattr(args->inode,
> +				       xattr_full_name(handler, args->name),
> +				       args->buffer, args->size);
>  	return  -EOPNOTSUPP;
>  }
>  

The ceph bits look fine to me. Note that we do have some patches queued
up for v5.4 that might have some merge conflicts here. Shouldn't be too
hard to fix it up though.

Acked-by: Jeff Layton <jlayton@kernel.org>




