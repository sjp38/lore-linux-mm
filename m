Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C1FCC3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 14:58:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 01435214DA
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 14:57:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=android.com header.i=@android.com header.b="mzwUwotH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01435214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=android.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 931D86B0006; Tue, 27 Aug 2019 10:57:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E24F6B0008; Tue, 27 Aug 2019 10:57:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7342B6B000A; Tue, 27 Aug 2019 10:57:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0210.hostedemail.com [216.40.44.210])
	by kanga.kvack.org (Postfix) with ESMTP id 49D5C6B0006
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 10:57:57 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 122CF181AC9CC
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 14:57:07 +0000 (UTC)
X-FDA: 75868510494.18.sun72_7842ec9e43c28
X-HE-Tag: sun72_7842ec9e43c28
X-Filterd-Recvd-Size: 8782
Received: from smtprelay.test.hostedemail.com (mail.test.hostedemail.com [216.40.41.5])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 14:57:06 +0000 (UTC)
Received: from forelay.test.hostedemail.com (10.5.29.251.rfc1918.com [10.5.29.251])
	by smtprelay01.test.hostedemail.com (Postfix) with ESMTP id 0E18111D60
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 14:57:06 +0000 (UTC)
Received: from forelay.prod.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by fograve01.test.hostedemail.com (Postfix) with ESMTP id D8F0923851
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 14:57:05 +0000 (UTC)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 692CD824376E
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 14:54:50 +0000 (UTC)
X-FDA: 75868504740.07.bone44_645ecedb35d39
X-HE-Tag: bone44_645ecedb35d39
X-Filterd-Recvd-Size: 7829
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 14:54:49 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id g2so14291224pfq.0
        for <linux-mm@kvack.org>; Tue, 27 Aug 2019 07:54:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=android.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=J0PyrXbgy2rQbHf32v3WQfO8h7H5WwZ0x8ImHOimCWs=;
        b=mzwUwotHCHLyC8kvJQKX2qfkclXUibOZVKlCSAmub430gCcW4lmMANVBjk4ZJn37Mz
         lmwqaekfvRnk91fWBTPe9MdR6DNIOZYbn1kKQlCtB2EIRUw9eVK89gLHZxbOnS+BoN9O
         z/e+lec1c3V+A/cevmzn6YhUNeV1qLcxR5P5ZMIEm0QeC99vQIqrptkzAecOAow3P+WG
         qTbXtfhvLGsZsqUEkNrN67J91EYh7XB3OB1b7OQP26/5Ffe7WcOAgQyPgjx4Kr7W8Oc+
         UwQjFeNzqy6bSLsp44PwvDCnhYQ/gCS2wppnuYUD4QcGMN8OxcAFpKCWSwZ+EWDarzDN
         vqDw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=J0PyrXbgy2rQbHf32v3WQfO8h7H5WwZ0x8ImHOimCWs=;
        b=MQ0CmMhzCN8a17LlN7mgYkvc+ANk4gszdNYc40a0g22xeUwnd6FUbTxNtrP0LGQrjt
         CY6AZbe3V74Jah4Dr8rt0niM5pUzAjXMtJZJr6zoKNj102EzF97v3Ev/xxI4liWFo0IT
         BVJwhgytflohxJ7u1layZ2rKYQWphb0pXjTd8WJuX1QBSsBdlOKwZeAFx727f1D2FTY7
         SRsni4SID2z4tEwb0VhZQbKC3lYsvcAPw25ZoI9TwzIjIM8maYrdHY2nyjKoYsKNVvMo
         gwPpSO+q6ca94SevmrUGow6BzeLxl0IHBlqKjSisLHBxzsJ6MS5bLiefKeJ9wdFrmv1J
         r4HQ==
X-Gm-Message-State: APjAAAXd6WO1RckA7enW7romJgVp9fMZdOVZTj9gKTXiFW7ABJWB667l
	DGJwbl1jXDxb/r25tmNM80gimw==
X-Google-Smtp-Source: APXvYqwBoH7/mHEw1qHJ4C0pvUdOnWf9w3cFM7T1JRRoXNt8gEzBDpTDPLau8WREch+lyRDJT+u4BA==
X-Received: by 2002:a65:6891:: with SMTP id e17mr20940506pgt.305.1566917687986;
        Tue, 27 Aug 2019 07:54:47 -0700 (PDT)
Received: from nebulus.mtv.corp.google.com ([2620:15c:211:200:5404:91ba:59dc:9400])
        by smtp.googlemail.com with ESMTPSA id s125sm30946505pfc.133.2019.08.27.07.54.45
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 27 Aug 2019 07:54:47 -0700 (PDT)
Subject: Re: [PATCH v7] Add flags option to get xattr method paired to
 __vfs_getxattr
