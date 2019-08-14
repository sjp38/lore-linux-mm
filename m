Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C60C9C32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 14:54:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E774206C1
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 14:54:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=android.com header.i=@android.com header.b="ahMJ7+6M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E774206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=android.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06ADB6B0005; Wed, 14 Aug 2019 10:54:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01A686B0007; Wed, 14 Aug 2019 10:54:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E75E26B000A; Wed, 14 Aug 2019 10:54:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0119.hostedemail.com [216.40.44.119])
	by kanga.kvack.org (Postfix) with ESMTP id C73916B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 10:54:21 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 76EDE181AC9B4
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 14:54:21 +0000 (UTC)
X-FDA: 75821329122.19.help44_431049c1f1a4a
X-HE-Tag: help44_431049c1f1a4a
X-Filterd-Recvd-Size: 10097
Received: from mail-pl1-f194.google.com (mail-pl1-f194.google.com [209.85.214.194])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 14:54:20 +0000 (UTC)
Received: by mail-pl1-f194.google.com with SMTP id y8so8699980plr.12
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:54:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=android.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=CnI+bcK+PrkZXa0lXxFneGD0jULXut8K+Ere8plo5Kc=;
        b=ahMJ7+6MRm+vSMGaNapJnzEVkJAGqdseEv5NiAiJ2xVM1sgCa/KjV3CzptwbORiRO4
         tdVwxwGBtUsGnUn2c7e13VySsAmWdVDIrtQOwhPmb7DJeeLmPii1ZL4rskNBRvtj47Hs
         RPxCzpXwnaU3g/CUfEBg3QlPGY1SngnQDCYWpuzQB5cndu90bUkPUFPxqy0/Rekd1WQO
         4zngI17UYs23Aiqj3B79lt987Hor3fkgPNT95mLnJes5xZMFhtrjHD+wvpp9CvYS0OOT
         T0Jx+829oyOwsEqr2Xgl3CEpOuwA5/x9WXxEUC4UDChgzDD/d77A140pfqc0MLV3w5Tr
         /pug==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=CnI+bcK+PrkZXa0lXxFneGD0jULXut8K+Ere8plo5Kc=;
        b=OxOIFkj/iQFzlKjJauFnw8pD2BsN83YViVZZRmxaCGwAE342pLDPj2z2bjy3sUfJ3t
         0j8QXq9gxbQXzeRYey6ZMCRB/zVO6clHUuhthJ5ULjJIEmWSwULBHrt1Ak6ai2yE/X/H
         R4752Db8OlLR8uTLwlG0U7IaVCazevl+AUyFOCc3tOi2tmEowSc6ZGY/4Dr8bWOOntY0
         tDaLaHPFhjPWG8B3yV9pbuXVs1JVNgFjzYXCyYVP+5M0UkfDd2OLAZkkbtBBoHt/5dxf
         r4Skn3JnIZ9MEugr+gVeeASd4ddLhKSkoazolLwdYtYaneM1KSjSkS33Wr4DevGgfek3
         9Z3A==
X-Gm-Message-State: APjAAAXN35wTF/f7ZiyzESjXlFe163tM68ZMru43KIKTFPSL87Su6pd+
	Uj5Q8dq2+FWTRT7OgEkgFz9gyQ==
X-Google-Smtp-Source: APXvYqz3CwepJ0lR8OwKX1IycWhHHs06AM+yzu0iFct+XZq8bOtgfYosWIvv1z0G9d0AAh0UWfDALQ==
X-Received: by 2002:a17:902:3103:: with SMTP id w3mr43683432plb.84.1565794459417;
        Wed, 14 Aug 2019 07:54:19 -0700 (PDT)
Received: from nebulus.mtv.corp.google.com ([2620:15c:211:200:5404:91ba:59dc:9400])
        by smtp.googlemail.com with ESMTPSA id f20sm144508955pgg.56.2019.08.14.07.54.16
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 14 Aug 2019 07:54:18 -0700 (PDT)
Subject: Re: [PATCH v2] Add flags option to get xattr method paired to
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
 Ilya Dryomov <idryomov@gmail.com>, Hugh Dickins <hughd@google.com>,
 Serge Hallyn <serge@hallyn.com>,
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
 v9fs-developer@lists.sourceforge.net, Theodore Ts'o <tytso@mit.edu>,
 James Morris <jmorris@namei.org>, Anna Schumaker
 <anna.schumaker@netapp.com>, Richard Weinberger <richard@nod.at>,
 Mike Marshall <hubcap@omnibond.com>, Martin Brandenburg
 <martin@omnibond.com>, "Darrick J. Wong" <darrick.wong@oracle.com>,
 ocfs2-devel@oss.oracle.com, Eric Paris <eparis@parisplace.org>,
 Paul Moore <paul@paul-moore.com>, Andreas Gruenbacher <agruenba@redhat.com>,
 cluster-devel@redhat.com, David Howells <dhowells@redhat.com>,
 Bob Peterson <rpeterso@redhat.com>, Sage Weil <sage@redhat.com>,
 Steve French <sfrench@samba.org>, Casey Schaufler <casey@schaufler-ca.com>,
 Phillip Lougher <phillip@squashfs.org.uk>, David Sterba <dsterba@suse.com>,
 Jan Kara <jack@suse.com>, Miklos Szeredi <miklos@szeredi.hu>,
 Josef Bacik <josef@toxicpanda.com>, Stephen Smalley <sds@tycho.nsa.gov>,
 ceph-devel@vger.kernel.org, ecryptfs@vger.kernel.org,
 linux-btrfs@vger.kernel.org, linux-cifs@vger.kernel.org,
 linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-integrity@vger.kernel.org, linux-nfs@vger.kernel.org,
 linux-security-module@vger.kernel.org, linux-unionfs@vger.kernel.org,
 linux-xfs@vger.kernel.org, netdev@vger.kernel.org,
 reiserfs-devel@vger.kernel.org, selinux@vger.kernel.org,
 stable@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>
