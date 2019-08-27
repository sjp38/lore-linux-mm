Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06E05C3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 17:06:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BAA9C2173E
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 17:06:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BAA9C2173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AF956B0008; Tue, 27 Aug 2019 13:06:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 661366B000A; Tue, 27 Aug 2019 13:06:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FFEB6B000C; Tue, 27 Aug 2019 13:06:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0210.hostedemail.com [216.40.44.210])
	by kanga.kvack.org (Postfix) with ESMTP id 2CB656B0008
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 13:06:46 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id CB8C8181AC9AE
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 17:06:45 +0000 (UTC)
X-FDA: 75868837170.12.sail88_57fea7e21e72e
X-HE-Tag: sail88_57fea7e21e72e
X-Filterd-Recvd-Size: 10567
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 17:06:44 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6C032B03C;
	Tue, 27 Aug 2019 17:06:41 +0000 (UTC)
Received: by ds.suse.cz (Postfix, from userid 10065)
	id D57F2DA809; Tue, 27 Aug 2019 19:07:00 +0200 (CEST)
Date: Tue, 27 Aug 2019 19:07:00 +0200
From: David Sterba <dsterba@suse.cz>
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
	Ilya Dryomov <idryomov@gmail.com>,
	Bharath Vedartham <linux.bhar@gmail.com>,
	Eric Biggers <ebiggers@google.com>, Hugh Dickins <hughd@google.com>,
	Jann Horn <jannh@google.com>, Serge Hallyn <serge@hallyn.com>,
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
	v9fs-developer@lists.sourceforge.net,
	Jonathan Corbet <corbet@lwn.net>, Theodore Ts'o <tytso@mit.edu>,
	James Morris <jmorris@namei.org>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	Richard Weinberger <richard@nod.at>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>,
	Allison Henderson <allison.henderson@oracle.com>,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	ocfs2-devel@oss.oracle.com, Eric Paris <eparis@parisplace.org>,
	Paul Moore <paul@paul-moore.com>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	Benjamin Coddington <bcodding@redhat.com>,
	"J. Bruce Fields" <bfields@redhat.com>,
	Brian Foster <bfoster@redhat.com>, cluster-devel@redhat.com,
	Dave Chinner <dchinner@redhat.com>,
	David Howells <dhowells@redhat.com>,
	Bob Peterson <rpeterso@redhat.com>, Sage Weil <sage@redhat.com>,
	Steve French <sfrench@samba.org>,
	Eric Sandeen <sandeen@sandeen.net>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Phillip Lougher <phillip@squashfs.org.uk>,
	David Sterba <dsterba@suse.com>, Jan Kara <jack@suse.com>,
	Jan Kara <jack@suse.cz>, Miklos Szeredi <miklos@szeredi.hu>,
	Josef Bacik <josef@toxicpanda.com>,
	Stephen Smalley <sds@tycho.nsa.gov>, ceph-devel@vger.kernel.org,
	ecryptfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
	linux-cifs@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-integrity@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org, reiserfs-devel@vger.kernel.org,
	selinux@vger.kernel.org, stable@vger.kernel.org,
	Alexander Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v8] Add flags option to get xattr method paired to
 __vfs_getxattr
Message-ID: <20190827170700.GW2752@suse.cz>
Reply-To: dsterba@suse.cz
Mail-Followup-To: dsterba@suse.cz, Mark Salyzyn <salyzyn@android.com>,
	linux-kernel@vger.kernel.org, kernel-team@android.com,
	Tyler Hicks <tyhicks@canonical.com>,
	Dominique Martinet <asmadeus@codewreck.org>,
	"David S. Miller" <davem@davemloft.net>,
	Mathieu Malaterre <malat@debian.org>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	devel@driverdev.osuosl.org, Vyacheslav Dubeyko <slava@dubeyko.com>,
	Joel Becker <jlbec@evilplan.org>, Mark Fasheh <mark@fasheh.com>,
	Chris Mason <clm@fb.com>, Artem Bityutskiy <dedekind1@gmail.com>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Ilya Dryomov <idryomov@gmail.com>,
	Bharath Vedartham <linux.bhar@gmail.com>,
	Eric Biggers <ebiggers@google.com>, Hugh Dickins <hughd@google.com>,
	Jann Horn <jannh@google.com>, Serge Hallyn <serge@hallyn.com>,
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
	v9fs-developer@lists.sourceforge.net,
	Jonathan Corbet <corbet@lwn.net>, Theodore Ts'o <tytso@mit.edu>,
	James Morris <jmorris@namei.org>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	Richard Weinberger <richard@nod.at>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>,
	Allison Henderson <allison.henderson@oracle.com>,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	ocfs2-devel@oss.oracle.com, Eric Paris <eparis@parisplace.org>,
	Paul Moore <paul@paul-moore.com>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	Benjamin Coddington <bcodding@redhat.com>,
	"J. Bruce Fields" <bfields@redhat.com>,
	Brian Foster <bfoster@redhat.com>, cluster-devel@redhat.com,
	Dave Chinner <dchinner@redhat.com>,
	David Howells <dhowells@redhat.com>,
	Bob Peterson <rpeterso@redhat.com>, Sage Weil <sage@redhat.com>,
	Steve French <sfrench@samba.org>,
	Eric Sandeen <sandeen@sandeen.net>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Phillip Lougher <phillip@squashfs.org.uk>,
	David Sterba <dsterba@suse.com>, Jan Kara <jack@suse.com>,
	Jan Kara <jack@suse.cz>, Miklos Szeredi <miklos@szeredi.hu>,
	Josef Bacik <josef@toxicpanda.com>,
	Stephen Smalley <sds@tycho.nsa.gov>, ceph-devel@vger.kernel.org,
	ecryptfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
	linux-cifs@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-integrity@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org, reiserfs-devel@vger.kernel.org,
	selinux@vger.kernel.org, stable@vger.kernel.org,
	Alexander Viro <viro@zeniv.linux.org.uk>
References: <20190827150544.151031-1-salyzyn@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190827150544.151031-1-salyzyn@android.com>
User-Agent: Mutt/1.5.23.1-rc1 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 27, 2019 at 08:05:15AM -0700, Mark Salyzyn wrote:
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

For btrfs

>  fs/btrfs/xattr.c                  |  36 +++++-----

Acked-by: David Sterba <dsterba@suse.com>

