Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D24D9C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 16:37:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B75320657
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 16:37:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Val/xFIc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B75320657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E04168E0003; Mon, 24 Jun 2019 12:37:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB4348E0002; Mon, 24 Jun 2019 12:37:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7C838E0003; Mon, 24 Jun 2019 12:37:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id A8F728E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 12:37:05 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id x17so22492027iog.8
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 09:37:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=HA99AMTfTSc28plQQ/cp41x7Nn4dwb3FKNRresvoez8=;
        b=sPePvd4571Gpa23H+Fc/zDE/9lIQI0AwzuyZhahp876xkM7SW5OEs+jTl7BaUEMjuh
         fRNgE4JaASIq8WX6BtOEAwbvfYKO8SOQmjBMNJqokJlGVF/GaZfNBaxFqk5PflaKIiU0
         Qet8C93zWDO+NFVzfGp9+tpGDURXJDKyE9mKrym5p+D8BYKGAWLepwCj4ZkislO6DIjv
         i1LfKt8n0IG9HFCsuQRXoXIGPZTV+P+QiQ4gwLcShyXXlTmdKzmDqS+qZDOTqv50EQ/L
         c80NUX8axf6JghuhmAU/8bp4wmVpm6/kKTkF/qlNnwVuGQvso3VmuCa+CEEx8xI6wHYY
         dQbQ==
X-Gm-Message-State: APjAAAUY5KmqGHWfzMPx221vdIvdhVtu752FtFCpOlgnC7/ANLH5TDQH
	/ZFHat0MWU00lX6khB5Zx29rOmgQsTW0biC0ieZ1iasuNowLBUWloHWIe0gbgoPn+WnV980vIIa
	AZ8BZ/b9LoMPeaPt6qN3c98qni5P573fdCzQoRSsJFx5DbkZ5oyRt0NCCCw5liqr9lg==
X-Received: by 2002:a02:7121:: with SMTP id n33mr32263775jac.19.1561394225360;
        Mon, 24 Jun 2019 09:37:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOwJjLN0gfpg0aosYMvKy2F7UHoj2F9QWEer01IWDm1z98mANxX72J/pA5r6twoRG1upTQ
X-Received: by 2002:a02:7121:: with SMTP id n33mr32263709jac.19.1561394224607;
        Mon, 24 Jun 2019 09:37:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561394224; cv=none;
        d=google.com; s=arc-20160816;
        b=ABFZApEQuvnNPbjttLWOvcqXPZi8gy/vNOR4vwK2vparDY210jJ+XgcnBAS1kyf3ZA
         qNPkxWrFGcxJTjH8WFUP2JRkj4VJv1MlQBA0vQJ+/QU4QPypW3SndoMd24eM9596zgSw
         vUM+Z1EGeE5iglE4QzrOmWRkhjwSNxDW+2LPh1PkFu+Tl0ykG4PpQV9SwDedy2CFGuY/
         ERpbnYaSQL6sUrSZR36L2bDfdiF4OxfVsXyHNXcEJ9EKopph4wUPztbzGnQIA5XETE/a
         xUsRAVV7U1qSBW2nVg1zqQy/Gxkv2AhejQP+S9l1WIRE3C5aVGbszfOxaNK8b5GfVwAE
         +Hgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=HA99AMTfTSc28plQQ/cp41x7Nn4dwb3FKNRresvoez8=;
        b=DI3F+t5YqHE9SICOprVYqCIA8ovGe2CvCeLJpqlOX9nkPCnSUI34XG3Ta11d7GJoMH
         Xd+nhth5FsupNI8SAfwUSoROA9MWrnWySWG++EtWMz7DHx6g1HMxIGwI/q5LYNxRzSTB
         FPi/pF++pTt2ml343X3xrlTMK+doy8kvQyPzvNe9cznUTppDaQp7MC+HuROPscyBI5TT
         BpfmsUCEiv/YM9lE9ShuTSGxpMBv4Fu3Zw+CwSiq1272sowjrnQeThaJBjn0Kmgpm3oD
         ucZ9IWzooxyQzQOoiwGtyBz1xkOJaCAtqHpEQzMEUx2h5D2G5BoVt4C/vl93TEBwdH20
         305w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="Val/xFIc";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id f8si13576429iok.62.2019.06.24.09.37.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 09:37:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="Val/xFIc";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5OGYBIm140014;
	Mon, 24 Jun 2019 16:36:52 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=HA99AMTfTSc28plQQ/cp41x7Nn4dwb3FKNRresvoez8=;
 b=Val/xFIcmXfnvXdGrQBd2uUMZYObEi3W8WIlY6oMUJIKvjldL9xYJIbr4X8m/8PfUkNP
 RhH7NFaRejnXOwK4OrHcHI49LEDw30Z0srM0V+BtgIV6OV/ooJ8YuV1XwJC9gXt//xWz
 Q0bSRiqdmELhNdVSkCIZr87TrKLwiGMPLZJNCBd7weSod/LyeYSIITLeuy/oyb0/36Pk
 joZS32wTTBm4Xftsq9fhk9nHXmjGPPxMMMzommCPqRpU1cRv8ZoyAI6/8dXnLZ2krssP
 nfR6QpxDK+AWnV/OvlFkpdglsTrJTTQAP82qwXJGdU82OAjIBZeAn2VIxNce6Btsj8Q4 7Q== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2t9cyq7dxf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 24 Jun 2019 16:36:52 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5OGZS5o040090;
	Mon, 24 Jun 2019 16:36:51 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3030.oracle.com with ESMTP id 2t9acbktrd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 24 Jun 2019 16:36:51 +0000
