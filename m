Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FA14C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:04:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A75E8206BA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:04:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="x/aLz03x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A75E8206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D3836B026E; Wed, 17 Apr 2019 15:04:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55CE46B0270; Wed, 17 Apr 2019 15:04:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FEBD6B0271; Wed, 17 Apr 2019 15:04:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 031996B026E
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 15:04:45 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id p8so16850781pfd.4
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 12:04:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=y+PxHRpKRR8FMn+l+nQg0fxdlWX1SCLNjd1udTc7yR8=;
        b=t4eGzG/9U8sh99Sjbu5LL8atq8nwOOGYjuWUNDq7flIfCC6Ihl9w3eaN9JBFsmmvUM
         pHF99nMdCxDmLpaoF8kPHyIXzSY6IjryE90mZpKRXcHVUJ/rv/Wc4yLsgvm4gg7SpkTE
         TBa96IISYuDpnReQD+W9dNP/fLUsY2syt7m+vVSVGiX0fYUY4QQiqbIEWDHhkeHbayj5
         qv2tOMynX42+vL9vwc3nqxgw4Sh7C0nQRhIJsyCKA/AV1e16sPaXIx39wQD2UNdyXb2P
         CGmcMEAtStIfjQKEfbKXzJDa4imG/RaJ/fPkp6MUfqm+rAIAfB3BUr42gy5pJKbOW54Q
         EW+g==
X-Gm-Message-State: APjAAAWQ1GP28hg30+J5R+eX5AeSaxe91HeER6DCAf/EcxlVtpa7Vtho
	l4OaPk7YOjKEbJrdg2OkynmWvqoyBIFs5G2xDk6i29jiMjWFw69Nx4COpUrUVNDD01jAhVgpV9o
	NdVnrnBUQZBmOTjBrYgSSWucFW+Q8up3AugfdZcN58fBy2K6AZP/Eeh/ZYyqoAAWMKA==
X-Received: by 2002:a65:6202:: with SMTP id d2mr5840515pgv.176.1555527884688;
        Wed, 17 Apr 2019 12:04:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAWm4Ytl5pdSxY++OQWF2TDA0xSWUbodD8LwP6umNDUCHrjbPxGOgfHc+Zkte0IQm9uOYy
X-Received: by 2002:a65:6202:: with SMTP id d2mr5840467pgv.176.1555527884052;
        Wed, 17 Apr 2019 12:04:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555527884; cv=none;
        d=google.com; s=arc-20160816;
        b=UvHWlCZT9zFVdf45EXEOkFsDWYLKBrmYLf1rf4U1cz7WUmjaEHXPTlX/lbsYUCQncR
         7JoXiity/xQEP2+TwUiQYRJen3c148TpGG0g7QbaRoMTd51mS3PuQ1EoLg9MEPETLVY0
         uhNaEB3HZi5HZCVSMgppPXfGmPQEfsWWc5PySEmo2tctxJ0VoLaJGj3nY3SVlBvpRjcB
         Bs72/WVOYN0RxaOfo2BogAN8ijoFmrK6MJP3fQeYGqN5t//HTkYgBKbxUeKVcDks8tDS
         PDTlUrnZ2CnOSSI2aKD07jHRHZ9kdmxx8PN0AT6E/WJt/6T0wvNSFLp9OsheEMzEK5ul
         eWCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=y+PxHRpKRR8FMn+l+nQg0fxdlWX1SCLNjd1udTc7yR8=;
        b=RVnsCiaDODcLOaytxvODu9Ys2MbarBpAeKY2PiFSDOIHECRm0NaRWKlSgVkdbQU9TT
         Obf4hx48s6nBky18zsG7+hpYFT3rI7TfnGVTA9Ze6/oGsIJD6ci8cyDQBoB0zSeEB5RT
         v7pnVN9t66P34Z40AUNiIUvd6abIWSn+3JAJV9NOMq5lYH/V+tSG3SSKr/j5K1CN0sGY
         OwB372CtEPUMLiCWa1w4ObJbYJH+sTsRxarJSMaggOJYDf6hoFTNAgv86kk1d0v5w6ob
         q+ds5OsuWN12nmlBxKebn3c7J1rWQotO5zjWgBa1bhCx8KkbVJPlKpk7Yz2OB8kOSJvt
         /Rrg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="x/aLz03x";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id k12si49447264pll.73.2019.04.17.12.04.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 12:04:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="x/aLz03x";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3HIwtRL185818;
	Wed, 17 Apr 2019 19:04:43 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=y+PxHRpKRR8FMn+l+nQg0fxdlWX1SCLNjd1udTc7yR8=;
 b=x/aLz03x9oud8wZan9RTBVwgCc31dEemOIKWGIia/Zw+wSbao09lIvbCBQSjxxPTf5XI
 53Xegw/lfsTQe2QPikyDzTuxivy9Yu0n9Kmt+eqqdCSFtUXeZrffaY0W5H6rSX1Ow5L0
 BU/a0kveDWkVPhMfXYicCFxJJJ12LnCw5mFpiaGbHyc4bcj7h9FySx1DPUj5oEurK/1r
 eVVe+oILw48oHvz2FDvcXEOmtU6evGrWh50fBTfx6ytDIByWiPBN3uGA+tiVFWWj8Dgf
 Bozd4pa1FQgPv//cDWhDStAlrKY8BmqHqbQoqQTBFjf1D1wiUiz9cWwE1ydcKOsb1kkb Yw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2rusnf2vg0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 17 Apr 2019 19:04:43 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3HJ49EM159083;
	Wed, 17 Apr 2019 19:04:42 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2rwe7ak1g9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 17 Apr 2019 19:04:42 +0000
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3HJ4fde008279;
	Wed, 17 Apr 2019 19:04:41 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 17 Apr 2019 12:04:41 -0700
Subject: [PATCH 2/8] xfs: unlock inode when xfs_ioctl_setattr_get_trans
 can't get transaction
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: darrick.wong@oracle.com
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mm@kvack.org
Date: Wed, 17 Apr 2019 12:04:39 -0700
Message-ID: <155552787973.20411.3438010430489882890.stgit@magnolia>
In-Reply-To: <155552786671.20411.6442426840435740050.stgit@magnolia>
References: <155552786671.20411.6442426840435740050.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9230 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=1 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=798
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904170125
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9230 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=820 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904170125
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Darrick J. Wong <darrick.wong@oracle.com>

We passed an inode into xfs_ioctl_setattr_get_trans with join_flags
indicating which locks are held on that inode.  If we can't allocate a
transaction then we need to unlock the inode before we bail out.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/xfs/xfs_ioctl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)


diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index ae615a79b266..21d6f433c375 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -1153,7 +1153,7 @@ xfs_ioctl_setattr_get_trans(
 
 	error = xfs_trans_alloc(mp, &M_RES(mp)->tr_ichange, 0, 0, 0, &tp);
 	if (error)
-		return ERR_PTR(error);
+		goto out_unlock;
 
 	xfs_ilock(ip, XFS_ILOCK_EXCL);
 	xfs_trans_ijoin(tp, ip, XFS_ILOCK_EXCL | join_flags);

