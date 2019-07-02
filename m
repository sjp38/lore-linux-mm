Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62D76C06510
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 10:45:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 273A32089C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 10:45:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kdVby+/P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 273A32089C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B34DD6B0005; Tue,  2 Jul 2019 06:45:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE5B08E0003; Tue,  2 Jul 2019 06:45:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AC478E0001; Tue,  2 Jul 2019 06:45:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 74DA36B0005
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 06:45:45 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id h35so2149651ybi.18
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 03:45:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=vlidC+hQ/gD/8v9eleM4nXtfiap8zhCG0j5qbLCVw18=;
        b=WR9qU2JaVABJvhNaV0MdxWE75geg4RrH6vnB1GZ9lZ/T1y8RoMGbV3HIRa89Lxp3V1
         ihCBT0un+Px52U7/vFw04MZhSpEiDkk21CgHeR9OkFis32cF1VqjyxU23MTi7FclybUa
         5lNNcI378wGbkVf5tcva5YxgQNRJgxFxBPoT/B2rMk+IEwon2R65qnc5OJsGvi5A/5C9
         sKjQJ7cppKM0y8yxrL8ikaW8UQkJdkX3caLw6BNpbrUIsatpeCspi4r0ZDa8E9ovwhwU
         8O9lP9n/l8RfKOqZGfNrWAkPlx39cDkRVdU61GJoJRfdCLNiNxn0MrRjID1rHkNPC1kj
         +luA==
X-Gm-Message-State: APjAAAV+SP7eREQ7Aum6o4SeD0fETQlPKCGyw2GpADausnEEcGZrgeoJ
	07GH9/HqS6FIjmAVqja+irYgJ3HsqoAVsn189ovyJKlFSPecsxaBxuaG28eUFzO+HFKkvvKMZjV
	2yUK2X6teGt0CoK3TYHO8cgb/TsNOwjASgKQj7LVoVnViKB6kG8b3On3bTmr7rrvcWQ==
X-Received: by 2002:a25:df0e:: with SMTP id w14mr4120693ybg.401.1562064345220;
        Tue, 02 Jul 2019 03:45:45 -0700 (PDT)
X-Received: by 2002:a25:df0e:: with SMTP id w14mr4120666ybg.401.1562064344257;
        Tue, 02 Jul 2019 03:45:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562064344; cv=none;
        d=google.com; s=arc-20160816;
        b=fVbB9AdH+i4gSfkUIRVSLxIrASOvkaQbMdDyYq4a9mcbQR6zpG9cVlWdIXOHRhyRQ4
         epvsRnUN2du7PuH5dpq18EV/LoNNDZf2HTbnBXpaSecOjauvVAhHNnphob4CIubgylNh
         dsTm82TSN2+vafB/uKW6zVQ66PAqy2RAcAMFBoG7Y/VXNDIX86blCe2Al0/K9qqd8f8M
         OPz/Y8cWKHasMuCCTRuyxbOcwnhmKn2VLFi7E5vYYKeFM7qvRnksrVqKJSw9/BZpkYMy
         gtPeSCEyBJPQQvXZ34N1e9ViKuPyUvYt4nCSnvB6FXd7ocJdHUTTjILGW9K8jiGW/Nso
         /NdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=vlidC+hQ/gD/8v9eleM4nXtfiap8zhCG0j5qbLCVw18=;
        b=c5QNp7SeoAMcxobXmBFoAXdyLuHWa+fHoA5Q7IvwJwiyJhfdzRVy1exu4zKXkaz1DP
         LNgdpvcnL3Jy6VMmX9pnx4sFPlW+6p7V1jOX5yzCIeqappTHuLWUYLTSCtXCU5Ri+jCW
         +a9+r2JtEGc294nVWuOsQVeNdyqVn2xrMO6DqaaTTd2Xmxtmck51C2/HrTAsGW+iZwCx
         5T4ssUVfZ/SocyUM4AQeCL7uJkPcA0TSAxl3zManGjwk9DM2m2sbhvd0DfMnnm/b6VVv
         AhjGBr2RPHrOryZjl2jchb1RMBAQIv70B/7+fm9yz2b5D4fhpSRCKTOqm3sPy+nJSSDd
         VT+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="kdVby+/P";
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x7sor5238187ybg.192.2019.07.02.03.45.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 03:45:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="kdVby+/P";
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vlidC+hQ/gD/8v9eleM4nXtfiap8zhCG0j5qbLCVw18=;
        b=kdVby+/PzZu5i6Y9UcQYatHEHHsEPhAQY+mjVHF6xlggt8o+nszbdHXCHfEBil5H5H
         UL+/28eYKfUAOv8AvNzRMQHWK/y4MABFSamQhRwNZH1hpEc5BUQCjqITvhev6DLWRzG3
         uOgpinFcBt7pSePpbwiWspS3cbj7dBXMod+4Z94YngJ+nIPc3qdhbsYftXAC3oBGhakE
         Bt+6iCjbrfqQEg0SzB1WdrzlyuHEb0JfhuYdop7KFU8fbo4QPvOCj4+Z+NVkWFYsg5RT
         IRHHoit1jxeDZWaJHULPmpdSPTutxwczS9nSE3h7MYk2MPhM/kHniCv9ovLGXWy3LfTv
         lmfQ==
