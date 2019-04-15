Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C6EAC10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 10:26:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C83B2075B
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 10:26:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="LnCj7QAV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C83B2075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE6E96B0003; Mon, 15 Apr 2019 06:26:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A965A6B0006; Mon, 15 Apr 2019 06:26:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AD3C6B0007; Mon, 15 Apr 2019 06:26:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7BEC26B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 06:26:15 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id m8so14281201qka.10
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 03:26:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=/BPNJ5Z0meskioHq9nZpVNtN1OnHlR0EfY4j+0WKJwI=;
        b=iQx+rTMWWK7no7XqrKNmkIKK0lfBByvFRQRMKDn14uHb5Iu9E2tFZZLI3U8de5QRY8
         DXGPSyA18vS4rVPkUfXLxcFbB1GiuFnFyuY4OywXjzWXse+8O6MJ199l0Gk25i6h4IWD
         l+tMd6D2yEHYmbDbMwusAQWT04fVEi4VqjPLs933vosUymPxbmN72d14rPkOpjoESPK8
         X2FJvwQqa6pghkrW6rlHXfCGTJBefAI7TkL08tGX1LfHK5ag5Zce7KA7aoboxfkb77XS
         7l9cIPupISvoN4AgVAuWjMU/Axe1uy9FNEJjxpoOnknumnlCu7JmtLOIS6rl46rEgOo9
         oOLA==
X-Gm-Message-State: APjAAAVtwrKVhaYdiHp7mHnA/rrSSrXku4ROK5VHBnW4kAsOXSTqH3kW
	6IwXEAmbiH5Y65PlMf5WHNLk2iEjD9vnfRPsYJFahX0ENLnPcAMzWsMo1QBlsujvMbuXa5/doOw
	ie0H9jeVXLOQBg1LQRMr41Yroby9Zz3pFDJCOj9bNMUsQ82zxFVp1hf/+vUM3Ygnhew==
X-Received: by 2002:a0c:b99c:: with SMTP id v28mr58950528qvf.10.1555323975292;
        Mon, 15 Apr 2019 03:26:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyExl9fR36gW0wJX2HNF4WaDD5HANjsnx5pla1AvrgZ3WkwKDZ7T6/KmCuK+ULb3CVluyew
X-Received: by 2002:a0c:b99c:: with SMTP id v28mr58950490qvf.10.1555323974567;
        Mon, 15 Apr 2019 03:26:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555323974; cv=none;
        d=google.com; s=arc-20160816;
        b=T/t+jcBBVUUBD9JcquMQe4A8c4FMwvvPHW4T0ExH6i6cVGavDtyHm2eV6VmNqSsDHK
         PwQ/EGWPTXhoVUMB8m0l1JPUW2+qty6rK7blJiyGPpv0YvDc4i8OZ5f0/8cMoRA/s2eA
         T0jp4iYbxLJNFd+mxoSIqqnieWOtyoBoNxEl0MsRsqq6vkxzNCFZciuBLkG2ox0ZJGB9
         TFQEn337Hujg7vKt35MrXMxosOPWquFQv+CxotiHhB7k5jSALXaXZEXqHJZq2scpAM3d
         9lYYlv/2Fi6dKwbdsVboh4ExA5ejkNU5AF0XqjZZAmYsBMvnSHzyNQBybTfhJOrmh8A8
         Tltw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=/BPNJ5Z0meskioHq9nZpVNtN1OnHlR0EfY4j+0WKJwI=;
        b=sxyJ1Q61O8TnCbBvub2GmDSjdvsLYgdq7g4nIBFhPGkbv3iKFnpvXHSVIsFmfGFkwD
         Vf1GHcONgHCYndi/Ep5Sx0V6l4FBbHppiAYicRCVYLhWXTshnbB22sxwZAyRV8U0NhDg
         +/AaCrzHuu60OtCJp6ywxjvJZ/nr2ykC9vIxUQnd7Zq5teq+1pNhC+Yxn6pxgx0dyoNz
         kQcmT1E9+X476hkMZmz++zU9Rw5rfPYhkP/NrLyfghNbSuvNUbak91xW4WAUTzR8ceJF
         Ww3iYMSA7aG117WAOwHG398sbUO/qOJfVetViycFfspDDBt5bdUnKygglyu9+wWH5OQt
         q3wg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LnCj7QAV;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id k7si14655183qte.258.2019.04.15.03.26.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 03:26:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LnCj7QAV;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3FAEJFu142919;
	Mon, 15 Apr 2019 10:26:06 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=/BPNJ5Z0meskioHq9nZpVNtN1OnHlR0EfY4j+0WKJwI=;
 b=LnCj7QAVeeMEZGQVmEeSgyntjpqoWpolMGyBEUMeSHjlESTL3KxoyiWf3zHLU0lDWkFp
 he0YsF5X+TQqKIpqM6D+V3JxM+jUuYeiGvanTZpiFqSTheXUlYiTrwljpQrJ6YQNFu35
 Jr4GdOSGOmNv6vYDFYYoIlj5ndy4Tx0goTKww2zsxbnB9/N6rFoCpktVKSnLO1HMOhX7
 /Cxy3iutUiny8p3EzSNoBYaQG/tVpwsbAX1PY1Rz0am87VRtCNFGI6/rtZF5BfxZdKaO
 59gIJL8k3bRJ6cHvCVmxNVtdUTh1oAf2Ko182ADs5iPkSB1u2q6MsMSSHrttDUJ+OB0T xg== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2120.oracle.com with ESMTP id 2rusnektxd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 15 Apr 2019 10:26:06 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3FAOS2w132610;
	Mon, 15 Apr 2019 10:26:06 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3020.oracle.com with ESMTP id 2rubq5njva-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 15 Apr 2019 10:26:06 +0000
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3FAQ3Yv006777;
	Mon, 15 Apr 2019 10:26:03 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 15 Apr 2019 03:26:03 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.8\))
Subject: Re: [PATCH v2] hugetlbfs: fix protential null pointer dereference
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <ce422d2b-dd9d-e878-750d-499b9a21c847@oracle.com>
Date: Mon, 15 Apr 2019 04:26:02 -0600
Cc: Michal Hocko <mhocko@kernel.org>, Yufen Yu <yuyufen@huawei.com>,
        linux-mm@kvack.org, kirill.shutemov@linux.intel.com,
        n-horiguchi@ah.jp.nec.com
Content-Transfer-Encoding: 7bit
Message-Id: <C17929E9-6685-4D53-9F9F-1C147D63A95E@oracle.com>
References: <20190411035318.32976-1-yuyufen@huawei.com>
 <20190411081900.GP10383@dhcp22.suse.cz>
 <b3287006-2d80-8ead-ea63-2047fc5ef602@oracle.com>
 <20190411182220.GD10383@dhcp22.suse.cz>
 <ce422d2b-dd9d-e878-750d-499b9a21c847@oracle.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
X-Mailer: Apple Mail (2.3445.104.8)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9227 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904150073
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9227 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904150073
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Apr 11, 2019, at 12:40 PM, Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
> You are right.  That would make more sense.  It has been a while since I
> looked into that code and unfortunately I did not save notes.  I'll do some
> research to come up with an appropriate explanation/comment.

I also like the idea of a comment rather than code here.

Zero run time impact and more importantly it instantly explains to everyone
why this case is different rather than just adding the check for the sake of
uniformity.

