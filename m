Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DB7AC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 15:10:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3FD020854
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 15:10:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3FD020854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9502E8E0003; Wed, 13 Mar 2019 11:10:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 900328E0001; Wed, 13 Mar 2019 11:10:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7EEF98E0003; Wed, 13 Mar 2019 11:10:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 54B788E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:10:24 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id x63so1817027qka.5
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 08:10:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:user-agent:mime-version:content-language
         :content-transfer-encoding:message-id;
        bh=kgrcCrL1qyCk7yaM57a+vs74Do/VkxYPAMutHJfimF8=;
        b=TNNwdXPCynZQbqps2DJmmoSjwHzQOAHOnAnd7Gq1FUw8Zs3WdHUTTY+OLClZGalBj9
         zTf8zB05dSdxey7t4aHxwLFECF2IOTRgfmUlOH1idn/GPF1Jya+ephMQn04uFHLPakVQ
         6uM89w/m/XvTCx+8SrNqSVDrYGz+lSq3nCPKYOk+uS43sksqP8gx1vKn8z+SZohO+Bxd
         sqypAaou/0sohfGrjCUwaIMYT/WFn+VWcfGwxyY21ua8wFV8mZVloRZkEeF3TNyaD1x/
         AzxQZOclR0JrKJBL4ganXfWL/bI22pTnTkwzDnMzJeNkKAQH2ozHDa2o+zat24nCy5se
         xlBA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAV97jhV+2TxoDHW6/XV0RwNpX8t60XJruAkRhvSzdTlE7+/rghn
	RXS3HNOJSQalaMC3Xet6RK+IdDbnqdU8Q5PsjrSDQon4pUxuWBFe8rrBl03opFlmrU2pUaa3LXr
	hKgGkhi21RqyoF4ezBh9G2zcja3yQqXw1eBEXDc969qni2s0faK1HwL3nm2wxY9HIhg==
X-Received: by 2002:aed:3868:: with SMTP id j95mr35501119qte.35.1552489824092;
        Wed, 13 Mar 2019 08:10:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwLa5CgCBjKKUxe+kTN8iCU1jsyF24GOx4zeb573VZh4Oi5CRanJ/KZtsgf2MFgc8BdXR/
X-Received: by 2002:aed:3868:: with SMTP id j95mr35501050qte.35.1552489823106;
        Wed, 13 Mar 2019 08:10:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552489823; cv=none;
        d=google.com; s=arc-20160816;
        b=Z8YyEKOFK3D0PeMO7bEOL7zdfR+JmECxb8Lw0hSNoNtsEE+fqbL5BnrE4et6XGmDey
         k0C9DFHgGHeaMY+yFcAyP5EJanO/bujnPL258XUnD5VGx+h4OLhRCZu3pFNFIutfjDbb
         y0lCUg5jJSvDxVcq2Lh2ki7Ey5m7jUZPitlsYR+l/VQNsI5NpWQQdd+5ongA88LlEDxG
         VbdioXUpKFBO3aC4va+gpqmFKT/2O/2en3j633f/lngSGcvH3ufjLhwyDjhHi2ek5xDD
         u3C5YmnYzwnS+mBmU2VD2xmngghvwYrIslM1X0WmXRD8bv+2SRkzxZoOpoCDlOuzNrGT
         3WiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:mime-version
         :user-agent:date:subject:cc:to:from;
        bh=kgrcCrL1qyCk7yaM57a+vs74Do/VkxYPAMutHJfimF8=;
        b=hwtnEHPqn2Whtzlj9wsYV0xXsCTfa5ane9H4oFA7dQGg5/NysAIYUYXe8OaAkxKfUD
         bt4nbsCJSFSbRV0sPAhM2fedb+APLHFKpw0/jSUX25sGVTubHTT936kzGJHYVlYTLxP4
         Rd/XaMtWAI8y1cTczbRJNAADsRYDgFlBG7/NeUrV0uaZBGGHiTXynwDqEd273u3moPtu
         28X/Pi4+SpCJ6lBLUP5sQg6ZufczyC9VswYPk+OJ8NG0OBATtAWY9vM5xt6zpzLX6oLb
         Tb8QQjoJYwbGVA8incFxgE9N3YVDSzC9yAI2x9KjH1hCAPxyukkZZwtWfOT/gmPYtvZg
         9d7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j2si4365062qkg.114.2019.03.13.08.10.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 08:10:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2DF9LkV038515
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:10:22 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2r747w03v3-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:10:22 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Wed, 13 Mar 2019 15:10:20 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 13 Mar 2019 15:10:17 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2DFAGEO30474482
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 13 Mar 2019 15:10:16 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B6755A4060;
	Wed, 13 Mar 2019 15:10:16 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A5FAEA405F;
	Wed, 13 Mar 2019 15:10:15 +0000 (GMT)
Received: from [9.145.161.27] (unknown [9.145.161.27])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 13 Mar 2019 15:10:15 +0000 (GMT)
From: Laurent Dufour <ldufour@linux.ibm.com>
To: lsf-pc@lists.linux-foundation.org, Linux-MM <linux-mm@kvack.org>,
        linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>
Subject: [LSF/MM TOPIC] Using XArray to manage the VMA
Date: Wed, 13 Mar 2019 16:10:14 +0100
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.5.3
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19031315-0016-0000-0000-000002616D08
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19031315-0017-0000-0000-000032BC1AEA
Message-Id: <7da20892-f92a-68d8-4804-c72c1cb0d090@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-13_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=824 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903130109
X-Bogosity: Ham, tests=bogofilter, spamicity=0.135722, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If this is not too late and if there is still place available, I would 
like to attend the MM track and propose a topic about using the XArray 
to replace the VMA's RB tree and list.

Using the XArray in place of the VMA's tree and list seems to be a first 
step to the long way of removing/replacing the mmap_sem.
However, there are still corner cases to address like the VMA splitting 
and merging which may raise some issue. Using the XArray's specifying 
locking would not be enough to handle the memory management, and 
additional fine grain locking like a per VMA one could be studied, 
leading to further discussion about the merging of the VMA.

In addition, here are some topics I'm interested in:
- Test cases to choose for demonstrating mm features or fixing mm bugs 
proposed by Balbir Singh
- mm documentation proposed by Mike Rapoport

Laurent.