X-Google-Smtp-Source: APXvYqzMdrjXgWGhi/zPaZxEj+t8DhHrW56qP/YMhmryxOT2o02rqdhc3hQ5y4gjPvsnd8KwypjTK3Tgmn2Zfydvxjo=
X-Received: by 2002:a25:8109:: with SMTP id o9mr16913558ybk.132.1562064343920;
 Tue, 02 Jul 2019 03:45:43 -0700 (PDT)
MIME-Version: 1.0
References: <156174687561.1557469.7505651950825460767.stgit@magnolia>
 <156174690758.1557469.9258105121276292687.stgit@magnolia> <20190701154200.GK1404256@magnolia>
In-Reply-To: <20190701154200.GK1404256@magnolia>
From: Amir Goldstein <amir73il@gmail.com>
Date: Tue, 2 Jul 2019 13:45:32 +0300
Message-ID: <CAOQ4uxizFXgSa4KzkwxmoPAvpiENg=y0=fsxEC1PkCX5J1ybag@mail.gmail.com>
Subject: Re: [PATCH v2 4/4] vfs: don't allow most setxattr to immutable files
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: matthew.garrett@nebula.com, Chao Yu <yuchao0@huawei.com>, 
	Theodore Tso <tytso@mit.edu>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
	Josef Bacik <josef@toxicpanda.com>, Christoph Hellwig <hch@infradead.org>, Chris Mason <clm@fb.com>, 
	Andreas Dilger <adilger.kernel@dilger.ca>, Al Viro <viro@zeniv.linux.org.uk>, 
	Jan Kara <jack@suse.com>, David Sterba <dsterba@suse.com>, Jaegeuk Kim <jaegeuk@kernel.org>, jk@ozlabs.org, 
	reiserfs-devel@vger.kernel.org, linux-efi@vger.kernel.org, 
	devel@lists.orangefs.org, linux-kernel <linux-kernel@vger.kernel.org>, 
	linux-f2fs-devel@lists.sourceforge.net, linux-xfs <linux-xfs@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, linux-nilfs@vger.kernel.org, 
	linux-mtd@lists.infradead.org, ocfs2-devel@oss.oracle.com, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ext4 <linux-ext4@vger.kernel.org>, 
	Linux Btrfs <linux-btrfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 1, 2019 at 7:31 PM Darrick J. Wong <darrick.wong@oracle.com> wrote:
>
> From: Darrick J. Wong <darrick.wong@oracle.com>
>
> The chattr manpage has this to say about immutable files:
>
> "A file with the 'i' attribute cannot be modified: it cannot be deleted
> or renamed, no link can be created to this file, most of the file's
> metadata can not be modified, and the file can not be opened in write
> mode."
>
> However, we don't actually check the immutable flag in the setattr code,
> which means that we can update inode flags and project ids and extent
> size hints on supposedly immutable files.  Therefore, reject setflags
> and fssetxattr calls on an immutable file if the file is immutable and
> will remain that way.
>
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---
> v2: use memcmp instead of open coding a bunch of checks


Thanks,

Reviewed-by: Amir Goldstein <amir73il@gmail.com>


> ---
>  fs/inode.c |   17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
>
> diff --git a/fs/inode.c b/fs/inode.c
> index cf07378e5731..31f694e405fe 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -2214,6 +2214,14 @@ int vfs_ioc_setflags_prepare(struct inode *inode, unsigned int oldflags,
>             !capable(CAP_LINUX_IMMUTABLE))
>                 return -EPERM;
>
> +       /*
> +        * We aren't allowed to change any other flags if the immutable flag is
> +        * already set and is not being unset.
> +        */
> +       if ((oldflags & FS_IMMUTABLE_FL) && (flags & FS_IMMUTABLE_FL) &&
> +           oldflags != flags)
> +               return -EPERM;
> +
>         /*
>          * Now that we're done checking the new flags, flush all pending IO and
>          * dirty mappings before setting S_IMMUTABLE on an inode via
> @@ -2284,6 +2292,15 @@ int vfs_ioc_fssetxattr_check(struct inode *inode, const struct fsxattr *old_fa,
>             !(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)))
>                 return -EINVAL;
>
> +       /*
> +        * We aren't allowed to change any fields if the immutable flag is
> +        * already set and is not being unset.
> +        */
> +       if ((old_fa->fsx_xflags & FS_XFLAG_IMMUTABLE) &&
> +           (fa->fsx_xflags & FS_XFLAG_IMMUTABLE) &&
> +           memcmp(fa, old_fa, offsetof(struct fsxattr, fsx_pad)))
> +               return -EPERM;
> +
>         /* Extent size hints of zero turn off the flags. */
>         if (fa->fsx_extsize == 0)
>                 fa->fsx_xflags &= ~(FS_XFLAG_EXTSIZE | FS_XFLAG_EXTSZINHERIT);

