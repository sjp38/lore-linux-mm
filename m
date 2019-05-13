Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 164C3C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:18:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C891F2133F
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:18:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="s+iOIvIz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C891F2133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5201A6B027F; Mon, 13 May 2019 11:18:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D0826B0280; Mon, 13 May 2019 11:18:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BF446B0281; Mon, 13 May 2019 11:18:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D7836B027F
	for <linux-mm@kvack.org>; Mon, 13 May 2019 11:18:13 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id u131so4746346itc.1
        for <linux-mm@kvack.org>; Mon, 13 May 2019 08:18:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=7dwMUJzRttDvJYwhnTS2pvQini1VnZvpMgmhpc63TNI=;
        b=UQKzE4xUaUoioae7RRFM+7qBZ8TctVoewKvl1Nc30FeqlY02Jv0BvX+XUhj0NZ2J9f
         egf88cjOvDrv7GgOHefod+xSoj3ZgZNoj05agzhoGE0hKXw8eyaFnp/zuKQRyOxar4T0
         VrOAHuEHbQdAJrKIYqZ5ziJzJXmlbqBh+HDKbrlfodLm5QwBYROK9rIQKqrIBD48H6qj
         eokFw9WeHlMVK7WOJwZIw7vQff46eZH2keZihfsmKuUmIJauUiG7KM6nyq5GdcANT/QP
         wZo6kIaJzWaY6L8RNz6XdYsoXo4HtjZp/SI0+P2UMWtM6thXiLjt7LfpWYb8wHJCnter
         UnqA==
X-Gm-Message-State: APjAAAXpwN7NmdwwJQAk8yW7HeYHmVR8QkqFA9fCSeyTI1XReWR0aBO4
	05eLNyooXz928Eyg4K+ZftPl3mwNRGH5fR3nP4N2mjATMOJ/gsB+qh1wHm9lC60moeuswuvszyN
	xnWYe/xD2P7mmVifkSuAGV6MCx+caJtEF+ASoh+a0gKb4l8X/Xa7+x0p8x2OsC8gWWg==
X-Received: by 2002:a02:c90a:: with SMTP id t10mr18179494jao.68.1557760692882;
        Mon, 13 May 2019 08:18:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKLjYwTGs+xX/EsXxnBrcIgG0QRp5OZ9PN4naZ3MS3Y5IzCbWz47lbW1ZBL7L10Ed//y57
