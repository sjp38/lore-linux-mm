Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7C19C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 17:50:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95E6F20823
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 17:50:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="g5Us3M5u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95E6F20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 300C96B0005; Thu, 28 Mar 2019 13:50:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 287026B0006; Thu, 28 Mar 2019 13:50:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 129196B0007; Thu, 28 Mar 2019 13:50:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C8C4E6B0005
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 13:50:40 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id b11so16909919pfo.15
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 10:50:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=UNp5UajRP0TYe7MVFZc545v0F1Jrs14oVb6FcV8yLDg=;
        b=O+WjvJCyyU1Ey2IAkpm6VZyYgEFJ6KgTlwf8HDMcrHTfHNaxAQFuPsfJVTFC+YR0u9
         KREBn6tJT08EJcOAy/wusYjbHP6q2c6YH9CCInMNJgJ5YH7Z9uP8k5vh6vhodaYBedCU
         106mgQZQE9Mlyp7R8+5nuplekP3Y4cec/aVQoRGQmavj++NFTeeEfORO5VePih0JZI1J
         fCAdYeaKIZZIK7xNrdg4ZdYKXecdG7qX2Ko3oLAzR0d+grbznqq2ek0nUaQHzrPSZlbr
         BNnEDh+r+6RAVBpfwy90HG8H3ws8lamm6IontCAS5Vv3DLnGAWEzOs80lhiMU7ePXAPo
         paxQ==
X-Gm-Message-State: APjAAAWsBPmW2gjJWVDgiO48x55FfWxGLxwsJhE5JC9UvSZ6phWTIgX0
	SITZrMYEnV9SLO05wp8Ri92cYVe1sdRk5QQnQZxYlL7mkNlBiUQPkokwDk6+ULhjRwaKOHAQAkc
	0z4wMrAVUyN0bh3G1EVxkXw0OetZQCNiN7GIpw/Ib5YBcVmpEKqcIbxc030Q9GkKIlw==
X-Received: by 2002:a65:65c5:: with SMTP id y5mr41790214pgv.192.1553795440221;
        Thu, 28 Mar 2019 10:50:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHe7e0fELnid/wJzowOINE2PLEb9+HrMDl8qeVbvsG/KB8pbKaUEMETenmpGAXxYnfjh1I
X-Received: by 2002:a65:65c5:: with SMTP id y5mr41790155pgv.192.1553795439274;
        Thu, 28 Mar 2019 10:50:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553795439; cv=none;
        d=google.com; s=arc-20160816;
        b=FS/b2bfTDXeMA63zVaLtt46e4rLK9eKIssYYN3ZORRogTTAV0AFPbat8wBs1Y/FB1U
         r8p9YZKGvHwYtG93r34FASTiKAfmGRtdaG4am9S0fS0V6Ptq45I0Aa/H+hnwGNNslvSo
         qDuLE/WHAuxTV5dYuyiKfeRLwc2ykMt5EqkwGcH0RHUOQrpDvfN3rm690PP7TrnONYnB
         GjsmiqjZ1kF3SD9IVstRcGuPmwzzOrn7zA7Mgkdkt6XpDlBkbhx2h9aY016W78GUuL8E
         BagT7fdbB1wfXf1ewgHf0qgWHeTKn77USwxiLmN3v3fq4ux+Idxrxneih73NtMQXbigK
         cMPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=UNp5UajRP0TYe7MVFZc545v0F1Jrs14oVb6FcV8yLDg=;
        b=xdw09BVbbxJPc49j7XlxaIc/DgQoaux21zM40VL3LpSbi3Ws6SEpZslL8Is2kHELsA
         tXQbeig6yRtAfMbqpu743M+3rh8nZD0xy2ML4vYdBHTbwagHPGdL3j49buvSVo2b7db2
         rvv9BxyW66KQH4chCFfpr7fHJU9QVRXVfcsGCbWsDqM1IY+XT8MP0k1MjRybTa2NszZa
         oZdW2PMmxXNIv52PnK96SgTADeb/OgeAi3xj+RtVBsSp9kOaTz0DURw91BlnYNm+KQNb
         aUPozbrRjTXU4x0I3V2WdJITt+GfJgOUzJj+su150spvJz7tqWbqn4JGlMmWkhhl3SYC
         CpxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=g5Us3M5u;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id w67si6100766pfb.20.2019.03.28.10.50.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 10:50:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=g5Us3M5u;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2SHnV1r045442;
	Thu, 28 Mar 2019 17:50:38 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : mime-version : content-type :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=UNp5UajRP0TYe7MVFZc545v0F1Jrs14oVb6FcV8yLDg=;
 b=g5Us3M5uwvfiVcmGVSth4oChqwEma8n39onuAXCr6Vj9gVoxLraLA5s6xmqwsYgw2mI7
 L1AA+eZXd9vnCgY2wUNwBGumDR0HhKy+qshBCXW2HzrFeUQpCsmvkzFkVyAUlV/2SbjF
 FDIHz25JWp8a8hl/pL2ZLN/dkVRVk0XqpAfxmONiwCj8TXVveJJJvd/kc+VDg5g9iwsi
 bKwqWg91hMrOQpHbgjrlf2jvziHLiYqW1Q6CcREwIFxJSy0di6L2nDyUjtv3ta9pFpa+
 UKJL9zv87JURDjpZwfLwgmIA5nAYHqwSY29Ct8GRM1kIscwIj/FSCs2Q44pfi+W7RAaf +g== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2re6g1g6nb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 17:50:38 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x2SHoaSQ029430
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 17:50:37 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x2SHoZDr009350;
	Thu, 28 Mar 2019 17:50:35 GMT
Received: from localhost (/10.159.234.216)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 28 Mar 2019 10:50:35 -0700
Subject: [PATCH 0/3] vfs: make immutable files actually immutable
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: darrick.wong@oracle.com
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mm@kvack.org
Date: Thu, 28 Mar 2019 10:50:34 -0700
Message-ID: <155379543409.24796.5783716624820175068.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9209 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=554 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903280117
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

The chattr(1) manpage has this to say about the immutable bit that
system administrators can set on files:

"A file with the 'i' attribute cannot be modified: it cannot be deleted
or renamed, no link can be created to this file, most of the file's
metadata can not be modified, and the file can not be opened in write
mode."

Given the clause about how the file 'cannot be modified', it is
surprising that programs holding writable file descriptors can continue
to write to and truncate files after the immutable flag has been set,
but they cannot call other things such as utimes, fallocate, unlink,
link, setxattr, or reflink.

Since the immutable flag is only settable by administrators, resolve
this inconsistent behavior in favor of the documented behavior -- once
the flag is set, the file cannot be modified, period.

This has been lightly tested with fstests.  Enjoy!
Comments and questions are, as always, welcome.

--D

