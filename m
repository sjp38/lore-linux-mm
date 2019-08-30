Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB9AEC3A59F
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 01:24:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7687920828
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 01:24:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=omnibond-com.20150623.gappssmtp.com header.i=@omnibond-com.20150623.gappssmtp.com header.b="rsF3TnYv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7687920828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=omnibond.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 071446B0008; Thu, 29 Aug 2019 21:24:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0229B6B000C; Thu, 29 Aug 2019 21:24:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2BD46B000D; Thu, 29 Aug 2019 21:24:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0096.hostedemail.com [216.40.44.96])
	by kanga.kvack.org (Postfix) with ESMTP id BFF356B0008
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 21:24:51 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 3E725180AD7C1
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 01:24:51 +0000 (UTC)
X-FDA: 75877349982.19.chess98_2a52491227432
X-HE-Tag: chess98_2a52491227432
X-Filterd-Recvd-Size: 7373
Received: from mail-yw1-f68.google.com (mail-yw1-f68.google.com [209.85.161.68])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 01:24:50 +0000 (UTC)
Received: by mail-yw1-f68.google.com with SMTP id m11so1848156ywh.3
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 18:24:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=omnibond-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=4TfZVE6zvYYuoOuB/Rxqa+Mlm3vtxZPY12krCFPSTtI=;
        b=rsF3TnYvnJjkhMrqd8jgi2b1fWfnS720m/snkWNYBAl3jogwp2mEsqA8h0meBBMFCG
         mupgLKrOXopsTT3mx+lDcAZLHUPbfCw/vXrZaEIvlfIiq4H0dj/IKCul0NWP4fpGLsu4
         48Lini1zfDu9D/EL0CeWiI8kZAXrgg08x+hcJWXhpsmSN701z4+zSsQ5V2A/N+PZ/ko+
         cAveXQxi5GTfOnxm/M0L2QMcpa0QpEp0UoezlsX6vklrx1noOLsykTvVpPGdg1yASetm
         NGCTD4uF7gFM2G4DP0Fj0jWpPyOxMpJF0KkXFU1tGtaTorkpzYDBwzJA49OyfPjy95xt
         U/rA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=4TfZVE6zvYYuoOuB/Rxqa+Mlm3vtxZPY12krCFPSTtI=;
        b=cn8/gnj7lZsN/BqnhBD9q8K3PwEzIsz3hCcTaUoFCwoaRKOs3Coa4+oJmpL/DwNj3w
         grV9YKK44jeApSQuaD/Zp0hbys0GFyyyvaJwyri5u6qwsnYVmtPoVAsy6MQzlHpmHc4L
         xVWbHqCW6RPoDoW5SaLTI9YfqQITRaORCWT2Ot5UmFptIhUyZkmVvIK5IyMvtl5PMkrl
         aBxhR/64sv9oDPtoxe6GQYSQAH6tIQNOdomLsWci9AJpTRkvMg4aulzbcImT4lq4x+6O
         v62zg+NhtAE1ijgV6RvZHElAEx+j8nIkR+ut65DKeKC3vyKjMXUSgAovaZzjpM/KLBc3
         Rbgw==
X-Gm-Message-State: APjAAAWlP0vQycaoVbm/6PZ77BbyDZErTQ9oi0oXdckpKNUerF+e978p
	Upozw2Z8iNnfonGJRKXLFMhRtYKNqvqrerF20a5rmw==
X-Google-Smtp-Source: APXvYqwS/gBw6GYqWJhwCNBmHR6+W2ONQRTVjMY8ZXLyRIgVZbf1blJaiiDec2a/U/ArNO35ME5xZuocZ9cXu0GpPKQ=
X-Received: by 2002:a0d:d596:: with SMTP id x144mr9018446ywd.69.1567128290041;
 Thu, 29 Aug 2019 18:24:50 -0700 (PDT)
MIME-Version: 1.0
References: <20190827150544.151031-1-salyzyn@android.com> <20190828142423.GA1955@infradead.org>
 <5dd09a38-fffb-36f2-505b-be2ddf6bb750@android.com>
