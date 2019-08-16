Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 174A3C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 15:30:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB297206C1
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 15:30:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=android.com header.i=@android.com header.b="n1rDvKmV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB297206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=android.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 688CF6B0007; Fri, 16 Aug 2019 11:30:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 612206B0008; Fri, 16 Aug 2019 11:30:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48B576B000A; Fri, 16 Aug 2019 11:30:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0211.hostedemail.com [216.40.44.211])
	by kanga.kvack.org (Postfix) with ESMTP id 2139A6B0007
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 11:30:36 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id C7C0212F57
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 15:30:35 +0000 (UTC)
X-FDA: 75828678030.09.key15_3f51bbea4d816
X-HE-Tag: key15_3f51bbea4d816
X-Filterd-Recvd-Size: 7139
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 15:30:34 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id b24so3318389pfp.1
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:30:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=android.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=mfAPdWffqPCiWWdG0+diH1s9rsdeIRT69OHzvRcyJZE=;
        b=n1rDvKmVIIzl5LQ8693geFLmZfVk3SNTRXjV+iWc+8TCGMLKeW1iTeiBjvRiueqoqF
         D9q8mlFSvHVsZFYo8y0kE96uO6kmQFQLzsCMbZOk0QJBcZZXpIGyVUfhKCZdaUtIfVCv
         i/NoHfVU/jNOhInU0nZF00JzrYo84Kc4poGmJ+0xtP3BbotZEuJh4vLNcJnKiqpzbKqX
         VAVojoCQ9+7vUVRbeqlgJ3x1mKtd9gYqddIhEV1djd0QWV+eU6MOHKC8ZzBAyRJxBa4j
         h2AWL75nzhxsVUvXnKj119sMtgytuLB07uRnQLjRyRsPInJpSQZBT6UeAUBurB9zqibi
         wIrg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=mfAPdWffqPCiWWdG0+diH1s9rsdeIRT69OHzvRcyJZE=;
        b=kMiz3IKArAMx2SEeqVpvicOOwapgVfyXdO7D4MPw8Oxpsr3dYkeZxtNLOVzv4/6WeB
         eThx2gjSmi647z1quOMxJKOvlWUoNZFYEnR9+JW7YyK0iEfD3YojYvbyJPdoZ/EZNMpw
         KmF4TMlp0we96oE34hod/jLGfk3oIR+aqLzOaJbM7+4m/4f1T8hmhOestp4RiB7c65a6
         8WVJt4147OdkNvU4O8c2hcV0UjwqWordXEKGb79mOzV0sepRiyCeZeCjSLt/ICemSzui
         Dh711ZGsrqm5EBjoRN2lQSayJdeOdvo6nKCNdVfJKwpfUNg6MLP5rKdzMKt+zbQtnIwk
         vuSw==
X-Gm-Message-State: APjAAAX+8elGGfAVeDHI9j4TrOMs+QLZnmmOFVsRwe99DfFidcY8BXWR
	NvHQxpFuln5GULiBnWxXJtuCJw==
X-Google-Smtp-Source: APXvYqydx2RtAVHirZjlmSa0Unc3LrMXkJsKHb448nh37ky9aF7sEwD8P8sx+d4AByX8L7k2WfP+gw==
X-Received: by 2002:a17:90a:77c9:: with SMTP id e9mr7407215pjs.141.1565969433680;
        Fri, 16 Aug 2019 08:30:33 -0700 (PDT)
Received: from nebulus.mtv.corp.google.com ([2620:15c:211:200:5404:91ba:59dc:9400])
        by smtp.googlemail.com with ESMTPSA id l4sm4355544pjq.9.2019.08.16.08.30.31
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 16 Aug 2019 08:30:32 -0700 (PDT)
Subject: Re: [PATCH] Add flags option to get xattr method paired to
 __vfs_getxattr