To: Jan Kara <jack@suse.cz>
Cc: linux-kernel@vger.kernel.org, kernel-team@android.com,
 Tyler Hicks <tyhicks@canonical.com>,
 Dominique Martinet <asmadeus@codewreck.org>,
 "David S. Miller" <davem@davemloft.net>, Mathieu Malaterre
 <malat@debian.org>, Andreas Dilger <adilger.kernel@dilger.ca>,
 devel@driverdev.osuosl.org, Vyacheslav Dubeyko <slava@dubeyko.com>,
 Joel Becker <jlbec@evilplan.org>, Mark Fasheh <mark@fasheh.com>,
 Chris Mason <clm@fb.com>, Artem Bityutskiy <dedekind1@gmail.com>,
 Eric Van Hensbergen <ericvh@gmail.com>,
 =?UTF-8?Q?Ernesto_A=2e_Fern=c3=a1ndez?= <ernesto.mnd.fernandez@gmail.com>,
 Ilya Dryomov <idryomov@gmail.com>, Bharath Vedartham <linux.bhar@gmail.com>,
 Eric Biggers <ebiggers@google.com>, Hugh Dickins <hughd@google.com>,
 Jann Horn <jannh@google.com>, Serge Hallyn <serge@hallyn.com>,
 Trond Myklebust <trond.myklebust@hammerspace.com>,
 Gao Xiang <gaoxiang25@huawei.com>, Chao Yu <yuchao0@huawei.com>,
 David Woodhouse <dwmw2@infradead.org>,
 Adrian Hunter <adrian.hunter@intel.com>, Latchesar Ionkov
 <lucho@ionkov.net>, Jaegeuk Kim <jaegeuk@kernel.org>,
 Jeff Layton <jlayton@kernel.org>, Dave Kleikamp <shaggy@kernel.org>,
 Tejun Heo <tj@kernel.org>, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>,
 Joseph Qi <joseph.qi@linux.alibaba.com>, Mimi Zohar <zohar@linux.ibm.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 linux-afs@lists.infradead.org, linux-mtd@lists.infradead.org,
 devel@lists.orangefs.org, linux-erofs@lists.ozlabs.org,
 samba-technical@lists.samba.org, jfs-discussion@lists.sourceforge.net,
 linux-f2fs-devel@lists.sourceforge.net,
 v9fs-developer@lists.sourceforge.net, Jonathan Corbet <corbet@lwn.net>,
 Theodore Ts'o <tytso@mit.edu>, James Morris <jmorris@namei.org>,
 Anna Schumaker <anna.schumaker@netapp.com>,
 Richard Weinberger <richard@nod.at>, Mike Marshall <hubcap@omnibond.com>,
 Martin Brandenburg <martin@omnibond.com>,
 Allison Henderson <allison.henderson@oracle.com>,
 "Darrick J. Wong" <darrick.wong@oracle.com>, ocfs2-devel@oss.oracle.com,
 Eric Paris <eparis@parisplace.org>, Paul Moore <paul@paul-moore.com>,
 Andreas Gruenbacher <agruenba@redhat.com>,
 Benjamin Coddington <bcodding@redhat.com>,
 "J. Bruce Fields" <bfields@redhat.com>, Brian Foster <bfoster@redhat.com>,
 cluster-devel@redhat.com, Dave Chinner <dchinner@redhat.com>,
 David Howells <dhowells@redhat.com>, Bob Peterson <rpeterso@redhat.com>,
 Sage Weil <sage@redhat.com>, Steve French <sfrench@samba.org>,
 Eric Sandeen <sandeen@sandeen.net>, Casey Schaufler
 <casey@schaufler-ca.com>, Phillip Lougher <phillip@squashfs.org.uk>,
 David Sterba <dsterba@suse.com>, Jan Kara <jack@suse.com>,
 Jeff Mahoney <jeffm@suse.com>, Miklos Szeredi <miklos@szeredi.hu>,
 Josef Bacik <josef@toxicpanda.com>, Stephen Smalley <sds@tycho.nsa.gov>,
 ceph-devel@vger.kernel.org, ecryptfs@vger.kernel.org,
 linux-btrfs@vger.kernel.org, linux-cifs@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-integrity@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org,
 linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org,
 netdev@vger.kernel.org, reiserfs-devel@vger.kernel.org,
 selinux@vger.kernel.org, stable@vger.kernel.org,
 Alexander Viro <viro@zeniv.linux.org.uk>
References: <20190820180716.129882-1-salyzyn@android.com>
 <20190827141952.GB10098@quack2.suse.cz>
From: Mark Salyzyn <salyzyn@android.com>
Message-ID: <8468b22d-05b7-47d3-eb93-2c71dafea3ee@android.com>
Date: Tue, 27 Aug 2019 07:54:44 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190827141952.GB10098@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/27/19 7:19 AM, Jan Kara wrote:
> On Tue 20-08-19 11:06:48, Mark Salyzyn wrote:
>> diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
>> index 204dd3ea36bb..e2687f21c7d6 100644
>> --- a/Documentation/filesystems/Locking
>> +++ b/Documentation/filesystems/Locking
>> @@ -101,12 +101,10 @@ of the locking scheme for directory operations.
>>   ----------------------- xattr_handler operations -----------------------
>>   prototypes:
>>   	bool (*list)(struct dentry *dentry);
>> -	int (*get)(const struct xattr_handler *handler, struct dentry *dentry,
>> -		   struct inode *inode, const char *name, void *buffer,
>> -		   size_t size);
>> -	int (*set)(const struct xattr_handler *handler, struct dentry *dentry,
>> -		   struct inode *inode, const char *name, const void *buffer,
>> -		   size_t size, int flags);
>> +	int (*get)(const struct xattr_handler *handler,
>> +		   struct xattr_gs_flags);
>> +	int (*set)(const struct xattr_handler *handler,
>> +		   struct xattr_gs_flags);
> The prototype here is really "struct xattr_gs_flags *args", isn't it?
> Otherwise feel free to add:
>
> Reviewed-by: Jan Kara <jack@suse.cz>
>
> for the ext2, ext4, ocfs2, reiserfs, and the generic fs/* bits.
>
> 								Honza

<oops> Thanks and good catch, will respin with a fix to the 
documentation shortly.

-- Mark