Received: from aserp3030.oracle.com (aserp3030.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5OGaodY042889;
	Mon, 24 Jun 2019 16:36:51 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2t9acbktr8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 24 Jun 2019 16:36:50 +0000
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5OGaiFC016783;
	Mon, 24 Jun 2019 16:36:44 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 24 Jun 2019 09:36:44 -0700
Date: Mon, 24 Jun 2019 09:36:42 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Jan Kara <jack@suse.cz>
Cc: matthew.garrett@nebula.com, yuchao0@huawei.com, tytso@mit.edu,
        ard.biesheuvel@linaro.org, josef@toxicpanda.com, clm@fb.com,
        adilger.kernel@dilger.ca, viro@zeniv.linux.org.uk, jack@suse.com,
        dsterba@suse.com, jaegeuk@kernel.org, jk@ozlabs.org,
        reiserfs-devel@vger.kernel.org, linux-efi@vger.kernel.org,
        devel@lists.orangefs.org, linux-kernel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org, linux-nilfs@vger.kernel.org,
        linux-mtd@lists.infradead.org, ocfs2-devel@oss.oracle.com,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Subject: Re: [PATCH 2/7] vfs: flush and wait for io when setting the
 immutable flag via SETFLAGS
Message-ID: <20190624163642.GT5387@magnolia>
References: <156116141046.1664939.11424021489724835645.stgit@magnolia>
 <156116142734.1664939.5074567130774423066.stgit@magnolia>
 <20190624153358.GH32376@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190624153358.GH32376@quack2.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9298 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=682 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906240131
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 05:33:58PM +0200, Jan Kara wrote:
> On Fri 21-06-19 16:57:07, Darrick J. Wong wrote:
> > +/*
> > + * Flush file data before changing attributes.  Caller must hold any locks
> > + * required to prevent further writes to this file until we're done setting
> > + * flags.
> > + */
> > +static inline int inode_flush_data(struct inode *inode)
> > +{
> > +	inode_dio_wait(inode);
> > +	return filemap_write_and_wait(inode->i_mapping);
> > +}
> 
> BTW, how about calling this function inode_drain_writes() instead? The
> 'flush_data' part is more a detail of implementation of write draining than
> what we need to do to set immutable flag.

Ok, that's a much better description of what the function does.

--D

> 
> 								Honza
> -- 
> Jan Kara <jack@suse.com>
> SUSE Labs, CR