References: <20190813145527.26289-1-salyzyn@android.com>
 <20190814110022.GB26273@quack2.suse.cz>
From: Mark Salyzyn <salyzyn@android.com>
Message-ID: <71d66fd1-cc94-fd0c-dfa7-115ba8a6b95a@android.com>
Date: Wed, 14 Aug 2019 07:54:16 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190814110022.GB26273@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/14/19 4:00 AM, Jan Kara wrote:
> On Tue 13-08-19 07:55:06, Mark Salyzyn wrote:
> ...
>> diff --git a/fs/xattr.c b/fs/xattr.c
>> index 90dd78f0eb27..71f887518d6f 100644
>> --- a/fs/xattr.c
>> +++ b/fs/xattr.c
> ...
>>   ssize_t
>>   __vfs_getxattr(struct dentry *dentry, struct inode *inode, const char *name,
>> -	       void *value, size_t size)
>> +	       void *value, size_t size, int flags)
>>   {
>>   	const struct xattr_handler *handler;
>> -
>> -	handler = xattr_resolve_name(inode, &name);
>> -	if (IS_ERR(handler))
>> -		return PTR_ERR(handler);
>> -	if (!handler->get)
>> -		return -EOPNOTSUPP;
>> -	return handler->get(handler, dentry, inode, name, value, size);
>> -}
>> -EXPORT_SYMBOL(__vfs_getxattr);
>> -
>> -ssize_t
>> -vfs_getxattr(struct dentry *dentry, const char *name, void *value, size_t size)
>> -{
>> -	struct inode *inode = dentry->d_inode;
>>   	int error;
>>   
>> +	if (flags & XATTR_NOSECURITY)
>> +		goto nolsm;
> Hum, is it OK for XATTR_NOSECURITY to skip even the xattr_permission()
> check? I understand that for reads of security xattrs it actually does not
> matter in practice but conceptually that seems wrong to me as
> XATTR_NOSECURITY is supposed to skip just security-module checks to avoid
> recursion AFAIU.

Good catch I think.

I was attempting to make this change purely inert, no change in 
functionality, only a change in API. Adding a call to xattr_permission 
would incur a change in overall functionality, as it would introduce 
into the current and original __vfs_getxattr a call to xattr_permission 
that was not there before.

(I will have to defer the real answer and requirements to the security 
folks)

AFAIK you are correct, and to make the call would reduce the attack 
surface, trading a very small amount of CPU utilization, for a much 
larger amount of trust.

Given the long history of this patch set (for overlayfs) and the large 
amount of stakeholders, I would _prefer_ to submit a followup 
independent functionality/security change to _vfs_get_xattr _after_ this 
makes it in.

>
>> diff --git a/include/uapi/linux/xattr.h b/include/uapi/linux/xattr.h
>> index c1395b5bd432..1216d777d210 100644
>> --- a/include/uapi/linux/xattr.h
>> +++ b/include/uapi/linux/xattr.h
>> @@ -17,8 +17,9 @@
>>   #if __UAPI_DEF_XATTR
>>   #define __USE_KERNEL_XATTR_DEFS
>>   
>> -#define XATTR_CREATE	0x1	/* set value, fail if attr already exists */
>> -#define XATTR_REPLACE	0x2	/* set value, fail if attr does not exist */
>> +#define XATTR_CREATE	 0x1	/* set value, fail if attr already exists */
>> +#define XATTR_REPLACE	 0x2	/* set value, fail if attr does not exist */
>> +#define XATTR_NOSECURITY 0x4	/* get value, do not involve security check */
>>   #endif
> It seems confusing to export XATTR_NOSECURITY definition to userspace when
> that is kernel-internal flag. I'd just define it in include/linux/xattr.h
> somewhere from the top of flags space (like 0x40000000).
>
> Otherwise the patch looks OK to me (cannot really comment on the security
> module aspect of this whole thing though).

Good point. However, we do need to keep these flags together to reduce 
maintenance risk, I personally abhor two locations for flags bits even 
if one comes from the opposite bit-side; collisions are undetectable at 
build time. Although I have not gone through the entire thought 
experiment, I am expecting that fuse could possibly benefit from this 
flag (if exposed) since it also has a security recursion. That said, 
fuse is probably the example of a gaping wide attack surface if user 
space had access to it ... your xattr_permissions call addition 
requested above would be realistically, not just pedantically, required!

I have to respin the patch because of yet another hole in filesystem 
coverage (I blew the mechanical ubifs adjustment, adjusted the wrong 
function), so please do tell if my rationalizations above hit a note, or 
if I _need_ to make the changes in this patch (change it to a series?).

Thanks -- Mark Salyzyn



