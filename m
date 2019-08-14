Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2690C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 11:00:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9EA26206C1
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 11:00:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EA26206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2538D6B0005; Wed, 14 Aug 2019 07:00:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DF536B0006; Wed, 14 Aug 2019 07:00:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A51F6B0007; Wed, 14 Aug 2019 07:00:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0241.hostedemail.com [216.40.44.241])
	by kanga.kvack.org (Postfix) with ESMTP id D7CC46B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:00:29 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 8178A4859
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 11:00:29 +0000 (UTC)
X-FDA: 75820739778.28.form25_3e6f0ecc17b1b
X-HE-Tag: form25_3e6f0ecc17b1b
X-Filterd-Recvd-Size: 6172
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 11:00:28 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3537FADEF;
	Wed, 14 Aug 2019 11:00:26 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 81D741E4200; Wed, 14 Aug 2019 13:00:22 +0200 (CEST)
Date: Wed, 14 Aug 2019 13:00:22 +0200
From: Jan Kara <jack@suse.cz>
To: Mark Salyzyn <salyzyn@android.com>
Cc: linux-kernel@vger.kernel.org, kernel-team@android.com,
	Tyler Hicks <tyhicks@canonical.com>,
	Dominique Martinet <asmadeus@codewreck.org>,
	"David S. Miller" <davem@davemloft.net>,
	Mathieu Malaterre <malat@debian.org>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	devel@driverdev.osuosl.org, Vyacheslav Dubeyko <slava@dubeyko.com>,
	Joel Becker <jlbec@evilplan.org>, Mark Fasheh <mark@fasheh.com>,
	Chris Mason <clm@fb.com>, Artem Bityutskiy <dedekind1@gmail.com>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Ernesto =?iso-8859-1?Q?A=2E_Fern=E1ndez?= <ernesto.mnd.fernandez@gmail.com>,
	Ilya Dryomov <idryomov@gmail.com>, Hugh Dickins <hughd@google.com>,
	Serge Hallyn <serge@hallyn.com>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Gao Xiang <gaoxiang25@huawei.com>, Chao Yu <yuchao0@huawei.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Adrian Hunter <adrian.hunter@intel.com>,
	Latchesar Ionkov <lucho@ionkov.net>,
	Jaegeuk Kim <jaegeuk@kernel.org>, Jeff Layton <jlayton@kernel.org>,
	Dave Kleikamp <shaggy@kernel.org>, Tejun Heo <tj@kernel.org>,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Joseph Qi <joseph.qi@linux.alibaba.com>,
	Mimi Zohar <zohar@linux.ibm.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-afs@lists.infradead.org, linux-mtd@lists.infradead.org,
	devel@lists.orangefs.org, linux-erofs@lists.ozlabs.org,
	samba-technical@lists.samba.org,
	jfs-discussion@lists.sourceforge.net,
	linux-f2fs-devel@lists.sourceforge.net,
	v9fs-developer@lists.sourceforge.net, Theodore Ts'o <tytso@mit.edu>,
	James Morris <jmorris@namei.org>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	Richard Weinberger <richard@nod.at>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	ocfs2-devel@oss.oracle.com, Eric Paris <eparis@parisplace.org>,
	Paul Moore <paul@paul-moore.com>,
	Andreas Gruenbacher <agruenba@redhat.com>, cluster-devel@redhat.com,
	David Howells <dhowells@redhat.com>,
	Bob Peterson <rpeterso@redhat.com>, Sage Weil <sage@redhat.com>,
	Steve French <sfrench@samba.org>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Phillip Lougher <phillip@squashfs.org.uk>,
	David Sterba <dsterba@suse.com>, Jan Kara <jack@suse.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Josef Bacik <josef@toxicpanda.com>,
	Stephen Smalley <sds@tycho.nsa.gov>, ceph-devel@vger.kernel.org,
	ecryptfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
	linux-cifs@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-integrity@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org, reiserfs-devel@vger.kernel.org,
	selinux@vger.kernel.org, stable@vger.kernel.org,
	Alexander Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v2] Add flags option to get xattr method paired to
 __vfs_getxattr
Message-ID: <20190814110022.GB26273@quack2.suse.cz>
References: <20190813145527.26289-1-salyzyn@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190813145527.26289-1-salyzyn@android.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 13-08-19 07:55:06, Mark Salyzyn wrote:
...
> diff --git a/fs/xattr.c b/fs/xattr.c
> index 90dd78f0eb27..71f887518d6f 100644
> --- a/fs/xattr.c
> +++ b/fs/xattr.c
...
>  ssize_t
>  __vfs_getxattr(struct dentry *dentry, struct inode *inode, const char *name,
> -	       void *value, size_t size)
> +	       void *value, size_t size, int flags)
>  {
>  	const struct xattr_handler *handler;
> -
> -	handler = xattr_resolve_name(inode, &name);
> -	if (IS_ERR(handler))
> -		return PTR_ERR(handler);
> -	if (!handler->get)
> -		return -EOPNOTSUPP;
> -	return handler->get(handler, dentry, inode, name, value, size);
> -}
> -EXPORT_SYMBOL(__vfs_getxattr);
> -
> -ssize_t
> -vfs_getxattr(struct dentry *dentry, const char *name, void *value, size_t size)
> -{
> -	struct inode *inode = dentry->d_inode;
>  	int error;
>  
> +	if (flags & XATTR_NOSECURITY)
> +		goto nolsm;

Hum, is it OK for XATTR_NOSECURITY to skip even the xattr_permission()
check? I understand that for reads of security xattrs it actually does not
matter in practice but conceptually that seems wrong to me as
XATTR_NOSECURITY is supposed to skip just security-module checks to avoid
recursion AFAIU.

> diff --git a/include/uapi/linux/xattr.h b/include/uapi/linux/xattr.h
> index c1395b5bd432..1216d777d210 100644
> --- a/include/uapi/linux/xattr.h
> +++ b/include/uapi/linux/xattr.h
> @@ -17,8 +17,9 @@
>  #if __UAPI_DEF_XATTR
>  #define __USE_KERNEL_XATTR_DEFS
>  
> -#define XATTR_CREATE	0x1	/* set value, fail if attr already exists */
> -#define XATTR_REPLACE	0x2	/* set value, fail if attr does not exist */
> +#define XATTR_CREATE	 0x1	/* set value, fail if attr already exists */
> +#define XATTR_REPLACE	 0x2	/* set value, fail if attr does not exist */
> +#define XATTR_NOSECURITY 0x4	/* get value, do not involve security check */
>  #endif

It seems confusing to export XATTR_NOSECURITY definition to userspace when
that is kernel-internal flag. I'd just define it in include/linux/xattr.h
somewhere from the top of flags space (like 0x40000000).

Otherwise the patch looks OK to me (cannot really comment on the security
module aspect of this whole thing though).

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

