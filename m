Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9FF4C43444
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 19:59:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3A7320665
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 19:59:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3A7320665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 311078E0002; Thu, 10 Jan 2019 14:59:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 297A18E0001; Thu, 10 Jan 2019 14:59:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 113028E0002; Thu, 10 Jan 2019 14:59:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C08CE8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 14:59:09 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id v72so6936936pgb.10
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 11:59:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=1gwTluziBeI721v/jIxPP34k4opPlA4YlXhQJSnkt2c=;
        b=Ukg7+l6nWZdOLksikD8NWwEKLbKQuW7QayT1hihwfnQFGGuFD4CFRPpJ//spwQw2e0
         PkCCMtq/bKjWe4Iz8XvI21KsFt1Linx5N7r/1ywjUKcBG0NkiXewiSmIeXtVDbkPc3pt
         1Kj0w9VwYwZSH0HxGtVR3wRwdFyuyU0F57pBlty0HpZYpbzqy1GAQdEBo8EMRaA1zxe/
         z81yUGhd9KtogLV5MY6Jfx+XBJuyl73GpJPUqgGi3S2fNjN9shO1cYYlqzXpgLN5NjFr
         APyEcClF5jUeIdEq48vU8N1EkeYnR1QkU/Kaiq5QAtsJDjNxp2JZ+JqriyPSjSCePdQx
         rb8w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jejb@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=jejb@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukcQVBgeOXKspiGOkQLx7VPVbTCP0qkDB+eGNrtfRfjfBqYY0Dfb
	AgvtHU+4c08yF8b5u7GW63w5Ax+xk8IsRekEYaHqHe1Cb2T8j7efEygE1jMx6Un6bwrO1E1buxy
	IHWAZ30Z9JsGM+KOHmUkdlQkjFW7wdCIjeX7U4SBe3FHrMctqPy+ES+GZwLdoSHEBdQ==
X-Received: by 2002:a63:1b1f:: with SMTP id b31mr10547836pgb.66.1547150349403;
        Thu, 10 Jan 2019 11:59:09 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6nhn5imxg1KR6GYHCRfUMC8GJ3XgUg39UPOHm9Wj0eFyE4Kdea1qnMcdtgNM2L1wnhrzZX
X-Received: by 2002:a63:1b1f:: with SMTP id b31mr10547796pgb.66.1547150348573;
        Thu, 10 Jan 2019 11:59:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547150348; cv=none;
        d=google.com; s=arc-20160816;
        b=Q1ILwDaDnpxZ86sW74dRHBPztXlqGVNLIjOQfUxiNhrFI2g/MpeMPMEgH5weGRI96N
         YD5KDuEjsMJoMCCod1l3YgISDJ/VGhfhx7+PtbhJJkqPDfyYiV0d3zf0plThVtHVqnPt
         q4oZFgYQPYQODOH7pdXgCwRMlQxQmzZqble3zrrs8ctauJommnhcd0B+PYeC4sm6ECZj
         cTTS5vTHcX+PulVRtjMfKYnpZiGLkUIbhrMxxoQCltq5mxcmfYUNRSVqiDEhYYbx1PR8
         zhjpdKCuMMlS4jlLoqvJ429etLXfqTBPrz/lYv8THpjrauEcDTaxgQuIiV6yZLT1rifF
         eTbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:cc:to:from:subject;
        bh=1gwTluziBeI721v/jIxPP34k4opPlA4YlXhQJSnkt2c=;
        b=AOCiFrQ7jr8bLToCt7BF0UFI/K3fzlDRy8Aw9S7DVc6l3k1vX5zHuN4tgc4P2Ma4pk
         pSXGVcBZBBNytpkuT+2H6QI+AtGOFTvJMaMb8R+RkVNQ8kTRkDBoxFCGW5iAEAPQYJSH
         TkG7bxZkqcYhu4k3QPU4if2l53xbxqWqiEotgp/uweuOtZYdlfWUpMav1SZRyt6FtBbt
         kDW+Pf6MMrXf0c1vbOXPWILSNR7h2M8yj8bXZKBM5ShUqwWOxyYqLWc/H6mqGitH/XJ1
         OJ5aaoKzxTXc2Lo4GXeFY1DKTHlOjVEOdKpByOXFRknuMBpqNHvI4xeXCtAZ9vb3OjAs
         SWCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jejb@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=jejb@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m75si4624897pga.432.2019.01.10.11.59.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 11:59:08 -0800 (PST)
