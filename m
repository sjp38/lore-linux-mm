Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59006C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 22:28:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15F1E206C1
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 22:28:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15F1E206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=namei.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A99426B0005; Thu, 15 Aug 2019 18:28:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A49DD6B0006; Thu, 15 Aug 2019 18:28:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 938616B0007; Thu, 15 Aug 2019 18:28:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0066.hostedemail.com [216.40.44.66])
	by kanga.kvack.org (Postfix) with ESMTP id 761CF6B0005
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 18:28:04 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 0EEDB55FAE
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 22:28:04 +0000 (UTC)
X-FDA: 75826101288.05.toes25_c29011ef6b07
X-HE-Tag: toes25_c29011ef6b07
X-Filterd-Recvd-Size: 4422
Received: from namei.org (namei.org [65.99.196.166])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 22:28:03 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by namei.org (8.14.4/8.14.4) with ESMTP id x7FMR7wY025897;
	Thu, 15 Aug 2019 22:27:07 GMT
Date: Fri, 16 Aug 2019 08:27:07 +1000 (AEST)
From: James Morris <jmorris@namei.org>
To: Mark Salyzyn <salyzyn@android.com>
cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-kernel@vger.kernel.org, kernel-team@android.com,
        Stephen Smalley <sds@tycho.nsa.gov>,
        linux-security-module@vger.kernel.org, stable@vger.kernel.org,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Latchesar Ionkov <lucho@ionkov.net>,
        Dominique Martinet <asmadeus@codewreck.org>,
        David Howells <dhowells@redhat.com>, Chris Mason <clm@fb.com>,
        Josef Bacik <josef@toxicpanda.com>, David Sterba <dsterba@suse.com>,
        Jeff Layton <jlayton@kernel.org>, Sage Weil <sage@redhat.com>,
        Ilya Dryomov <idryomov@gmail.com>, Steve French <sfrench@samba.org>,
        Tyler Hicks <tyhicks@canonical.com>, Jan Kara <jack@suse.com>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>,
        Miklos Szeredi <miklos@szeredi.hu>, Bob Peterson <rpeterso@redhat.com>,
        Andreas Gruenbacher <agruenba@redhat.com>,
        David Woodhouse <dwmw2@infradead.org>,
        Richard Weinberger <richard@nod.at>, Dave Kleikamp <shaggy@kernel.org>,
        Tejun Heo <tj@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Mark Fasheh <mark@fasheh.com>, Joel Becker <jlbec@evilplan.org>,
        Joseph Qi <joseph.qi@linux.alibaba.com>,
        Mike Marshall <hubcap@omnibond.com>,
        Martin Brandenburg <martin@omnibond.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Phillip Lougher <phillip@squashfs.org.uk>,
        "Darrick J. Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org,
        Hugh Dickins <hughd@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Serge Hallyn <serge@hallyn.com>, Mimi Zohar <zohar@linux.ibm.com>,
        Paul Moore <paul@paul-moore.com>, Eric Paris <eparis@parisplace.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Vyacheslav Dubeyko <slava@dubeyko.com>,
        =?ISO-8859-15?Q?Ernesto_A=2E_Fern=E1ndez?= <ernesto.mnd.fernandez@gmail.com>,
        Mathieu Malaterre <malat@debian.org>,
        v9fs-developer@lists.sourceforge.net, linux-afs@lists.infradead.org,
        linux-btrfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        ecryptfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org,
        cluster-devel@redhat.com, linux-mtd@lists.infradead.org,
        jfs-discussion@lists.sourceforge.net, linux-nfs@vger.kernel.org,
        ocfs2-devel@oss.oracle.com, devel@lists.orangefs.org,
        linux-unionfs@vger.kernel.org, reiserfs-devel@vger.kernel.org,
        linux-mm@kvack.org, netdev@vger.kernel.org,
        linux-integrity@vger.kernel.org, selinux@vger.kernel.org
Subject: Re: [PATCH] Add flags option to get xattr method paired to
 __vfs_getxattr
In-Reply-To: <69889dec-5440-1472-ed57-380f45547581@android.com>
Message-ID: <alpine.LRH.2.21.1908160825310.22623@namei.org>
References: <20190812193320.200472-1-salyzyn@android.com> <20190813084801.GA972@kroah.com> <alpine.LRH.2.21.1908160515130.12729@namei.org> <69889dec-5440-1472-ed57-380f45547581@android.com>
User-Agent: Alpine 2.21 (LRH 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Aug 2019, Mark Salyzyn wrote:

> Good Idea, but using the same argument structure for set and get I would be
> concerned about the loss of compiler protection for the buffer argument;

Agreed, I missed that.

> struct getxattr_args {
> 	struct dentry *dentry;
> 	struct inode *inode;
> 	const char *name;
> 	void *buffer;
> 	size_t size;
> 	int flags;

Does 'get' need flags?

-- 
James Morris
<jmorris@namei.org>


