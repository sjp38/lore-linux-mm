Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A0E6C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 05:49:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAD9220883
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 05:49:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="kgirDgby"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAD9220883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70DE76B0283; Mon,  8 Apr 2019 01:49:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BEFA6B0284; Mon,  8 Apr 2019 01:49:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 560136B0285; Mon,  8 Apr 2019 01:49:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 18DA96B0283
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 01:49:20 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id b11so9682503pfo.15
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 22:49:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=027zM/YiSxoqXFDKPDkpG0BuEZrLNy/aYPmVOdfq8sE=;
        b=SWJah7YSEMx45YggpAWzRRayArspgqWf/jgi1edhFOdPPb2SLJqTPCCKkqUNexuLli
         1R+FHIwKwqbjRJaTa1YqxT0ZXR2T/SxqvOSHhVnjk26ROOvUFjpOYnhNJl9tpdk6nVhF
         0lz7i9HcXRi6rjcS0yZKMaXSdeQKByW4O7hFLJYgc+3382gRvoozvNhihpyOX+cnKics
         fNDaqWJI8wjecTg5zwDVEq5kSk3ixJmqaICTrdP8ah4obTwaYNu8c7JMmWbDgFUIHs2Q
         Oph8zcaxgFBfcwqmh3sBg20ZxQ2R983p9fCf3lTO44N6bPAGx5gyjTC0SU5n2/6MKaBM
         BeSw==
X-Gm-Message-State: APjAAAVvtXzMLAKeaB3JibGulrWPTAOpwDlrN9Tg+b633ei0nv0aqD3l
	USw6yggjw1HwRkEZQNXPB64NgDsYWv06unyWdlcsLAoCD0fyZtGIOyA6QaVFXyO1QPNODFRQkxE
	lvuwz0cP+xG0gF/Z/ub5ceo4yz9f059IW0WbJCn+3fjTbNoPxve9E1/nrkWq2/8OqgQ==
X-Received: by 2002:a17:902:f084:: with SMTP id go4mr27337691plb.235.1554702559639;
        Sun, 07 Apr 2019 22:49:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzy2TY2+3+WYUmk84Jra3NKJjv+Tc1lM+QSoFzLmhPX4EuWIdvB6qhs47YeUCXRtqBEw3X