In-Reply-To: <5dd09a38-fffb-36f2-505b-be2ddf6bb750@android.com>
From: Mike Marshall <hubcap@omnibond.com>
Date: Thu, 29 Aug 2019 21:24:38 -0400
Message-ID: <CAOg9mSTCC4Z3RpEyppC50B+pnSBbV0sr-F7hbsM-B+z3c-AZVA@mail.gmail.com>
Subject: Re: [PATCH v8] Add flags option to get xattr method paired to __vfs_getxattr
To: Mark Salyzyn <salyzyn@android.com>
Cc: Christoph Hellwig <hch@infradead.org>, LKML <linux-kernel@vger.kernel.org>, 
	kernel-team@android.com, Jan Kara <jack@suse.cz>, Stephen Smalley <sds@tycho.nsa.gov>, 
	linux-security-module@vger.kernel.org, stable@vger.kernel.org, 
	Jonathan Corbet <corbet@lwn.net>, Gao Xiang <gaoxiang25@huawei.com>, Chao Yu <yuchao0@huawei.com>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Eric Van Hensbergen <ericvh@gmail.com>, 
	Latchesar Ionkov <lucho@ionkov.net>, Dominique Martinet <asmadeus@codewreck.org>, 
	David Howells <dhowells@redhat.com>, Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>, 
	David Sterba <dsterba@suse.com>, Jeff Layton <jlayton@kernel.org>, Sage Weil <sage@redhat.com>, 
	Ilya Dryomov <idryomov@gmail.com>, Steve French <sfrench@samba.org>, 
	Tyler Hicks <tyhicks@canonical.com>, Jan Kara <jack@suse.com>, "Theodore Ts'o" <tytso@mit.edu>, 
	Andreas Dilger <adilger.kernel@dilger.ca>, Jaegeuk Kim <jaegeuk@kernel.org>, 
	Miklos Szeredi <miklos@szeredi.hu>, Bob Peterson <rpeterso@redhat.com>, 
	Andreas Gruenbacher <agruenba@redhat.com>, David Woodhouse <dwmw2@infradead.org>, 
	Richard Weinberger <richard@nod.at>, Dave Kleikamp <shaggy@kernel.org>, Tejun Heo <tj@kernel.org>, 
	Trond Myklebust <trond.myklebust@hammerspace.com>, 
	Anna Schumaker <anna.schumaker@netapp.com>, Mark Fasheh <mark@fasheh.com>, 
	Joel Becker <jlbec@evilplan.org>, Joseph Qi <joseph.qi@linux.alibaba.com>, 
	Martin Brandenburg <martin@omnibond.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Phillip Lougher <phillip@squashfs.org.uk>, Artem Bityutskiy <dedekind1@gmail.com>, 
	Adrian Hunter <adrian.hunter@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, 
	linux-xfs@vger.kernel.org, Hugh Dickins <hughd@google.com>, 
	"David S. Miller" <davem@davemloft.net>, Serge Hallyn <serge@hallyn.com>, James Morris <jmorris@namei.org>, 
	Mimi Zohar <zohar@linux.ibm.com>, Paul Moore <paul@paul-moore.com>, 
	Eric Paris <eparis@parisplace.org>, Casey Schaufler <casey@schaufler-ca.com>, 
	"J. Bruce Fields" <bfields@redhat.com>, Eric Biggers <ebiggers@google.com>, 
	Benjamin Coddington <bcodding@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Mathieu Malaterre <malat@debian.org>, Vyacheslav Dubeyko <slava@dubeyko.com>, 
	Bharath Vedartham <linux.bhar@gmail.com>, Jann Horn <jannh@google.com>, 
	Dave Chinner <dchinner@redhat.com>, Allison Henderson <allison.henderson@oracle.com>, 
	Brian Foster <bfoster@redhat.com>, Eric Sandeen <sandeen@sandeen.net>, linux-doc@vger.kernel.org, 
	linux-erofs@lists.ozlabs.org, devel@driverdev.osuosl.org, 
	V9FS Developers <v9fs-developer@lists.sourceforge.net>, linux-afs@lists.infradead.org, 
	linux-btrfs@vger.kernel.org, ceph-devel <ceph-devel@vger.kernel.org>, 
	linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, 
	ecryptfs@vger.kernel.org, Ext4 Developers List <linux-ext4@vger.kernel.org>, 
	"Linux F2FS DEV, Mailing List" <linux-f2fs-devel@lists.sourceforge.net>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, cluster-devel@redhat.com, 
	linux-mtd <linux-mtd@lists.infradead.org>, jfs-discussion@lists.sourceforge.net, 
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>, ocfs2-devel@oss.oracle.com, 
	devel@lists.orangefs.org, linux-unionfs@vger.kernel.org, 
	reiserfs-devel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, netdev@vger.kernel.org, 
	linux-integrity@vger.kernel.org, selinux@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I added this patch series on top of Linux 5.3-rc6 and ran xfstests
on orangefs with no regressions.

Acked-by: Mike Marshall <hubcap@omnibond.com>

-Mike

On Wed, Aug 28, 2019 at 10:40 AM Mark Salyzyn <salyzyn@android.com> wrote:
>
> On 8/28/19 7:24 AM, Christoph Hellwig wrote:
> > On Tue, Aug 27, 2019 at 08:05:15AM -0700, Mark Salyzyn wrote:
> >> Replace arguments for get and set xattr methods, and __vfs_getxattr
> >> and __vfs_setaxtr functions with a reference to the following now
> >> common argument structure:
> > Yikes.  That looks like a mess.  Why can't we pass a kernel-only
> > flag in the existing flags field for =E2=82=8B>set and add a flags fiel=
d
> > to ->get?  Passing methods by structure always tends to be a mess.
>
> This was a response to GregKH@ criticism, an earlier patch set just
> added a flag as you stated to get method, until complaints of an
> excessively long argument list and fragility to add or change more
> arguments.
>
> So many ways have been tried to skin this cat ... the risk was taken to
> please some, and we now have hundreds of stakeholders, when the first
> patch set was less than a dozen. A recipe for failure?
>
> -- Mark
>