X-Received: by 2002:a02:c90a:: with SMTP id t10mr18179465jao.68.1557760692328;
        Mon, 13 May 2019 08:18:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557760692; cv=none;
        d=google.com; s=arc-20160816;
        b=tID2Z40EGilb3+cMLIMC/sUzeceE+iFjFLT7Cjpz4DOCp3X18JCKtekq/hEU+u1PEM
         FG45BHc6QzIIpRlZPw0d/FmqBXfIdbMSX+iqI0soYr0h27pDHOxxpKG0ZBhTdVCrkM81
         fb44LRB28/lSP82q7GB2jzpy5UJlZ1PCqUi4A2SRjSYYAqI69bC1ykcpvetRuchcpAad
         tYTaPRxBBErzRaSv0TbZM6lXUrfrtfrhbZCF4TR2NPh1HEYr3ipQUEHE4pwYdH8qQNj1
         qB4vuzCmdbhrtG7/70xLjWYijgxXYT19w0CtvbaQwVWZL+Jcvzbjv6Awkw+6g+ktcrzG
         SWvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=7dwMUJzRttDvJYwhnTS2pvQini1VnZvpMgmhpc63TNI=;
        b=GOn/1D2sJ6sMOftxzESthfJtjGQrKVStKKcgNhKyV3FewfEl3sR6zFNpEKvhVfC8j9
         AkrgNEGZ4DTzAoEoyo9mbsT/khMxXFYNPHwwdgOvJ7/i/3riPAMISrCKGwfrxbUh/tvH
         k4PdHYiKTgrWqXb9Ku02WHZzwlnTX4pJy6N5wf/YXExpN9mENpznMZSM01haELV3F/wE
         grUyD2BKxw0L85wEkAPZCcl97LuD4he5cQpRJW6M8FH6mJ9N2eQVCCVEPIOr9MJcAGGD
         my8C49Fww5rsvM1mi6wBD2jwJWd+BnIuy2tY3yCq8Q+Sf6bpu5WWpKHluS3UQst/pPoa
         2/CA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=s+iOIvIz;
       spf=pass (google.com: domain of liran.alon@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=liran.alon@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id t9si8689398itj.76.2019.05.13.08.18.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 08:18:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of liran.alon@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=s+iOIvIz;
       spf=pass (google.com: domain of liran.alon@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=liran.alon@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DF9oxF029760;
	Mon, 13 May 2019 15:17:54 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=7dwMUJzRttDvJYwhnTS2pvQini1VnZvpMgmhpc63TNI=;
 b=s+iOIvIzPv8p+qdn5Lp87nwsGe8piEJpWQ3OZW90Gqa7nfhqwc5jki1ocfhV8tfSYzyW
 ERQWmQkk0Drp6M39yqnyF2g5hWg8ckFsDEpZVMimRtrkJrFmN42X06Mw0JuVxtOyFXFQ
 ZM3y1OBAffh3lZwD1UORvYQyqw2FVoBLsR/ICZWoOVz30V9X8ZVIhod3gTSiGDDdcVAE
 BIDNG0vWG0mrq+wPCV1tkOBE/AwOEA2iQNd9Wj0ltYBVmaSz96NorsvT640eIhHYb7gR
 dKR2h7IcfhTPGL9nD1ygG8RWeV0LY/JCpb8KY+qu5uHfxDcfChNM5u9rLq4YgfLdHDAE yw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2120.oracle.com with ESMTP id 2sdq1q7m9k-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 15:17:53 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DFHYQU140196;
	Mon, 13 May 2019 15:17:53 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3020.oracle.com with ESMTP id 2sdnqj1a07-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 15:17:53 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4DFHo3J020928;
	Mon, 13 May 2019 15:17:50 GMT
Received: from [10.30.3.22] (/213.57.127.2)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 13 May 2019 08:17:49 -0700
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.1 \(3445.4.7\))
Subject: Re: [RFC KVM 01/27] kernel: Export memory-management symbols required
 for KVM address space isolation
From: Liran Alon <liran.alon@oracle.com>
In-Reply-To: <20190513151550.GZ2589@hirez.programming.kicks-ass.net>
Date: Mon, 13 May 2019 18:17:42 +0300
Cc: Alexandre Chartre <alexandre.chartre@oracle.com>, pbonzini@redhat.com,
        rkrcmar@redhat.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de,
        hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, konrad.wilk@oracle.com,
        jan.setjeeilers@oracle.com, jwadams@google.com
Content-Transfer-Encoding: quoted-printable
Message-Id: <6CAE8F45-E2C0-453F-B2C8-12D9BBE6B8D7@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-2-git-send-email-alexandre.chartre@oracle.com>
 <20190513151550.GZ2589@hirez.programming.kicks-ass.net>
To: Peter Zijlstra <peterz@infradead.org>
X-Mailer: Apple Mail (2.3445.4.7)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9255 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905130105
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9255 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130105
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On 13 May 2019, at 18:15, Peter Zijlstra <peterz@infradead.org> wrote:
>=20
> On Mon, May 13, 2019 at 04:38:09PM +0200, Alexandre Chartre wrote:
>> From: Liran Alon <liran.alon@oracle.com>
>>=20
>> Export symbols needed to create, manage, populate and switch
>> a mm from a kernel module (kvm in this case).
>>=20
>> This is a hacky way for now to start.
>> This should be changed to some suitable memory-management API.
>=20
> This should not be exported at all, ever, end of story.
>=20
> Modules do not get to play with address spaces like that.

I agree=E2=80=A6 No doubt about that. This should never be merged like =
this.
It=E2=80=99s just to have an initial PoC of the concept so we can:
1) Messure performance impact of concept.
2) Get feedback on appropriate design and APIs from community.

-Liran