X-Received: by 2002:a17:902:f084:: with SMTP id go4mr27337655plb.235.1554702558960;
        Sun, 07 Apr 2019 22:49:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554702558; cv=none;
        d=google.com; s=arc-20160816;
        b=JElwgEO51y5aoBK3rsJ4m6B0MLO8KX/2PPNW40tLPTJWffmx/hzaj8WNuIBehLZws2
         /UDUKpnJvzKislWH5uNm+tm8TUwBumKAyCRxDrYw6tdcUhYCAUjIeBxxDvmwaBN3rwvy
         00N5JsKEbSjQmnqOKeEAHz49XVoAjgzsOkt+SA9o3hbrObUH82WE79mrfBT8L2AJE6wx
         kypHguEf6ZTSrzLSaCDsRntbvWaCdVxqhibq3hgp8q//RFxPy3vlbSFNwC7em/DE5Ycd
         +L5o3B3dDSyM54qoKUxpTTy5PHEOAlwaTB5tME8XmK8kDMJ29feE371h5Fs4qs1jWDPu
         MDow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=027zM/YiSxoqXFDKPDkpG0BuEZrLNy/aYPmVOdfq8sE=;
        b=p3QfFAtZ7U30VivSRiGOs98QhpQ0HXzOQSD3q5Iiaz6SrG2yhSWOk78DjAsoYztr35
         xjbO9NA4mc0ZgBhsMHsWNi5wDaq/gx2V8GRA1P5fthMkEihL30dax8oPiYwFJ7lansnz
         1Elq5IF4TVBeU5vr7NHbJeW+c3jLqUte3ud3yt9oK0DOvupI6S+CH8rKGVAQmoNfkiCj
         tvxbcK8hCqrmYZ0NrRBqL6B3ZDXIpn82tSTIc1KSwON8tMnav+lElFccrXC3taGHOkBD
         GBVaYa+xdK4qUNNmUZixxpX0kbYGyZzAqTR9yuUi8rOSIToKakqrwoQNMg0wVCYjd6/S
         6rqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=kgirDgby;
       spf=pass (google.com: domain of allison.henderson@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=allison.henderson@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id b8si26970620pla.290.2019.04.07.22.49.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Apr 2019 22:49:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of allison.henderson@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=kgirDgby;
       spf=pass (google.com: domain of allison.henderson@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=allison.henderson@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x385i9fQ032524;
	Mon, 8 Apr 2019 05:49:17 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=027zM/YiSxoqXFDKPDkpG0BuEZrLNy/aYPmVOdfq8sE=;
 b=kgirDgby8kRRxyY4w4Kl6rjVzP7KiusnwL7fBE7Pm6hJold9hb8SIxCv1V1evILgtjBU
 3z20Mi5TEwSwHLC0pZSkDyKoYuwbHuh1yzbShn4Ake6ZQ6LVFi/p7p5Q847izG27O8C6
 r2tfsfOj8pfgmd29YVY+wCdgk8wwIrKmwnCl2DLhcNE6nBKe6AH9FHc0FpaxA3GOskDQ
 PPoqaO4G+UDUnUUh0GoCQfN8qwbt7yXGJ09a8LfqV3gjM81+ctSVnkE+wL3VgUzaSNJq
 aoRT7QF1UD5ZJpEJGDSdZ6IspOZ4mGzSk5+7LmHB4boOF0iGwKb0BOaGRNslThz6uT7P Ug== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2rpmrpuy2r-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 08 Apr 2019 05:49:17 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x385liMV034085;
	Mon, 8 Apr 2019 05:49:16 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2rpj59t5jx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 08 Apr 2019 05:49:16 +0000
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x385nGHr030113;
	Mon, 8 Apr 2019 05:49:16 GMT
Received: from [192.168.1.226] (/70.176.225.12)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Sun, 07 Apr 2019 22:49:15 -0700
Subject: Re: [PATCH 3/4] xfs: flush page mappings as part of setting immutable
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
References: <155466882175.633834.15261194784129614735.stgit@magnolia>
 <155466884294.633834.1486289166159962611.stgit@magnolia>
From: Allison Henderson <allison.henderson@oracle.com>
Message-ID: <e5749655-2c12-a3a0-7ce8-8f5a9a9eb20e@oracle.com>
Date: Sun, 7 Apr 2019 22:49:14 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <155466884294.633834.1486289166159962611.stgit@magnolia>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9220 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904080053
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9220 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904080053
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/7/19 1:27 PM, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> The chattr manpage has this to say about immutable files:
> 
> "A file with the 'i' attribute cannot be modified: it cannot be deleted
> or renamed, no link can be created to this file, most of the file's
> metadata can not be modified, and the file can not be opened in write
> mode."
> 
> This means that we need to flush the page cache when setting the
> immutable flag so that all mappings will become read-only again and
> therefore programs cannot continue to write to writable mappings.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---
>   fs/xfs/xfs_ioctl.c |   51 ++++++++++++++++++++++++++++++++++++++++++++-------
>   1 file changed, 44 insertions(+), 7 deletions(-)
> 
> 
> diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
> index 91938c4f3c67..5a1b96dad901 100644
> --- a/fs/xfs/xfs_ioctl.c
> +++ b/fs/xfs/xfs_ioctl.c
> @@ -998,6 +998,31 @@ xfs_diflags_to_linux(
>   #endif
>   }
>   
> +/*
> + * Lock the inode against file io and page faults, then flush all dirty pages
> + * and wait for writeback and direct IO operations to finish.  Returns with
> + * the relevant inode lock flags set in @join_flags.  Caller is responsible for
> + * unlocking even on error return.
> + */
> +static int
> +xfs_ioctl_setattr_flush(
> +	struct xfs_inode	*ip,
> +	int			*join_flags)
> +{
> +	struct inode		*inode = VFS_I(ip);
> +
> +	/* Already locked the inode from IO?  Assume we're done. */
> +	if (((*join_flags) & (XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL)) ==
> +			     (XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL))
> +		return 0;
> +
> +	/* Lock and flush all mappings and IO in preparation for flag change */
> +	*join_flags = XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL;
Did you mean |= here?  It looks like this code came from 
xfs_ioctl_setattr_dax_invalidate, but now calling from 
xfs_ioctl_setattr, we may be over writing flags where we previously had 
not, so that may not be expected.

Allison

> +	xfs_ilock(ip, *join_flags);
> +	inode_dio_wait(inode);
> +	return filemap_write_and_wait(inode->i_mapping);
> +}
> +
>   static int
>   xfs_ioctl_setattr_xflags(
>   	struct xfs_trans	*tp,
> @@ -1092,25 +1117,22 @@ xfs_ioctl_setattr_dax_invalidate(
>   	if (!(fa->fsx_xflags & FS_XFLAG_DAX) && !IS_DAX(inode))
>   		return 0;
>   
> -	if (S_ISDIR(inode->i_mode))
> +	if (!S_ISREG(inode->i_mode))
>   		return 0;
>   
>   	/* lock, flush and invalidate mapping in preparation for flag change */
> -	xfs_ilock(ip, XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL);
> -	error = filemap_write_and_wait(inode->i_mapping);
> +	error = xfs_ioctl_setattr_flush(ip, join_flags);
>   	if (error)
>   		goto out_unlock;
>   	error = invalidate_inode_pages2(inode->i_mapping);
>   	if (error)
>   		goto out_unlock;
> -
> -	*join_flags = XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL;
>   	return 0;
>   
>   out_unlock:
> -	xfs_iunlock(ip, XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL);
> +	xfs_iunlock(ip, *join_flags);
> +	*join_flags = 0;
>   	return error;
> -
>   }
>   
>   /*
> @@ -1356,6 +1378,21 @@ xfs_ioctl_setattr(
>   	if (code)
>   		goto error_free_dquots;
>   
> +	/*
> +	 * If we are trying to set immutable on a file then flush everything to
> +	 * disk to force all writable memory mappings back through the
> +	 * pagefault handler.
> +	 */
> +	if (S_ISREG(VFS_I(ip)->i_mode) && !IS_IMMUTABLE(VFS_I(ip)) &&
> +	    (fa->fsx_xflags & FS_XFLAG_IMMUTABLE)) {
> +		code = xfs_ioctl_setattr_flush(ip, &join_flags);
> +		if (code) {
> +			xfs_iunlock(ip, join_flags);
> +			join_flags = 0;
> +			goto error_free_dquots;
> +		}
> +	}
> +
>   	tp = xfs_ioctl_setattr_get_trans(ip, join_flags);
>   	if (IS_ERR(tp)) {
>   		code = PTR_ERR(tp);
> 

