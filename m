Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E350C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 08:58:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 275B020578
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 08:58:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="c/7IxRS5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 275B020578
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B1436B0005; Wed, 28 Aug 2019 04:58:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 962476B0008; Wed, 28 Aug 2019 04:58:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 851976B000C; Wed, 28 Aug 2019 04:58:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0020.hostedemail.com [216.40.44.20])
	by kanga.kvack.org (Postfix) with ESMTP id 630136B0005
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 04:58:25 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id EB826127AF
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 08:58:24 +0000 (UTC)
X-FDA: 75871235328.17.cover59_6681c9f579104
X-HE-Tag: cover59_6681c9f579104
X-Filterd-Recvd-Size: 7823
Received: from mail-yb1-f194.google.com (mail-yb1-f194.google.com [209.85.219.194])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 08:58:24 +0000 (UTC)
Received: by mail-yb1-f194.google.com with SMTP id a17so557531ybc.0
        for <linux-mm@kvack.org>; Wed, 28 Aug 2019 01:58:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ZkpFpnYPlZJ9QcxAWETe0exvhhGufV9GcXx8KPl75dQ=;
        b=c/7IxRS5bV7/Y1D6aqVDN4h5XY8CLwleVTKbXnD1xvkPuYpdCL6KG1pUCZedAgswVL
         jl/Y/H3TL3Y7v26WGEvK2/K7kQDXltg3Gh1B2bsEXgA+f3ZfuZKs0Owowo137ADQO4O+
         cpzdYN/uTyuwxI00FWQlSRJrDeSiVoypEr2jK5PPgACNzrThi9kqlMgnjpNIbvs06isz
         sSk1xx9N3A6v0UgaCkxeg+WxsqAscnJ0NMP/ilLoKpdluNCBKsgYaS4spNoOe+kfNZNB
         7XBDgWqpy6pn08EBwgtZBm+9GjktdL94w9YatMNYYgi1jW7re8aGyyVgQPga7XhLViSE
         j9Cg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=ZkpFpnYPlZJ9QcxAWETe0exvhhGufV9GcXx8KPl75dQ=;
        b=tN9yQ+6Zwo+ZEumB4RLKUQXSqjHtwwsLfUx1v5AXNA+KAWh+ekUSVvE7aBzBW52GJv
         fMBRzvwo3LE4x2xbt1PJM2dheEffLTurqI92+oB4d+7GWa6aFPrQAeovbs0iCH0A3o/U
         ajyiw0smrJIRYOW7XCtNyGvyPBFS/sbu67ktx6maUwF8r2/klzOGmsejUvwdhCDaa2P9
         RmgEVoXPioXkqCfGsrdL6t1z/QHAfqUtbire+WG7MQ0RdPUKdd95ZDGMhuXObrppv+YD
         rUlblXY3nZEyqTmD5oX+PpNIUBUwJm9fERhFhbaPc0HgWBKaVYQJhcvoWMPUfpTM6SXj
         QGwA==
X-Gm-Message-State: APjAAAXSzaJ1o27VnwDRZNFkD0JZEW91aRfaAe/8YrzKxTgfzgCt49PN
	0uLKPS2e+fWCyNDLEPskGRZUuHfqM/7l6EimaO0=
X-Google-Smtp-Source: APXvYqzSub2GIlA5tBXI/WsJGtSH+6zioYqDGzlUhxxxj30lJtRuCO2Hlbsd4xVOf5z0HjodsXgoZMdYp6cwy9sWUoQ=
X-Received: by 2002:a25:c486:: with SMTP id u128mr2051352ybf.428.1566982703595;
 Wed, 28 Aug 2019 01:58:23 -0700 (PDT)
