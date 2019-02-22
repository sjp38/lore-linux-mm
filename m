Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7ED11C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 22:22:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3194C20675
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 22:22:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="stvg59CI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3194C20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B850F8E0140; Fri, 22 Feb 2019 17:22:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B31BE8E0137; Fri, 22 Feb 2019 17:22:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A20D68E0140; Fri, 22 Feb 2019 17:22:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 618888E0137
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 17:22:14 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id b4so2579103plb.9
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 14:22:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:to:cc:subject:from:message-id
         :date:user-agent:mime-version:content-language
         :content-transfer-encoding;
        bh=jWIrh7d6XTW5kBiYUt0OQY8AAkCG9FOUyj2Fmvls/G4=;
        b=A+OI70zuf6JCeYdoUe5vGPMhQAOCq38W1Shgow1qJyJvo6fNmGf2NBvdFV6zZaagGp
         A9f69b+k6phw4K4y4eR+4/GylO7gLRVuFBTRNjcwA9tg5Ha0SMlT3BadUCv0aQCQ/MRV
         KleEeid05gZlIocMhQJ2l+1BeSpBhO2sffFO2/wFneMGtMLomnO2nEewPExi+49MMyFf
         7+UTy7EUuqvxz4TfBV0I+DLA6xkxxSXMc1ek1hrtDVgKQUHNb6EtQyGW5VqBeyiHu222
         1W2uVHac189LrqLjWgAIuHC4+QCds3XfWcOIBLqA5F6EbGz/jz95cmDchMmE0t0ODIjD
         XqHw==
X-Gm-Message-State: AHQUAuYi+mgd/KziHGI28WOwpnlWe+kd5VWwsOS6x5/5KjMgw9Og+c4H
	IVgd3moUH5tZnXJxJDWNmb10EOGtvrhU4UiXJ1S+Qm4dXCZLVfwJnuTQcsxe21GANx8w01L4Ed8
	xzKvFgiArJi27Ku5wjLDFkKt6EHze4lo7u7lakQYprtEbZmQP3lUSMPl41V5klVdpwQ==
X-Received: by 2002:a62:503:: with SMTP id 3mr6349651pff.176.1550874134039;
        Fri, 22 Feb 2019 14:22:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYz7RY/DB+rdA6d2/Ao4MQ0UtUzNy38sTepuzsosDRUCdh0LYrQaiANbXQylwFGDwDOd8IC
X-Received: by 2002:a62:503:: with SMTP id 3mr6349581pff.176.1550874133164;
        Fri, 22 Feb 2019 14:22:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550874133; cv=none;
        d=google.com; s=arc-20160816;
        b=SDLz+XEOGrRJvzxK8J8Eb7/h+IZe93yJWbdBaaPgtrsOKgRVu5OVN8QOcLUz34cO2y
         solfbpRXsBIlNlJ6mb6RZD24ttoYT6LbUDG/FEpy1pNm/M6+pX3VBcmsnKIWf3F6TST+
         w3YQz75qI0wvKpHFWS17wGsF2B6vOTlM7d7IgHHLe1HLUDfi7aQcpxybt0d6tTKICJeQ
         z73QvvmHjMLMiUaWTTYrc++DVvbouVaMmtaHWZkPvoBd+D3CLv2iVXI/qn4uTVpuo+dy
         Nb45PgUFmWkDr9z9f3qYoDTOcBS5P6ySYx7yEKT0PoZppGgmEnI5lOlTgorgWRjhwFqw
         TMXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:from:subject:cc:to:dkim-signature;
        bh=jWIrh7d6XTW5kBiYUt0OQY8AAkCG9FOUyj2Fmvls/G4=;
        b=tdZaWY48ECg1nkyHn1G1QRjueem75fWQxBQaEZ/2wfas6EhnysdC4qLn88EkA3O4R1
         dkt6TQ69LeGpeVDnDWOEU63mR5TPFbTcezOPoy1BCYQy0wS021STLOoWFx5Y6Nof3QhZ
         97ecnh/2WytR+mKLzjr4XPEL5bWFJlfvfNBBypoF2yF94b0ZL0y9RQbG/akZiF0/QSXi
         qVdSwfvNX40wChi3Jfo42cEGR2Jc1d5AmYaCjruJY9G9Gc1Nv8cfuaO3+QkggWAWRXwf
         AbyFHiQfS0WsDbmBB6PY29MRavB3C6U9zLYzvmdasCBx0cSoK2V+sjbHe7m/RjPsTXQz
         tt6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=stvg59CI;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id v6si2193962pgs.206.2019.02.22.14.22.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 14:22:13 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=stvg59CI;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1MMIu7V034884;
	Fri, 22 Feb 2019 22:22:12 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=to : cc : subject :
 from : message-id : date : mime-version : content-type :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=jWIrh7d6XTW5kBiYUt0OQY8AAkCG9FOUyj2Fmvls/G4=;
 b=stvg59CIySH0kDi5xBfpge9/iru/QixBmmfu81NoP13bszB6GzQYKvzDPX4LdWupANZ1
 oVAopGDzicyKtY8XXv28CYNdULvu3ppNDD5HOzMPrb3XIeDGG2J5rr+fgBJ7FmvVYzJR
 bbDU0bVnNXGvhy6srbxpGJiW9/FekIvKp6WcN1xn6hXkQDJe8ttlIFl7p3KnMoIeTRqe
 dsUPPeVliAJHx0WjvCFG9MK98zb7iCZql8vnX4+ksaZpPLQQxuUSEU8xTsxDDQm1lQje
 qy3qV+a55KBHnCqFGTNJPyXw01r3oU1IvD+Lzv69XsqZ09sf5h+hoDSol3oLB5B08CFe yg== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2130.oracle.com with ESMTP id 2qp9xuhtg0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 22 Feb 2019 22:22:12 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1MMMCG6028916
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 22 Feb 2019 22:22:12 GMT
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1MMMBdu030372;
	Fri, 22 Feb 2019 22:22:11 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 22 Feb 2019 14:22:11 -0800
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: [LSF/MM ATTEND] MM track: contig allocation, thp numa, userfaultfd
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <a47b26e8-0048-e360-1f69-a296acf222f5@oracle.com>
Date: Fri, 22 Feb 2019 14:22:03 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9175 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=502 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902220153
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000282, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If there is space available, I would like to attend the MM track of LSF/MM
this year.  This is a somewhat lame request as I have not proposed a topic,
and my mm contributions this past year have been somewhat limited to finding
and fixing bugs hugetlbfs.

Topics in which I am interested and could contribute:
- Contiguous memory allocation.  This seems to be an ongoing feature
  request.  John Hubbard wants a reliable and efficient method to
  obtain provide huge pages.  Zi Yan has put out a bunch of code to
  support an alternate approach.
- THP and huge pages in general.
  - Specific interest in Andrea's NUMA remote THP vs NUMA local non-THP
    under MADV_HUGEPAGE proposal.
- Userfaultfd and Peter Xu approach to write protect support.

-- 
Mike Kravetz

