Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A77CC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:38:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27922206BB
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:38:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="K8L1rSpe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27922206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEF478E0125; Mon, 11 Feb 2019 21:38:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9FC88E0115; Mon, 11 Feb 2019 21:38:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B5448E0125; Mon, 11 Feb 2019 21:38:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6B2238E0115
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 21:38:06 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id x64so769989ywc.6
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:38:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=O/QX/FWn39V0uFALG2Z67rFs8z8//8DxM3sY6IGq6S0=;
        b=Csbc0Ez+PXpjXH/8hV7cnk2/F+/tHpPef75Pjh34Mk//6J/EILZeMmQliC2bmbwgXX
         LT3ynBwIO7U2sFbcufTkKwzQjwvpPCJ8H5/ghpBDSpmDE5iy9RjJSyyKEJmOl1HYM+Q1
         Mv4I2d0thBti42qboDAlEhSBB+MvUnEfXBjmocdaeeBRpVeijuCatKX/7fAPJf8wB4+h
         TnUdSfShmBxPjJVh1TXIsIXvfA9Y7qkt6irx1W27e8UXu/JVkdOWWeZpCVw7ByXAa3Z/
         OnnHyjw2k2xciGitveLCDG87t38gRE7JUQpFUd8e5e+8VHqx+OLuIp45WlSCIP0YEjry
         HuMA==
X-Gm-Message-State: AHQUAua+TH483PqWIo7ctHC7s8p3pE/b+CbZgE72aExnhTDHho0Eh6la
	voedIwHKAfHsW4ekK3kzAbbE4mbyue613F8vAZKayXo/lac/Aela7HdAGfwV7AE+EBcBJnMKj/5
	timrNtmp8pk36AEnIvjtMOQzKHMR3fKfpFhWkuG+hrjX3HpxPc5gYLx33CHvBS29XEQ==
X-Received: by 2002:a81:4b02:: with SMTP id y2mr1045662ywa.447.1549939086068;
        Mon, 11 Feb 2019 18:38:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbF6WT4Y2tovncdfnDSW4SZvZvjknon5GObYxrlFozE6Q3TQ4iTrX+49iKSV4lo6p0Nt0rE
X-Received: by 2002:a81:4b02:: with SMTP id y2mr1045630ywa.447.1549939085355;
        Mon, 11 Feb 2019 18:38:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549939085; cv=none;
        d=google.com; s=arc-20160816;
        b=jCpVQhl2efPbWRcR5ZLNbWqyuhKgycXSYCVoprYF6+JQy10Fznf8+orb/jV2pedwQr
         2pbcrpVXdtv9H2m6g6Tk7of0A1qgE+BCKcONkyZI21Grg+ZDpMjVCVH1V+YM3aS0bTlI
         2wQz1U6co0+9UC/EgBKwVfrg7MTLsX5wQMNbRZynxM31jT68g0MdbL9awFxMofshqRU5
         HiNLq0nOGYtkodhN8jsx8HmgQLtb/F1VzCC2BLLQ8IW8V+FM8NUl7qlVT7xPUQBDqE4u
         QDsRK/kr/Vn9OEg5Yr5T4xdaJAp6gJPQucYon2WwqWXXZQc/X6zJ19lXalBCsOZeW236
         EOTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=O/QX/FWn39V0uFALG2Z67rFs8z8//8DxM3sY6IGq6S0=;
        b=X/OSIw2WDUol+bC3bf2I09lvAPsd8/FBLpO/71xPOOKQKRpkE0MK8apENTQd4PWloA
         ToWroc4xEcY5fzjp3bKQdiG+OugiLjyeO8xuZ5ruqklXE3KizkjjB+CotpRS7mptmY2F
         ACi2uGzGYw/hf5/yCMn4eLkSDgpcWTNKld8Yv/74ec8ytX03AnOwjYVYEGeYZ+xG9zZC
         CI0R7uvTmxGp7ApEvgEVM09gx6URZlaOoFRM2HKWSgRdAGzWLeDMLyoLqnBxfW1C2yEZ
         IwKSoEGnmZNhKlh2yZAAw5tXhzVdd8EK3hsecbtfLJDG2THvLBBIw0L1ZNT8odIcFl7g
         5BCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=K8L1rSpe;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id u1si7349078ywd.433.2019.02.11.18.38.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 18:38:05 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=K8L1rSpe;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1C2YOmK037020;
	Tue, 12 Feb 2019 02:38:00 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=O/QX/FWn39V0uFALG2Z67rFs8z8//8DxM3sY6IGq6S0=;
 b=K8L1rSpeXRxDKVnaoJkMwbp7BHbh75nLa/9MGsWyHyTHGzPejOqu7jXzwqFflUbEScku
 2rYCXN/KEvdAsibQReRg02IZ5twnORZH1XytvHQUsFHxkc5M1MjdzF/9/3Kryt8x8jS6
 nV+aL9ov1ItqWJyfH148ubCJG3RjxGj9A6DPCsdPXOZnPMN89RtgM7uoPxfE04IgRlFm
 FwVxqyNIQLybyMUEkrRQ7RXzrCwhknxvorJ+rjscC/1YghZRbwBxnJ3PRXN5r6n2cqIh
 /vDO4v8+utWqYiT3AZmUDZMZviQ8tYDeeMIEvymcx6JkO3uJy7ik2Yma1JTrb1ARW1jp GQ== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2130.oracle.com with ESMTP id 2qhrek9b2y-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Feb 2019 02:38:00 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1C2c046023466
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Feb 2019 02:38:00 GMT
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1C2bw4d021554;
	Tue, 12 Feb 2019 02:37:59 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 11 Feb 2019 18:37:58 -0800
Subject: Re: [PATCH] huegtlbfs: fix page leak during migration of file pages
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Michal Hocko <mhocko@kernel.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Davidlohr Bueso
 <dave@stgolabs.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
References: <20190130211443.16678-1-mike.kravetz@oracle.com>
 <917e7673-051b-e475-8711-ed012cff4c44@oracle.com>
 <20190208023132.GA25778@hori1.linux.bs1.fc.nec.co.jp>
 <07ce373a-d9ea-f3d3-35cc-5bc181901caf@oracle.com>
 <20190208073149.GA14423@hori1.linux.bs1.fc.nec.co.jp>
 <ffe58925-a301-6791-44d5-e3bec7f9ebf3@oracle.com>
 <20190212022428.GA12369@hori1.linux.bs1.fc.nec.co.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <803d2349-8911-0b47-bc5b-4f2c6cc3f928@oracle.com>
Date: Mon, 11 Feb 2019 18:37:57 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190212022428.GA12369@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9164 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=861 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902120017
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/11/19 6:24 PM, Naoya Horiguchi wrote:
> On Mon, Feb 11, 2019 at 03:06:27PM -0800, Mike Kravetz wrote:
>> While looking at this, I think there is another issue.  When a hugetlb
>> page is migrated, we do not migrate the 'page_huge_active' state of the
>> page.  That should be moved as the page is migrated.  Correct?
> 
> Yes, and I think that putback_active_hugepage(new_hpage) at the last step
> of migration sequence handles the copying of 'page_huge_active' state.
> 

Thanks!  I missed the putback_active_hugepage that takes care of making
the target migration page active.

-- 
Mike Kravetz

