Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1576FC3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:40:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCDB922CED
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:40:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=android.com header.i=@android.com header.b="OlcPfkFh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCDB922CED
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=android.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68DDD6B0005; Wed, 28 Aug 2019 10:40:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63E9B6B0006; Wed, 28 Aug 2019 10:40:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C1766B000E; Wed, 28 Aug 2019 10:40:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0157.hostedemail.com [216.40.44.157])
	by kanga.kvack.org (Postfix) with ESMTP id 288696B0005
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 10:40:21 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id B64A9181AC9B4
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:40:20 +0000 (UTC)
X-FDA: 75872097000.20.cats22_20059d7c9513c
X-HE-Tag: cats22_20059d7c9513c
X-Filterd-Recvd-Size: 7303
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:40:19 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id q139so1842735pfc.13
        for <linux-mm@kvack.org>; Wed, 28 Aug 2019 07:40:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=android.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=otBOnvzgcCfij7khznQb839FNBhUwDL3v2TXcjGpOzs=;
        b=OlcPfkFh4eVXaPXXhh3cHvgBURsJe3iAt4+TEVeWmIUa8zc09e0oQ5MaZNlepG2vze
         B3r7RgJuWq9O6TIbswaNUIKe8aYWW+KNRgEXeCMfCvmELHUyftJPl7HAVt/DUWoqH+mt
         7FiMUsP13ILyRxskXvgoEKTt4mcyDqpG+bZTW39pIt/5h+k8/JBgcB7qNM0XACYD7ale
         oWFmT2jC5R2Rv9fP9CO4NSXlbVjGTO4SWvbIfLdPsT4850CBsX7b6iyMaVYsWWgBm0EJ
         ydfkWGX0BboAbCSeR2RRikvC2V1c34KnlnNThn4oWcDh6RwGfO3sPku0/xiss22u0zC8
         qA2Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=otBOnvzgcCfij7khznQb839FNBhUwDL3v2TXcjGpOzs=;
        b=bCQnIdprrkMc1uhpC9zUgtYElHJ6tj+HSV1Zt7VZYYrhAIPPC0pzBjxBFudgGs7M/+
         LvS47GuUqGRVe0fLs00MO0r8JFx15mSCvuUxWSnSpNpBKz5qxKScdgN5SbzkFnykW0x3
         NDgILp3jZRKxW0Wj2cnnvnKO0iRT8f8UKMML/7tL4jsS5zWZNe3Qf32mkGtgWG/B2pIc
         wU3eT51zdsYktnlX2dAbLJx/Y6o/wWpBD3kjZpFcHoBGkf2fqJSPHmAU5gyp4Sbf1ha8
         uhQ/r1164jFN7rmBVv5utQxOK8hicbSA6SFlQzdmJ0Zr6EC6YjvLbwMhOA3xejt2GC2q
         J5GQ==
X-Gm-Message-State: APjAAAVpb6FdPs7H6WU3QbBJDHwqHwXAD+Q8cjZhfSlm+YJOQq0LzOTa
	8PEsZ39L7HjH8bcwEOQCXmRsgA==
X-Google-Smtp-Source: APXvYqxMi0WkPdC/TIWQ/rEP0W+6WEwgY/rp8ZhYjwRr9PMekyUrfkMqryPcx5ziGSRNx/jQnRs5oA==
X-Received: by 2002:a17:90b:8ca:: with SMTP id ds10mr4474530pjb.139.1567003218534;
        Wed, 28 Aug 2019 07:40:18 -0700 (PDT)
