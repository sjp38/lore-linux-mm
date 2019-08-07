Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AD24C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 16:13:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFD842229C
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 16:13:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ytvRKMU4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFD842229C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59DA06B0007; Wed,  7 Aug 2019 12:13:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 552CE6B0008; Wed,  7 Aug 2019 12:13:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 43DCA6B000A; Wed,  7 Aug 2019 12:13:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1959E6B0007
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 12:13:05 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id t20so48573096otk.7
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 09:13:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=ZAW+qcuaCE1QOFrpMarNcFKwi4miSTEyYBSJ1Z1pMMo=;
        b=ak/p3ta1Lt3GDP2fEL6too3oviERzKrd/73ztxPEja4fXRNrYIRM2OMg+/aMWDtkBZ
         3G1z5vZRUhlBbmDkFtLuSeLyi0tYHw5F5jVDScAmFpuWYkDWuC9SP2D4AumttlpczafO
         bzXap/Kjl0ug3yz5qLLXDYg/BIIa+EWzqPLb8v/2sBSV2WpaY3M8pbbwOAkZVfgaLX0K
         VoqTSOMgcBg7ZrAINNLd9OUR+4TT7eyKcbFOrImLLoIVatRmjPL9kKMKVRq3cNKnxGUp
         x/lAWlLp1LpQNy5PftNlANGm4qZtYsPEU1WZv7d1dzYLNy59ddHiqga1FR6e2V5OWGTM
         RG/w==
X-Gm-Message-State: APjAAAWWRPSCHIuV2Ox3+/fLHQpaB00HQqu+vtaSSSr4dg8g4BojfzT6
	M9Kor032H6hMqdfihK2/aG7Q/CH2Vu7yLvUePhHWPIJi1JCsA6Rr5U1oyW0qxmKgJEmzdv5RwTc
	1wRgCOfFlKOT2BqFAdt5DmL4sGYagQfO/T9MZzKl4zQzH80aJGij+y5XEZRlsJpPYEg==
X-Received: by 2002:a02:c6a9:: with SMTP id o9mr11289823jan.90.1565194383239;
        Wed, 07 Aug 2019 09:13:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLePmeTE4fwGwMOgxGL4volfxw5uQUh6xFqisynJJJPZTck+ZioNV29wdnBAlSge/Zp1wD
X-Received: by 2002:a02:c6a9:: with SMTP id o9mr11289704jan.90.1565194382082;
        Wed, 07 Aug 2019 09:13:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565194382; cv=none;
        d=google.com; s=arc-20160816;
        b=CG7MzEuLqrDCsuo0L0g+71eeHfzphvL1iJJlBk3+u926AzdCnxsvgArvUgv8gEUn5J
         wJgRBNDCOsq32L6cXaORK+/uftdzNVXm8OHDHbwfKfXkyv0w4zH6sGri11UPn+6NgnYD
         drh0opu7XHYSbNGGbjrSU0eHZ5pF11bgRZSVsce2f1WSwETeCAvZOtyNFfEj5gu6BNvX
         oAHcDnTYYJaKQwSDQuKxZ30FH6QgnVo0l1t8j+68cyccDHOqXNLwBibbn7Y0FpvVQ4S+
         2Hc67U4NZFO7N/0VBNjppjqzEaw8HCXwk/JyQyPIn+igElvFl6bsnp9eVQyMfMvuQdcw
         ePJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=ZAW+qcuaCE1QOFrpMarNcFKwi4miSTEyYBSJ1Z1pMMo=;
        b=g5n2ceHW2iNCKH4ByTs3jPjvg6PuV779rzZSwLnIR9q4QFX4JNv9JR40zTINxEcmIP
         jPE5vJ0SV4W+ZR1VHcVsgIZEaHErenoa6lu/Tj/3A455k6CtTk1oczEB5bgpJddymBae
         qj5RAw2keaXqvRmjPzw4iEQNR+dXivcqb5helmtMRtpfO7c2kHFNiTJQivuLPnSkg13x
         lddPbhfvehNIRsUXEIH85e8EJb4hyws5lGdgdiHSqGT26FBAI7I0Aa7W32aJwMqPWUxN
         64xMwZjCgp6JgiCqk1UnI+PjbyKYbPF37hyoPMhwVBioaIoOEYYGWWyDGkaFBnQNby4g
         YgwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ytvRKMU4;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id d71si111251179jab.10.2019.08.07.09.13.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 09:13:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ytvRKMU4;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x77GBRYs022104;
	Wed, 7 Aug 2019 16:12:47 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=ZAW+qcuaCE1QOFrpMarNcFKwi4miSTEyYBSJ1Z1pMMo=;
 b=ytvRKMU4JrdLH+P2Qpr5e/GAf+QNJfpkol+hG4wyPdle5/EBnL2xO8+zS1R9VJErqz4a
 jwu3KuyWqAMyWFsaFmq4Ym0e642N/SrYSnnEjSUbVxuQvXfnU/IImCp4LPu6bqRZwACz
 mggOyJY34FIVI8XFRUdAKqr821vlRndnF+nKSQNLSknXLnovBqzxvuGGur6yTHFrVPvQ
 bhx/V9SFnQYtxN/VOl7i2f1Yz5iT9bAaZLuckIxJat7FIBfZP1vRD6Wo4auTOLuw5vAB
 BQrnqUJVM5fCVGRsgN2AVya8QenCb0819QeuBoOmxK9/SEYDViKivoH/kKvJGPG/MvOo eg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2u52wrdbth-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 07 Aug 2019 16:12:46 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x77G3KaH158235;
	Wed, 7 Aug 2019 16:12:46 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3020.oracle.com with ESMTP id 2u7578384q-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 07 Aug 2019 16:12:46 +0000
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x77GCgiY023566;
	Wed, 7 Aug 2019 16:12:42 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 07 Aug 2019 09:12:42 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 13.0 \(3570.1\))
