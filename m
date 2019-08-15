Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 678B8C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:43:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23AEA2171F
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:43:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="rmevilO9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23AEA2171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C92D06B0003; Thu, 15 Aug 2019 16:43:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C43776B0008; Thu, 15 Aug 2019 16:43:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B323D6B000A; Thu, 15 Aug 2019 16:43:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0060.hostedemail.com [216.40.44.60])
	by kanga.kvack.org (Postfix) with ESMTP id 91CE16B0003
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:43:27 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 3A21F8248AAF
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:43:27 +0000 (UTC)
X-FDA: 75825837654.07.roll66_75645da5f6c1d
X-HE-Tag: roll66_75645da5f6c1d
X-Filterd-Recvd-Size: 6108
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:43:26 +0000 (UTC)
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5BB2B2083B;
	Thu, 15 Aug 2019 20:43:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565901805;
	bh=4MUbuhxyjB/Z/I0+KEuHYyPv1fvr/qroc0kojX6LQUI=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=rmevilO9FFuTpF1TkeHr9rMjq0tx8UWAlZu1cW/zsMuDRMCXNIqbtamv/Bh9PWjxr
	 uMcyMcUqmrlEz/U6ipnvwnFJksubQpe8uhV+mxBP/PuZfI7m0SnpKLNF/GD9rIRrXm
	 9i2PofIAyA1t7LZj0WwS4y+NrRc1E+LScCfI1k7c=
Date: Thu, 15 Aug 2019 22:43:22 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: James Morris <jmorris@namei.org>
Cc: Mark Salyzyn <salyzyn@android.com>, linux-kernel@vger.kernel.org,
	kernel-team@android.com, Stephen Smalley <sds@tycho.nsa.gov>,
	linux-security-module@vger.kernel.org, stable@vger.kernel.org,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Latchesar Ionkov <lucho@ionkov.net>,
	Dominique Martinet <asmadeus@codewreck.org>,
	David Howells <dhowells@redhat.com>, Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>, David Sterba <dsterba@suse.com>,
	Jeff Layton <jlayton@kernel.org>, Sage Weil <sage@redhat.com>,
	Ilya Dryomov <idryomov@gmail.com>, Steve French <sfrench@samba.org>,
	Tyler Hicks <tyhicks@canonical.com>, Jan Kara <jack@suse.com>,
	Theodore Ts'o <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Bob Peterson <rpeterso@redhat.com>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Richard Weinberger <richard@nod.at>,
	Dave Kleikamp <shaggy@kernel.org>, Tejun Heo <tj@kernel.org>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	Mark Fasheh <mark@fasheh.com>, Joel Becker <jlbec@evilplan.org>,
	Joseph Qi <joseph.qi@linux.alibaba.com>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Phillip Lougher <phillip@squashfs.org.uk>,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	linux-xfs@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Serge Hallyn <serge@hallyn.com>, Mimi Zohar <zohar@linux.ibm.com>,
	Paul Moore <paul@paul-moore.com>,
	Eric Paris <eparis@parisplace.org>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vyacheslav Dubeyko <slava@dubeyko.com>,
	Ernesto =?iso-8859-1?Q?A=2E_Fern=E1ndez?= <ernesto.mnd.fernandez@gmail.com>,
	Mathieu Malaterre <malat@debian.org>,
	v9fs-developer@lists.sourceforge.net, linux-afs@lists.infradead.org,
	linux-btrfs@vger.kernel.org, ceph-devel@vger.kernel.org,
	linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
	ecryptfs@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org, cluster-devel@redhat.com,
	linux-mtd@lists.infradead.org, jfs-discussion@lists.sourceforge.net,
	linux-nfs@vger.kernel.org, ocfs2-devel@oss.oracle.com,
	devel@lists.orangefs.org, linux-unionfs@vger.kernel.org,
	reiserfs-devel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, linux-integrity@vger.kernel.org,
	selinux@vger.kernel.org
Subject: Re: [PATCH] Add flags option to get xattr method paired to
 __vfs_getxattr
Message-ID: <20190815204322.GB6782@kroah.com>
References: <20190812193320.200472-1-salyzyn@android.com>
 <20190813084801.GA972@kroah.com>
 <alpine.LRH.2.21.1908160515130.12729@namei.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.21.1908160515130.12729@namei.org>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 05:20:36AM +1000, James Morris wrote:
> On Tue, 13 Aug 2019, Greg Kroah-Hartman wrote:
> 
> > On Mon, Aug 12, 2019 at 12:32:49PM -0700, Mark Salyzyn wrote:
> > > --- a/include/linux/xattr.h
> > > +++ b/include/linux/xattr.h
> > > @@ -30,10 +30,10 @@ struct xattr_handler {
> > >  	const char *prefix;
> > >  	int flags;      /* fs private flags */
> > >  	bool (*list)(struct dentry *dentry);
> > > -	int (*get)(const struct xattr_handler *, struct dentry *dentry,
> > > +	int (*get)(const struct xattr_handler *handler, struct dentry *dentry,
> > >  		   struct inode *inode, const char *name, void *buffer,
> > > -		   size_t size);
> > > -	int (*set)(const struct xattr_handler *, struct dentry *dentry,
> > > +		   size_t size, int flags);
> > > +	int (*set)(const struct xattr_handler *handler, struct dentry *dentry,
> > >  		   struct inode *inode, const char *name, const void *buffer,
> > >  		   size_t size, int flags);
> > 
> > Wow, 7 arguments.  Isn't there some nice rule of thumb that says once
> > you get more then 5, a function becomes impossible to understand?
> > 
> > Surely this could be a structure passed in here somehow, that way when
> > you add the 8th argument in the future, you don't have to change
> > everything yet again?  :)
> > 
> > I don't have anything concrete to offer as a replacement fix for this,
> > but to me this just feels really wrong...
> 
> How about something like:
> 
> struct xattr_gs_args {
> 	struct dentry *dentry;
> 	struct inode *inode;

As he said in a later message, dentry and inode is redundant, only 1 is
needed (dentry I think?)

> 	const char *name;
> 	const void *buffer;
> 	size_t size;
> 	int flags;
> };
> 
> int (*get)(const struct xattr_handler *handler, struct xattr_gs_args *args);
> int (*set)(const struct xattr_handler *handler, struct xattr_gs_args *args);

But yes, that would be much much better.

thanks,

greg k-h