MIME-Version: 1.0
References: <20190820180716.129882-1-salyzyn@android.com> <20190827141952.GB10098@quack2.suse.cz>
In-Reply-To: <20190827141952.GB10098@quack2.suse.cz>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 28 Aug 2019 11:58:12 +0300
Message-ID: <CAOQ4uxgVWyiEV2s3KNT40jkUjEkn_v2MN5Z--HW=LoA_aZwNOw@mail.gmail.com>
Subject: Re: [PATCH v7] Add flags option to get xattr method paired to __vfs_getxattr
To: Mark Salyzyn <salyzyn@android.com>
Cc: Latchesar Ionkov <lucho@ionkov.net>, Eric Sandeen <sandeen@sandeen.net>, 
	Mike Marshall <hubcap@omnibond.com>, linux-xfs <linux-xfs@vger.kernel.org>, 
	James Morris <jmorris@namei.org>, devel@lists.orangefs.org, 
	Eric Van Hensbergen <ericvh@gmail.com>, Joel Becker <jlbec@evilplan.org>, 
	Trond Myklebust <trond.myklebust@hammerspace.com>, Mathieu Malaterre <malat@debian.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, 
	Jan Kara <jack@suse.com>, Casey Schaufler <casey@schaufler-ca.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Dave Kleikamp <shaggy@kernel.org>, linux-doc@vger.kernel.org, 
	Jeff Layton <jlayton@kernel.org>, Chao Yu <yuchao0@huawei.com>, 
	Mimi Zohar <zohar@linux.ibm.com>, "David S. Miller" <davem@davemloft.net>, 
	CIFS <linux-cifs@vger.kernel.org>, Paul Moore <paul@paul-moore.com>, 
	"Darrick J. Wong" <darrick.wong@oracle.com>, Hugh Dickins <hughd@google.com>, kernel-team@android.com, 
	selinux@vger.kernel.org, Brian Foster <bfoster@redhat.com>, 
	reiserfs-devel@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	Jaegeuk Kim <jaegeuk@kernel.org>, "Theodore Ts'o" <tytso@mit.edu>, Miklos Szeredi <miklos@szeredi.hu>, 
	linux-f2fs-devel@lists.sourceforge.net, 
	Benjamin Coddington <bcodding@redhat.com>, linux-integrity <linux-integrity@vger.kernel.org>, 
	Martin Brandenburg <martin@omnibond.com>, Chris Mason <clm@fb.com>, linux-mtd@lists.infradead.org, 
	linux-afs@lists.infradead.org, Jonathan Corbet <corbet@lwn.net>, 
	Vyacheslav Dubeyko <slava@dubeyko.com>, Allison Henderson <allison.henderson@oracle.com>, 
	Ilya Dryomov <idryomov@gmail.com>, Ext4 <linux-ext4@vger.kernel.org>, 
	Stephen Smalley <sds@tycho.nsa.gov>, Serge Hallyn <serge@hallyn.com>, Gao Xiang <gaoxiang25@huawei.com>, 
	Eric Paris <eparis@parisplace.org>, ceph-devel@vger.kernel.org, 
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>, Joseph Qi <joseph.qi@linux.alibaba.com>, 
	samba-technical <samba-technical@lists.samba.org>, Steve French <sfrench@samba.org>, 
	Bob Peterson <rpeterso@redhat.com>, Tejun Heo <tj@kernel.org>, linux-erofs@lists.ozlabs.org, 
	Anna Schumaker <anna.schumaker@netapp.com>, ocfs2-devel@oss.oracle.com, 
	jfs-discussion@lists.sourceforge.net, Eric Biggers <ebiggers@google.com>, 
	Dominique Martinet <asmadeus@codewreck.org>, Jeff Mahoney <jeffm@suse.com>, 
	overlayfs <linux-unionfs@vger.kernel.org>, David Howells <dhowells@redhat.com>, 
	Linux MM <linux-mm@kvack.org>, Andreas Dilger <adilger.kernel@dilger.ca>, 
	devel@driverdev.osuosl.org, "J. Bruce Fields" <bfields@redhat.com>, 
	Andreas Gruenbacher <agruenba@redhat.com>, Sage Weil <sage@redhat.com>, 
	Richard Weinberger <richard@nod.at>, Mark Fasheh <mark@fasheh.com>, 
	LSM List <linux-security-module@vger.kernel.org>, cluster-devel@redhat.com, 
	v9fs-developer@lists.sourceforge.net, 
	Bharath Vedartham <linux.bhar@gmail.com>, Jann Horn <jannh@google.com>, ecryptfs@vger.kernel.org, 
	Josef Bacik <josef@toxicpanda.com>, Dave Chinner <dchinner@redhat.com>, 
	David Sterba <dsterba@suse.com>, Artem Bityutskiy <dedekind1@gmail.com>, Netdev <netdev@vger.kernel.org>, 
	Adrian Hunter <adrian.hunter@intel.com>, stable <stable@vger.kernel.org>, 
	Tyler Hicks <tyhicks@canonical.com>, 
	=?UTF-8?Q?Ernesto_A=2E_Fern=C3=A1ndez?= <ernesto.mnd.fernandez@gmail.com>, 
	Phillip Lougher <phillip@squashfs.org.uk>, David Woodhouse <dwmw2@infradead.org>, 
	Linux Btrfs <linux-btrfs@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Jan Kara <jack@suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 11:15 AM Jan Kara via samba-technical
<samba-technical@lists.samba.org> wrote:
>
> On Tue 20-08-19 11:06:48, Mark Salyzyn wrote:
> > diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
> > index 204dd3ea36bb..e2687f21c7d6 100644
> > --- a/Documentation/filesystems/Locking
> > +++ b/Documentation/filesystems/Locking
> > @@ -101,12 +101,10 @@ of the locking scheme for directory operations.
> >  ----------------------- xattr_handler operations -----------------------
> >  prototypes:
> >       bool (*list)(struct dentry *dentry);
> > -     int (*get)(const struct xattr_handler *handler, struct dentry *dentry,
> > -                struct inode *inode, const char *name, void *buffer,
> > -                size_t size);
> > -     int (*set)(const struct xattr_handler *handler, struct dentry *dentry,
> > -                struct inode *inode, const char *name, const void *buffer,
> > -                size_t size, int flags);
> > +     int (*get)(const struct xattr_handler *handler,
> > +                struct xattr_gs_flags);
> > +     int (*set)(const struct xattr_handler *handler,
> > +                struct xattr_gs_flags);
>
> The prototype here is really "struct xattr_gs_flags *args", isn't it?
> Otherwise feel free to add:
>
> Reviewed-by: Jan Kara <jack@suse.cz>
>
> for the ext2, ext4, ocfs2, reiserfs, and the generic fs/* bits.
>
>                                                                 Honza

Mark,

That's some CC list you got there... but I never got any of your
patches because they did not
reach fsdevel list.

Did you get a rejection message from ML server?

Thanks,
Amir.