Subject: Re: [PATCH v3 2/2] mm,thp: Add experimental config option
 RO_EXEC_FILEMAP_HUGE_FAULT_THP
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190806111210.7xpmjsd4hq54vuml@box>
Date: Wed, 7 Aug 2019 10:12:35 -0600
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Song Liu <songliubraving@fb.com>,
        Bob Kasten <robert.a.kasten@intel.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        Chad Mynhier <chad.mynhier@oracle.com>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Johannes Weiner <jweiner@fb.com>, Matthew Wilcox <willy@infradead.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <452E819C-894D-40C5-B680-CC5A02C599AA@oracle.com>
References: <20190731082513.16957-1-william.kucharski@oracle.com>
 <20190731082513.16957-3-william.kucharski@oracle.com>
 <20190801123658.enpchkjkqt7cdkue@box>
 <c8d02a3b-e1ad-2b95-ce15-13d3ed4cca87@oracle.com>
 <20190805132854.5dnqkfaajmstpelm@box.shutemov.name>
 <19A86A16-B440-4B73-98FE-922A09484DFD@oracle.com>
 <20190806111210.7xpmjsd4hq54vuml@box>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Mailer: Apple Mail (2.3570.1)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9342 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908070163
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9342 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908070163
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Aug 6, 2019, at 5:12 AM, Kirill A. Shutemov <kirill@shutemov.name> =
wrote:
>=20
> IIUC, you are missing ->vm_pgoff from the picture. The newly allocated
> page must land into page cache aligned on HPAGE_PMD_NR boundary. In =
other
> word you cannout have huge page with ->index, let say, 1.
>=20
> VMA is only suitable for at least one file-THP page if:
>=20
> - (vma->vm_start >> PAGE_SHIFT) % (HPAGE_PMD_NR - 1) is equal to
>    vma->vm_pgoff % (HPAGE_PMD_NR - 1)
>=20
>    This guarantees right alignment in the backing page cache.
>=20
> - *and* vma->vm_end - round_up(vma->vm_start, HPAGE_PMD_SIZE) is equal =
or
>   greater than HPAGE_PMD_SIZE.
>=20
> Does it make sense?

It makes sense, but what I am thinking was say a vma->vm_start of =
0x1ff000
and vma->vm_end of 0x400000.

Assuming x86, that can be mapped with a PAGESIZE page at 0x1ff000 then a
PMD page mapping 0x200000 - 0x400000.

That doesn't mean a vma IS or COULD ever be configured that way, so you =
are
correct with your comment, and I will change my check accordingly.

>> In the current code, it's assumed it is not exposed, because a single =
read
>> of a large page that does no readahead before the page is inserted =
into the
>> cache means there are no external users of the page.
>=20
> You've exposed the page to the filesystem once you call ->readpage().
> It *may* track the page somehow after the call.

OK, thanks again.

I'll try to have a V4 available with these changes soon.