Received: from nebulus.mtv.corp.google.com ([2620:15c:211:200:5404:91ba:59dc:9400])
        by smtp.googlemail.com with ESMTPSA id t9sm7295641pgj.89.2019.08.28.07.40.15
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 28 Aug 2019 07:40:17 -0700 (PDT)
Subject: Re: [PATCH v8] Add flags option to get xattr method paired to
 __vfs_getxattr
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, kernel-team@android.com,
 Jan Kara <jack@suse.cz>, Stephen Smalley <sds@tycho.nsa.gov>,
 linux-security-module@vger.kernel.org, stable@vger.kernel.org,
 Jonathan Corbet <corbet@lwn.net>, Gao Xiang <gaoxiang25@huawei.com>,
 Chao Yu <yuchao0@huawei.com>, Greg Kroah-Hartman
 <gregkh@linuxfoundation.org>, Eric Van Hensbergen <ericvh@gmail.com>,
 Latchesar Ionkov <lucho@ionkov.net>,
 Dominique Martinet <asmadeus@codewreck.org>,
 David Howells <dhowells@redhat.com>, Chris Mason <clm@fb.com>,
 Josef Bacik <josef@toxicpanda.com>, David Sterba <dsterba@suse.com>,
 Jeff Layton <jlayton@kernel.org>, Sage Weil <sage@redhat.com>,
 Ilya Dryomov <idryomov@gmail.com>, Steve French <sfrench@samba.org>,
 Tyler Hicks <tyhicks@canonical.com>, Jan Kara <jack@suse.com>,
 Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>,
 Jaegeuk Kim <jaegeuk@kernel.org>, Miklos Szeredi <miklos@szeredi.hu>,
 Bob Peterson <rpeterso@redhat.com>, Andreas Gruenbacher
 <agruenba@redhat.com>, David Woodhouse <dwmw2@infradead.org>,
 Richard Weinberger <richard@nod.at>, Dave Kleikamp <shaggy@kernel.org>,
 Tejun Heo <tj@kernel.org>, Trond Myklebust
 <trond.myklebust@hammerspace.com>, Anna Schumaker
 <anna.schumaker@netapp.com>, Mark Fasheh <mark@fasheh.com>,
 Joel Becker <jlbec@evilplan.org>, Joseph Qi <joseph.qi@linux.alibaba.com>,
 Mike Marshall <hubcap@omnibond.com>, Martin Brandenburg
 <martin@omnibond.com>, Alexander Viro <viro@zeniv.linux.org.uk>,
 Phillip Lougher <phillip@squashfs.org.uk>,
 Artem Bityutskiy <dedekind1@gmail.com>,
 Adrian Hunter <adrian.hunter@intel.com>,
 "Darrick J. Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org,
 Hugh Dickins <hughd@google.com>, "David S. Miller" <davem@davemloft.net>,
 Serge Hallyn <serge@hallyn.com>, James Morris <jmorris@namei.org>,
 Mimi Zohar <zohar@linux.ibm.com>, Paul Moore <paul@paul-moore.com>,
 Eric Paris <eparis@parisplace.org>, Casey Schaufler
 <casey@schaufler-ca.com>, "J. Bruce Fields" <bfields@redhat.com>,
 Eric Biggers <ebiggers@google.com>, Benjamin Coddington
 <bcodding@redhat.com>, Andrew Morton <akpm@linux-foundation.org>,
 Mathieu Malaterre <malat@debian.org>, Vyacheslav Dubeyko
 <slava@dubeyko.com>, Bharath Vedartham <linux.bhar@gmail.com>,
 Jann Horn <jannh@google.com>, Dave Chinner <dchinner@redhat.com>,
 Allison Henderson <allison.henderson@oracle.com>,
 Brian Foster <bfoster@redhat.com>, Eric Sandeen <sandeen@sandeen.net>,
 linux-doc@vger.kernel.org, linux-erofs@lists.ozlabs.org,
 devel@driverdev.osuosl.org, v9fs-developer@lists.sourceforge.net,
 linux-afs@lists.infradead.org, linux-btrfs@vger.kernel.org,
 ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
 samba-technical@lists.samba.org, ecryptfs@vger.kernel.org,
 linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
 linux-fsdevel@vger.kernel.org, cluster-devel@redhat.com,
 linux-mtd@lists.infradead.org, jfs-discussion@lists.sourceforge.net,
 linux-nfs@vger.kernel.org, ocfs2-devel@oss.oracle.com,
 devel@lists.orangefs.org, linux-unionfs@vger.kernel.org,
 reiserfs-devel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org,
 linux-integrity@vger.kernel.org, selinux@vger.kernel.org
References: <20190827150544.151031-1-salyzyn@android.com>
 <20190828142423.GA1955@infradead.org>
From: Mark Salyzyn <salyzyn@android.com>
Message-ID: <5dd09a38-fffb-36f2-505b-be2ddf6bb750@android.com>
Date: Wed, 28 Aug 2019 07:40:15 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190828142423.GA1955@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/28/19 7:24 AM, Christoph Hellwig wrote:
> On Tue, Aug 27, 2019 at 08:05:15AM -0700, Mark Salyzyn wrote:
>> Replace arguments for get and set xattr methods, and __vfs_getxattr
>> and __vfs_setaxtr functions with a reference to the following now
>> common argument structure:
> Yikes.  That looks like a mess.  Why can't we pass a kernel-only
> flag in the existing flags field for =E2=82=8B>set and add a flags fiel=
d
> to ->get?  Passing methods by structure always tends to be a mess.

This was a response to GregKH@ criticism, an earlier patch set just=20
added a flag as you stated to get method, until complaints of an=20
excessively long argument list and fragility to add or change more=20
arguments.

So many ways have been tried to skin this cat ... the risk was taken to=20
please some, and we now have hundreds of stakeholders, when the first=20
patch set was less than a dozen. A recipe for failure?

-- Mark


