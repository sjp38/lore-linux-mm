Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A7F6C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 13:09:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48BF42184D
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 13:09:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="NoAQCMKe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48BF42184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7F0F6B0003; Wed, 20 Mar 2019 09:09:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2D116B0006; Wed, 20 Mar 2019 09:09:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1CEF6B0007; Wed, 20 Mar 2019 09:09:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 79B676B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 09:09:05 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id q192so2191361itb.9
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 06:09:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=JSDYeuShhyDCH3/IuB6WC/bUZLns4NrINdoZHf0IE2o=;
        b=kZwcdkGgY2GnWD/6uNNr4iGjtgJRORjXgq42uxvP+oMc1tbls51UbsWfxVKjhz9tyg
         ff0mnFiQSrFN/K1qo27XURICrrC53B6hr7wSRS9iIJhV+0++xlhSvcrYgxsb6Shl+kmB
         OlY1AM57dLxFAmZ3ULa7BgzvWyNd6uG3+XpuO1SZflThficxrtV73KiaRc7/acXwzAoi
         M/3tnB8YE+v3NCXVz9EIQvsAVmHgM6PdOuel2McLMkLGwlOKiGtqMJikrzMYaEmjGPF4
         32OR4/xivVq6+IKc1ysYBoMDwylj44BgtRz+WclCcykKvymWnFZIZf9jP5f8ZvxnjqcD
         rpvg==
X-Gm-Message-State: APjAAAWM8praZFiZk8jCJBNEWmEdo5Wz/cWva9+1zelMo03SshPBsJBf
	ZzeOnIjZ8d1+kwksJ1+7lcpjj4xuZu1vgmsWmHiwtD8ctsurJd0gE1jeeweNEILATRj/sxssVkR
	bwLR2mxCRob3imrL26fgA6jflMi7r4XHyOZrs3Hagt/Yx2ixuNLZ/B1TYV+tBl5WIvw==
X-Received: by 2002:a6b:8b50:: with SMTP id n77mr4845449iod.222.1553087345300;
        Wed, 20 Mar 2019 06:09:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwmRUuYvnVDw6iHeKYwweedsYseG1TMtJSSSo4cuI4C2Q2PbWgpg0vf6mW/xVsNv4mjyk5Z
X-Received: by 2002:a6b:8b50:: with SMTP id n77mr4845389iod.222.1553087344640;
        Wed, 20 Mar 2019 06:09:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553087344; cv=none;
        d=google.com; s=arc-20160816;
        b=DxinTy257wn3O09bOPYFbrGOnjA6dX/jNCZU4foEoQ0EawXRqHjUtqChC9LDY3C6sk
         bw3eut5gsU5ww6IG2DkXDT4MH1NZ35v0rLeO+AqpechFZznEf59XLPfRN8UN0G4AAXW1
         Co4KHAqVYNND/98jxwDNOoqxt0/ehgry+Ap0RXJrXTZ8drjfFRaf7fXDakn7Iojf3gV0
         o7edUNJVB7gQ7MzWsoIw/fv5d6kyedAyIuDihWmqEHoLcPfDuVB/KbOwkP0KUj8ACxZH
         sO4pmamtM2qCYILAg8GntBD4ccUTjMYAzrvh/dMMfjpij1S9MtUDR25gVeyEouL48CKG
         iI7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=JSDYeuShhyDCH3/IuB6WC/bUZLns4NrINdoZHf0IE2o=;
        b=R108Lp5YVg88bQGjfHuhkLVtWt85aTiaWNMXfKTUzdD+q8ZZPKc5jM6ZE7Crbjs3+e
         t+QLI44Jswu4mL4ajuqE3WRyHs9EeSp8mwjR5WAMI3nwFehpV9lsekVoTyUm9Ysgy+n9
         rRZ45Pro2/8LjwNf917Nnru7SeOfijjEljOU5KtKXDrJnjkG+zeN7TKm6Rkw8NAmpPJT
         P4sHrv0VeyVoN8mYnqHuGfdJeB6N5+afpjqyo1++5xcoMB31lJlaLw128lb7sZ3+ijhE
         MtvXlEuZA3nSl9j5Sx3naSIVzVwacsrE3PmSQv7c3Mh8mj2mYuz6rTy4ZXsg3Xw8a0kU
         JRdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=NoAQCMKe;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id c5si211203itl.126.2019.03.20.06.09.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 06:09:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=NoAQCMKe;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2KD8dPT163086;
	Wed, 20 Mar 2019 13:08:54 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=JSDYeuShhyDCH3/IuB6WC/bUZLns4NrINdoZHf0IE2o=;
 b=NoAQCMKe1JkYPK9+nU7u+HbxJkkB6fTwuoUH63LKXpOsfU3yMew4RZyZIr9jJcOc/8Ln
 ETgLhUuV4M1PJyesClN9VIt5QUD18yxPcWfkyw2BhgPYt9Hsbb6GNY6kbLNK7zGuLCTA
 cQWpn7M/4M76ycNR1MeCtiI9Vj6D+voBfU8sTxBDwwImckKXXOqaAZofW7E0uVJHf0eT
 9Ne6pN9/eCL5o1ixalen61+4IuBEfz8F4pXr6Vgrf4HxGfvrwqhcDT6BM5ofQqjaGwQl
 78iXo73IDP/TYd4PWdRv9k6Mz09Xh9++p2J5JLrV7NbLLgISX0ibzCBXVrryY3fEyGb4 rw== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2r8ssrjgfe-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Mar 2019 13:08:54 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x2KD8q2a007698
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Mar 2019 13:08:53 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x2KD8qtd027902;
	Wed, 20 Mar 2019 13:08:52 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 20 Mar 2019 06:08:52 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.8\))
Subject: Re: [PATCH] list.h: fix list_is_first() kernel-doc
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <ddce8b80-9a8a-d52d-3546-87b2211c089a@infradead.org>
Date: Wed, 20 Mar 2019 07:08:51 -0600
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
        "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mel Gorman <mgorman@techsingularity.net>
Content-Transfer-Encoding: quoted-printable
Message-Id: <6B02177E-55BC-47F2-8374-FBCAC25134C5@oracle.com>
References: <ddce8b80-9a8a-d52d-3546-87b2211c089a@infradead.org>
To: Randy Dunlap <rdunlap@infradead.org>
X-Mailer: Apple Mail (2.3445.104.8)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9200 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=961 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903200102
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Mar 17, 2019, at 6:16 PM, Randy Dunlap <rdunlap@infradead.org> =
wrote:
>=20
> From: Randy Dunlap <rdunlap@infradead.org>
>=20
> Fix typo of kernel-doc parameter notation (there should be
> no space between '@' and the parameter name).
>=20
> Also fixes bogus kernel-doc notation output formatting.
>=20
> Fixes: 70b44595eafe9 ("mm, compaction: use free lists to quickly =
locate a migration source")
>=20
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> ---

Nice little cleanup.

Reviewed-by: William Kucharski <william.kucharski@oracle.com>

