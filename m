Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 253C6C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:04:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C786D206BA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:04:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="PGpVhSwj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C786D206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75A206B0266; Wed, 17 Apr 2019 15:04:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E3C56B026E; Wed, 17 Apr 2019 15:04:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55FCC6B026F; Wed, 17 Apr 2019 15:04:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 179456B0266
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 15:04:31 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id s26so16784333pfm.18
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 12:04:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=tJjUPprNZ1wKy9741AhGUQYtsmORe3rs1XCk6inkF1g=;
        b=iM4bQ8xsP4zRleTfdKGIt6VHxJtl8yxLASm1DRN6IFv2J5JBSIu709R1R9rcYaMHdj
         aCTkS6Zxk7ysC+eQULo+7gc0EX9ysX+0sjbtMK8rtJj3zRF3fe0MzINxJASuzmHhS3hG
         jfg2x0pTNuhKIMbDPuqSs77ZoiYqGxwocRtapG6VYetGfKEB1atBCc1h2fg8cqt+w7XE
         hIuuMAKGM14yvib0uztl85q0nlczhiyU2Hceasvp0uts3vrzfQhQ6fcrWXi/93b1F/+v
         UK9s8PXB9W4UIno0OkqJBVgAdk/LTLgEaBBpWNptc/FW025tUtByXGo7askmuCIm9VgR
         4QQA==
X-Gm-Message-State: APjAAAXingdkc/FxRpc1cOqW51IJcsdHDTlhc+EYwdFZqlgoIwMQp7Wz
	R+e7RARRQE94rgbbdRZ8qkICXtDFozLi4bLFEtgg0NWLrPA2rj40a/4Bo6309WAsShlRbaDZYZk
	uIEnyChS8uSV5tzYCSd6AK6qhQuLYrN7QZJfzSwiNM3uAl9T9RR+F9LVTDKZOrVxIOQ==
X-Received: by 2002:a17:902:be0a:: with SMTP id r10mr87766574pls.4.1555527870670;
        Wed, 17 Apr 2019 12:04:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEBjUzKRGWq002uqLwiYGFWCaVGhziaM5oGlgRxljYjwxBaZ2hB/mEypO3jbolTG0eovJh
X-Received: by 2002:a17:902:be0a:: with SMTP id r10mr87766500pls.4.1555527869964;
        Wed, 17 Apr 2019 12:04:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555527869; cv=none;
        d=google.com; s=arc-20160816;
        b=HfggYjGMkY/K+WzFgkMLxvwQD1frNrwendNlAa5xK1fMC900wpiaEWrJMYUwbl0n2A
         I6GnNNCHO6eYjdv6C4k5Rzcc+ctAFCN03UOQn8MvwHyxcWsz9J9LV+oV7INmiEcsxu8T
         hXtsB5XllnEhlO+sbJ75Qplo4o4uvmveSyrPDHVQNALp72uy84BhfczPNHIzXIMj+VGz
         0P3hzbmotMdWtO5QU8tHbO5T6+zaBVQrvOVlIsFVTyXbfv/W3j6cFpbRnGvGDFFRzXfj
         K8O0f6vIurGJsHHefGmZt024RuvikCkstYrZQi7H7MPZvANgAW9I3JE3E88dyc61r2LD
         Scgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=tJjUPprNZ1wKy9741AhGUQYtsmORe3rs1XCk6inkF1g=;
        b=XL8g++YQgo3FLnqnrDa8kA2Iqai7e2sWIx4r/NUHWR4/SatUTxgtb1AeoKdmGWWWtF
         96LutL0bSPDoVTEugD6OBNJ4aAz6L3oTv+RaOfdB0EDGdG+dbUnFwZrsAYQEWgfX17wW
         WzeHP0i3sUuIiN4DDZffN6h5fnMiY8UoxZgY/RxftPU3uKBCaFEE9K6pS6HVr1A789Xx
         MBnHDyVeCqMZGPXeqWR3jUNTQYBCF3FoVJs/Ut/nclwpN1of8F98f3q6/cnrJr5B6p+g
         Y5wFFcsEr6/mDE0Pm1GMsMXMuqUldiSHNdTgz1tvnIazEeVRUWhvcdBqkSzQc5hUstXp
         RKkw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=PGpVhSwj;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id ba5si21230504plb.24.2019.04.17.12.04.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 12:04:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=PGpVhSwj;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3HIwqNW168716;
	Wed, 17 Apr 2019 19:04:29 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : mime-version : content-type :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=tJjUPprNZ1wKy9741AhGUQYtsmORe3rs1XCk6inkF1g=;
 b=PGpVhSwjWwjZhLcFGeJMy4FSK4TQvpDW/+Z1BwxTqP4qSxpar+qyGMKVU0s/Iuk1GiR+
 TtTnA+ISP2oXpuRIAOBIh8TMz5PJMzPlSkPJoP5HQg5w5RNZe0zw/dbx7Os2kfeSg9hx
 kWpXAEq9cK8EqGWGWsBAbUK7XaIIw7jPQpwW6m113y0Sh5ETiVTzeG7U65EvWIDjN9lR
 Wkcid6e5MSS4aO0d4pkB27GK+ZJKBASFvoBDhb1+VbS0gkPw/Tkl/KCRnIJxLpDf+EOs
 2CQZpjruLCmLouY9yZleRDTM1z+6shFtB8OBsEXekX/n6LMVefoQ16lZSGp26/7H64ru BA== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2rvwk3w090-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 17 Apr 2019 19:04:29 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3HJ34ca081874;
	Wed, 17 Apr 2019 19:04:28 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3030.oracle.com with ESMTP id 2ru4vtyxhp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 17 Apr 2019 19:04:28 +0000
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x3HJ4RDr008926;
	Wed, 17 Apr 2019 19:04:28 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 17 Apr 2019 12:04:27 -0700
Subject: [PATCH v2 0/8] vfs: make immutable files actually immutable
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: darrick.wong@oracle.com
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mm@kvack.org
Date: Wed, 17 Apr 2019 12:04:26 -0700
Message-ID: <155552786671.20411.6442426840435740050.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9230 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=842
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904170125
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9230 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=866 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904170125
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

If you're going to start using this mess, you probably ought to just
pull from my git trees, which are linked below.

This is an extraordinary way to destroy everything.  Enjoy!
Comments and questions are, as always, welcome.

--D

kernel git tree:
https://git.kernel.org/cgit/linux/kernel/git/djwong/xfs-linux.git/log/?h=immutable-files

fstests git tree:
https://git.kernel.org/cgit/linux/kernel/git/djwong/xfstests-dev.git/log/?h=immutable-files