Received-SPF: pass (google.com: domain of jejb@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jejb@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=jejb@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x0AJrYQ3073952
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 14:59:07 -0500
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2px9errune-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 14:59:07 -0500
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <jejb@linux.ibm.com>;
	Thu, 10 Jan 2019 19:59:06 -0000
Received: from b03cxnp08025.gho.boulder.ibm.com (9.17.130.17)
	by e34.co.us.ibm.com (192.168.1.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 10 Jan 2019 19:59:03 -0000
Received: from b03ledav004.gho.boulder.ibm.com (b03ledav004.gho.boulder.ibm.com [9.17.130.235])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0AJx2RQ29163636
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 10 Jan 2019 19:59:02 GMT
Received: from b03ledav004.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0A1B57805E;
	Thu, 10 Jan 2019 19:59:02 +0000 (GMT)
Received: from b03ledav004.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 78B8D7805C;
	Thu, 10 Jan 2019 19:59:00 +0000 (GMT)
Received: from [153.66.254.194] (unknown [9.85.186.19])
	by b03ledav004.gho.boulder.ibm.com (Postfix) with ESMTP;
	Thu, 10 Jan 2019 19:59:00 +0000 (GMT)
Subject: Re: PROBLEM: syzkaller found / pool corruption-overwrite / page in
 user-area or NULL
From: James Bottomley <jejb@linux.ibm.com>
To: Esme <esploit@protonmail.ch>,
        "dgilbert@interlog.com"
	 <dgilbert@interlog.com>,
        "martin.petersen@oracle.com"
	 <martin.petersen@oracle.com>,
        "linux-scsi@vger.kernel.org"
	 <linux-scsi@vger.kernel.org>,
        "linux-kernel@vger.kernel.org"
	 <linux-kernel@vger.kernel.org>,
        linux-mm@kvack.org
Cc: "security@kernel.org" <security@kernel.org>
Date: Thu, 10 Jan 2019 11:58:59 -0800
In-Reply-To: <t78EEfgpy3uIwPUvqvmuQEYEWKG9avWzjUD3EyR93Qaf_tfx1gqt4XplrqMgdxR1U9SsrVdA7G9XeUZacgUin0n6lBzoxJHVJ9Ko0yzzrxI=@protonmail.ch>
References: 
	<t78EEfgpy3uIwPUvqvmuQEYEWKG9avWzjUD3EyR93Qaf_tfx1gqt4XplrqMgdxR1U9SsrVdA7G9XeUZacgUin0n6lBzoxJHVJ9Ko0yzzrxI=@protonmail.ch>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19011019-0016-0000-0000-00000972EB19
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010380; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000274; SDB=6.01144587; UDB=6.00595975; IPR=6.00924852;
 MB=3.00025072; MTD=3.00000008; XFM=3.00000015; UTC=2019-01-10 19:59:04
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19011019-0017-0000-0000-000041B91A3C
Message-Id: <1547150339.2814.9.camel@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-10_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901100154
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000011, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110195859.KAcEJnLIGeixm9z2-b56twd00v3pmVAUtCqkbTuUCUc@z>

On Thu, 2019-01-10 at 19:12 +0000, Esme wrote:
> Sorry for the resend some mail servers rejected the mime type.
> 
> Hi, I've been getting more into Kernel stuff lately and forged ahead
> with some syzkaller bug finding.  I played with reducing it further
> as you can see from the attached c code but am moving on and hope to
> get better about this process moving forward as I'm still building
> out my test systems/debugging tools.
> 
> Attached is the report and C repro that still triggers on a fresh git
> pull as of a few minutes ago, if you need anything else please let me
> know.
> Esme
> 
> Linux syzkaller 5.0.0-rc1+ #5 SMP Tue Jan 8 20:39:33 EST 2019 x86_64
> GNU/Linux

I'm not sure I'm reading this right, but it seems that a simple
allocation inside block/scsi_ioctl.h

	buffer = kzalloc(bytes, q->bounce_gfp | GFP_USER| __GFP_NOWARN);

(where bytes is < 4k) caused a slub padding check failure on free. 
From the internal details, the freeing entity seems to be KASAN as part
of its quarantine reduction (albeit triggered by this kzalloc).  I'm
not remotely familiar with what KASAN is doing, but it seems the memory
corruption problem is somewhere within the KASAN tracking?

I added linux-mm in case they can confirm this diagnosis or give me a
pointer to what might be wrong in scsi.

James