To: James Morris <jmorris@namei.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 linux-kernel@vger.kernel.org, kernel-team@android.com,
 Stephen Smalley <sds@tycho.nsa.gov>, linux-security-module@vger.kernel.org,
 stable@vger.kernel.org, Eric Van Hensbergen <ericvh@gmail.com>,
 Latchesar Ionkov <lucho@ionkov.net>,
 Dominique Martinet <asmadeus@codewreck.org>,
 David Howells <dhowells@redhat.com>, Chris Mason <clm@fb.com>,
 Josef Bacik <josef@toxicpanda.com>, David Sterba <dsterba@suse.com>,
 Jeff Layton <jlayton@kernel.org>, Sage Weil <sage@redhat.com>,
 Ilya Dryomov <idryomov@gmail.com>, Steve French <sfrench@samba.org>,
 Tyler Hicks <tyhicks@canonical.com>, Jan Kara <jack@suse.com>,
 Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>,
 Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>,
 Miklos Szeredi <miklos@szeredi.hu>, Bob Peterson <rpeterso@redhat.com>,
 Andreas Gruenbacher <agruenba@redhat.com>,
 David Woodhouse <dwmw2@infradead.org>, Richard Weinberger <richard@nod.at>,
 Dave Kleikamp <shaggy@kernel.org>, Tejun Heo <tj@kernel.org>,
 Trond Myklebust <trond.myklebust@hammerspace.com>,
 Anna Schumaker <anna.schumaker@netapp.com>, Mark Fasheh <mark@fasheh.com>,
 Joel Becker <jlbec@evilplan.org>, Joseph Qi <joseph.qi@linux.alibaba.com>,
 Mike Marshall <hubcap@omnibond.com>, Martin Brandenburg
 <martin@omnibond.com>, Alexander Viro <viro@zeniv.linux.org.uk>,
 Phillip Lougher <phillip@squashfs.org.uk>,
 "Darrick J. Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org,
 Hugh Dickins <hughd@google.com>, "David S. Miller" <davem@davemloft.net>,
 Serge Hallyn <serge@hallyn.com>, Mimi Zohar <zohar@linux.ibm.com>,
 Paul Moore <paul@paul-moore.com>, Eric Paris <eparis@parisplace.org>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Vyacheslav Dubeyko <slava@dubeyko.com>,
 =?UTF-8?Q?Ernesto_A=2e_Fern=c3=a1ndez?= <ernesto.mnd.fernandez@gmail.com>,
 Mathieu Malaterre <malat@debian.org>, v9fs-developer@lists.sourceforge.net,
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
References: <20190812193320.200472-1-salyzyn@android.com>
 <20190813084801.GA972@kroah.com>
 <alpine.LRH.2.21.1908160515130.12729@namei.org>
 <69889dec-5440-1472-ed57-380f45547581@android.com>
 <alpine.LRH.2.21.1908160825310.22623@namei.org>
From: Mark Salyzyn <salyzyn@android.com>
Message-ID: <92b1df4b-6433-7d01-9c08-23de10e8d527@android.com>
Date: Fri, 16 Aug 2019 08:30:30 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.21.1908160825310.22623@namei.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/15/19 3:27 PM, James Morris wrote:
> On Thu, 15 Aug 2019, Mark Salyzyn wrote:
>
>> Good Idea, but using the same argument structure for set and get I would be
>> concerned about the loss of compiler protection for the buffer argument;
> Agreed, I missed that.

Sadly, the pattern of

struct getxattr_args args;

memset(&args, 0, sizeof(args));

args.xxxx = ...

__vfs_getxattr(&args};

...

__vfs_setxattr(&args);

would be nice, so maybe we need to cool our jets and instead:

struct xattr_gs_args {
	struct dentry *dentry;
	struct inode *inode;
	const char *name;
	union {
	        void *buffer;
	        const void *value;
	};
	size_t size;
	int flags;
};

value _must_ be referenced for all setxattr operations, buffer for getxattr operations (how can we enforce that?).

>> struct getxattr_args {
>> 	struct dentry *dentry;
>> 	struct inode *inode;
>> 	const char *name;
>> 	void *buffer;
>> 	size_t size;
>> 	int flags;
> Does 'get' need flags?
>
:-) That was the _whole_ point of the patch, flags is how we pass in the 
recursion so that a security/internal getxattr call has the rights to 
acquire the data in the lower layer(s).

-- Mark


