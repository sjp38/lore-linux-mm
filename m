Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E41BC4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 16:15:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6CDB520866
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 16:15:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CDB520866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D12E36B0008; Tue, 11 Jun 2019 12:15:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC3096B000A; Tue, 11 Jun 2019 12:15:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BDA0F6B000C; Tue, 11 Jun 2019 12:15:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A41E6B0008
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 12:15:45 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id f10so4449462plr.17
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 09:15:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=Fjx5Evpq6NDo6oeZpzA/p50Z6tbO54kkcvQ/Z7oL3fY=;
        b=iJ65u6xVrqeTwU7piUOPhNdeK+O4K9czmtSko8oMnNP+317Sq4BDFBy83MqjMQzk1u
         EGenLomT2H+ScLRHNAMRi6dj3ZgH3zmsG+ltXSvwaoldwKs0kPDlvpHB36DdYyZrnOXA
         DAXg6Z4FU6CSrKg/YyuMEdDNbJouQKkP8ZHCTDRp3qxINhWovfPTRB5r23yP6IhcToq1
         QKxxGFnUA2vG8rM9QwK6uDmBpqqB4MTNxu2t2+lM/nXsS9hKfH3nEBxBJqz+1+Q/KX/M
         7PwYEkiIHSLOfaHT4xE/RUd869nn23SSIREP4BCNsQ+SCLiatxfWriUKZ2Ce6Q3VZQsL
         7DGg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUxd277Gska07z7NgWeaWp/Dmxz+YoZ0F2E0FLKmmiDkx3HgprZ
	hfEkvG50y8ZS2hdtM/FIPTDQ06ULZsq+v/eVWgQQ9UthM92iyToFOaozNdlGa/q47uu2R7dWwuP
	1EqqEPRZr4lujlVrPtDkmZxGok7vtQA75qg1qvE+GejQ97k7M+EvzGypICyX0uK5kbg==
X-Received: by 2002:a63:d551:: with SMTP id v17mr10508341pgi.365.1560269745133;
        Tue, 11 Jun 2019 09:15:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDbB+X5cvLyJBeaEbSmKp6EzR3O9l19hocRQVRj3n47RAnQF3zFN2ZxhfmLD8W082akros
X-Received: by 2002:a63:d551:: with SMTP id v17mr10508293pgi.365.1560269744341;
        Tue, 11 Jun 2019 09:15:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560269744; cv=none;
        d=google.com; s=arc-20160816;
        b=jHfTDbW+A8xGJKoXR6NokRgF5DfcWa3U/xSFnRIhMH7B0NG3MzFHkSuSSPf8KBMWYB
         1uGhNFNODUq72xprT5RADA5mUfhHGGAnymqdobsrkCsY+mFIDJ9x9HhI4Ol//66rN7ya
         ZvfK6wHf+9W8GnZeF32bSMUKBhDg7rqNJPudXA9jYgzqfh/f5MYsXsT3kfwb5WPt8Hbc
         aWEmQMbxHMx9IEU7ZT7U7BmaDdQxL/Auq0rvbgBYIv7L8ph0j0TDiD1vyOl0mJJom54G
         wQ65B4/DYCUx6jnpgvhBkpCNuiVkV83hoONCM1c7qI+JGSvTv75676k1JoJZZ4lVZW/R
         3/Gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=Fjx5Evpq6NDo6oeZpzA/p50Z6tbO54kkcvQ/Z7oL3fY=;
        b=jIsXj28VaMaUQLLi1Z5gSOWOwXHkfGUgO9TCGtYZsyCsKHHgaqrEF4LIOkYLxsKVc3
         VeV5dkg9hY7r2Y3tS2mtrc0QNepI5WCZzWg7WLg9i/GgIyti5yyumAVjlFPoE/e3sY9F
         /JOtc/PFjY1BxkYgkisObee3tPIdDXkFQPyHoWgWn9uuLvB0NBJByf3i8n7LKJgCe6HH
         nKoR/8J8vgRid2dtQAkhNBV06BLbBeygvE3v00xDVYY9F7iA0FzM0wKjj1YlTTPreK6f
         pG7rd0cs9NPBf+PDgeXRLIr9axUHQFtUUzVUIOr1Zy7vpeo/62vXYsaAC7TYAgy3JIRf
         cz4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p19si9051848plr.286.2019.06.11.09.15.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 09:15:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5BGBTEX120235
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 12:15:43 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t2eug2vp5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 12:15:43 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 11 Jun 2019 17:15:40 +0100
Received: from b06avi18878370.portsmouth.uk.ibm.com (9.149.26.194)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 11 Jun 2019 17:15:37 +0100
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06avi18878370.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5BGFaNx24576476
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 16:15:36 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0E08C42052;
	Tue, 11 Jun 2019 16:15:36 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id BE0C842045;
	Tue, 11 Jun 2019 16:15:33 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.85.73.114])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 11 Jun 2019 16:15:33 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Pingfan Liu <kernelfans@gmail.com>, linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Ira Weiny <ira.weiny@intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Rapoport <rppt@linux.ibm.com>,
        Dan Williams <dan.j.williams@intel.com>,
        Matthew Wilcox <willy@infradead.org>,
        John Hubbard <jhubbard@nvidia.com>,
        Keith Busch <keith.busch@intel.com>,
        Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCHv3 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in get_user_pages_fast()
In-Reply-To: <1559725820-26138-1-git-send-email-kernelfans@gmail.com>
References: <1559725820-26138-1-git-send-email-kernelfans@gmail.com>
Date: Tue, 11 Jun 2019 21:45:31 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19061116-0016-0000-0000-000002882CF6
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061116-0017-0000-0000-000032E55CB2
Message-Id: <87tvcwhzdo.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-11_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=458 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906110104
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Pingfan Liu <kernelfans@gmail.com> writes:

> As for FOLL_LONGTERM, it is checked in the slow path
> __gup_longterm_unlocked(). But it is not checked in the fast path, which
> means a possible leak of CMA page to longterm pinned requirement through
> this crack.

Shouldn't we disallow FOLL_LONGTERM with get_user_pages fastpath? W.r.t
dax check we need vma to ensure whether a long term pin is allowed or not.
If FOLL_LONGTERM is specified we should fallback to slow path.

-aneesh

