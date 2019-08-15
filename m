Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6857EC3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 21:26:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1916F205F4
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 21:26:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=android.com header.i=@android.com header.b="lIpZ0g9D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1916F205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=android.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C24E86B0005; Thu, 15 Aug 2019 17:26:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD6946B0006; Thu, 15 Aug 2019 17:26:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9D3E6B0007; Thu, 15 Aug 2019 17:26:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0003.hostedemail.com [216.40.44.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8AD2F6B0005
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:26:51 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 4490681D1
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 21:26:51 +0000 (UTC)
X-FDA: 75825947022.02.tent66_3bb8392215330
X-HE-Tag: tent66_3bb8392215330
X-Filterd-Recvd-Size: 8873
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 21:26:50 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id f17so1962513pfn.6
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 14:26:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=android.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=NQPI89pyKynFZwWztDWLjrPNlq9e9KFjYiijpvVD82o=;
        b=lIpZ0g9DtDyqIqk3Pk+f3LAbBb1IHJR/OqcvIqSvHq+yBEN7osFWEACcZH+FVTGAN+
         z81fgESdI7fNhc3JgTo9dRJMBztkRx79bvkDfp3/xi9bZurWt2357qZZo4tFW7M0y0Ej
         A6uvlorCTKMuc3kR41qxmYDng3wbRM+BG0tiDg042ULiVNZsJKa0xmpkuCsfDllwdR+e
         dG4DrPqiLG1FI9UfDGP54YpE2IKITme3NrNG9h5Xx1BAmyChoM9PJ99fCCQ/KwOPT9he
         yumEroYrkBe4fkJ0BYuWZmThYwe0QxWcBl+TbCtzexrk33BB01Ff8hxY8VdTWES/ELDc
         HaRQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=NQPI89pyKynFZwWztDWLjrPNlq9e9KFjYiijpvVD82o=;
        b=VwtUKex1t87lidpU+gedvdFaDvS7TtUZE1CP0EOeAn5/GDgMbBrjiEIogU+LIPs1CS
         mFPWIfnddIVMJJTHccYxh9G9kB1wbkSlSwT3l6jVZeYEMV4Gx/3ym00tdm9nCuNnY9Op
         zLSiUUW+p5YEIDagT2U+IKb92NUHs9w7XrbvfwTjc/HYb6CsTLbkcyi3KuoRiGpFpdvJ
         R8nNOt4CunCGHuMnVi6aVQsgrzYIdu9090vQbJkszaCQs4Fd5F8rviNsL2t6ozE7S97X
         MfMPM3a+CsA2UdtrPoRIL+bhVOh7zTbttuQOTBA6FuOVhP45grgq9A/o7RuiCh9p71KU
         rWsA==
X-Gm-Message-State: APjAAAVb1f2HNxhmGyzK5vtlxEs0bscVpM8SWLfvF+L9Z+rpwuzcBE56
	e3tSE/JFDJEl1ulXb1r46fCNgA==
X-Google-Smtp-Source: APXvYqzllKC5ksLQDzyaqGJCDuceyLpQSHPwoKzZQcbJiABKWTaC5jPOSVkAOdc7QTtTY77anKcswg==
X-Received: by 2002:a62:e910:: with SMTP id j16mr7618601pfh.123.1565904408941;
        Thu, 15 Aug 2019 14:26:48 -0700 (PDT)
Received: from nebulus.mtv.corp.google.com ([2620:15c:211:200:5404:91ba:59dc:9400])
        by smtp.googlemail.com with ESMTPSA id v7sm3875690pff.87.2019.08.15.14.26.46
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 15 Aug 2019 14:26:48 -0700 (PDT)
Subject: Re: [PATCH] Add flags option to get xattr method paired to
 __vfs_getxattr
To: James Morris <jmorris@namei.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, kernel-team@android.com,
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
From: Mark Salyzyn <salyzyn@android.com>
Message-ID: <69889dec-5440-1472-ed57-380f45547581@android.com>
Date: Thu, 15 Aug 2019 14:26:46 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.21.1908160515130.12729@namei.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/15/19 12:20 PM, James Morris wrote:
> On Tue, 13 Aug 2019, Greg Kroah-Hartman wrote:
>
>> On Mon, Aug 12, 2019 at 12:32:49PM -0700, Mark Salyzyn wrote:
>>> --- a/include/linux/xattr.h
>>> +++ b/include/linux/xattr.h
>>> @@ -30,10 +30,10 @@ struct xattr_handler {
>>>   	const char *prefix;
>>>   	int flags;      /* fs private flags */
>>>   	bool (*list)(struct dentry *dentry);
>>> -	int (*get)(const struct xattr_handler *, struct dentry *dentry,
>>> +	int (*get)(const struct xattr_handler *handler, struct dentry *dentry,
>>>   		   struct inode *inode, const char *name, void *buffer,
>>> -		   size_t size);
>>> -	int (*set)(const struct xattr_handler *, struct dentry *dentry,
>>> +		   size_t size, int flags);
>>> +	int (*set)(const struct xattr_handler *handler, struct dentry *dentry,
>>>   		   struct inode *inode, const char *name, const void *buffer,
>>>   		   size_t size, int flags);
>> Wow, 7 arguments.  Isn't there some nice rule of thumb that says once
>> you get more then 5, a function becomes impossible to understand?
>>
>> Surely this could be a structure passed in here somehow, that way when
>> you add the 8th argument in the future, you don't have to change
>> everything yet again?  :)
>>
>> I don't have anything concrete to offer as a replacement fix for this,
>> but to me this just feels really wrong...
> How about something like:
>
> struct xattr_gs_args {
> 	struct dentry *dentry;
> 	struct inode *inode;
> 	const char *name;
> 	const void *buffer;
> 	size_t size;
> 	int flags;
> };
>
> int (*get)(const struct xattr_handler *handler, struct xattr_gs_args *args);
> int (*set)(const struct xattr_handler *handler, struct xattr_gs_args *args);
>
Good Idea, but using the same argument structure for set and get I would 
be concerned about the loss of compiler protection for the buffer 
argument; it is void* for get, and const void* for set. And if we pulled 
out buffer (and size since it is paired with it) from the structure to 
solve, the 'mixed' argument approach (resulting in 4 args) adds to the 
difficulty/complexity.

Good news is the same structure(s) can get passed to __vfs_getxattr and 
__vfs_setxattr, so one less issue with getting the argument order 
correct from the caller.

 From an optimization standpoint, passing an argument to a pointer to a 
structure assembled on the stack constrains the compiler. Whereas 
individual arguments allow for the optimization to place all the 
arguments into registers. All modern processors have no issue with tens 
of arguments.

So, I will look into what the patch set will look like by splitting into 
set and get, and trying to reuse the structure down the call chain.

struct getxattr_args {
	struct dentry *dentry;
	struct inode *inode;
	const char *name;
	void *buffer;
	size_t size;
	int flags;
};

struct setxattr_args {
	struct dentry *dentry;
	struct inode *inode;
	const char *name;
	const void *buffer;
	size_t size;
	int flags;
};

-- Mark




