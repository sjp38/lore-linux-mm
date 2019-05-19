Return-Path: <SRS0=ZpWy=TT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D817CC04AB4
	for <linux-mm@archiver.kernel.org>; Sun, 19 May 2019 08:55:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D8032146F
	for <linux-mm@archiver.kernel.org>; Sun, 19 May 2019 08:55:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D8032146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B00146B0003; Sun, 19 May 2019 04:55:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB1CE6B0006; Sun, 19 May 2019 04:55:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C7546B0007; Sun, 19 May 2019 04:55:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7DDF46B0003
	for <linux-mm@kvack.org>; Sun, 19 May 2019 04:55:45 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id y185so11039694ybc.18
        for <linux-mm@kvack.org>; Sun, 19 May 2019 01:55:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=O2QHmw/ZXq7UfYNB3h/adjnShYsChidW+TpetMYKq2s=;
        b=hI94I3fwtt2d2/NsDqTUjMjnlw4vUvHJo0wWL/OEHF5RubScdYoGhxRegCS17aqX/O
         usYOU9axLhPsFOOH+KqTkp6BuaPI1A6lZZGg6MsHGAhR0/mN0lzmKAIt8+QX5Cb7LUZB
         hRcIvMqmBU3qLElbGAsP/wi81c3pUsRwZDiJWenUcQgPyIK0gTUESDtvQ9+KMkarJgW6
         zAW8MCixKM+hVv3jOBVLeIVYT+NDBdQ77t/VlvT8SUIhoMHVEXxhUGD/fkyJcsmzkRSU
         W6ZDBsdmOO+Codw3fdAkRXQr+FBG7NzOENyy0Uln6RkTz6AfyvFmVKD6XGR7gg4HCDLh
         P6/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXvR3TR7VtX4UzmeHk2zzsbJ2kBAt31dAX0gLUTHbzjgr4D/knU
	pHMLuWhzr2/dGxPgSyediZC3XJaarGZHr/ZueWmpJqu2Lfc/Q1Npyp10mwUyp4jNeI6cnjwX3j7
	8CWU4M8A4nc2fGO3CaP4qcGxlbgcwmFCOj8krJm5hqtSmafrU0AXdoCU1lfbs4sJPgQ==
X-Received: by 2002:a0d:ed04:: with SMTP id w4mr32215812ywe.208.1558256145261;
        Sun, 19 May 2019 01:55:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzeJGf9NkTWI8Zyzx8qoQVoz7Tj8CMyyIBNkoAVGH4nG2dMbjiTM350TYFLXw+/lxq8tMr
X-Received: by 2002:a0d:ed04:: with SMTP id w4mr32215804ywe.208.1558256144261;
        Sun, 19 May 2019 01:55:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558256144; cv=none;
        d=google.com; s=arc-20160816;
        b=gtiKjse4V1nNX9eCBiuXnhqKLYAAyhnps+34NhMPh0pUCaGgYqg9R2poTwxTqTqpTz
         jW9INxiUGawm+IdWhFhL6+NsFI5e0sG9LeNIGt6YgPo2riFTAx/IHXL2A4TyuzqYwwba
         rVi/d4OK4exXfDvTxZtgxWLF9ytIyiwOEk+TRNoMBBw4ZsC3E54n/0S3d0maqjenHdrk
         EnBv/TDHkqY0Ge1rg/zNK9+QfpHSXPbuhKPiLJ5eMNqdDaUEIn9s09fBo9yMuqIShYZT
         MMRIlSoFM/8hNA/yLSJ8lu+PQroqJYFEMOXDcaznCScEfxsgq0rDVRr5ZpTtSbLV6620
         eKwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=O2QHmw/ZXq7UfYNB3h/adjnShYsChidW+TpetMYKq2s=;
        b=pdsJhBwMxvOQAEZCIzjDd8DX4dikrPdJTBOFYKTTAZYjsxA7PkdqmCXtiNRDiVh6NT
         mlp8qNX1GpA19Akv8zJGIDsjCZka/5EwrF5Y13BgfyqdtQTO2z8wg6gvqw8FbxAF0z0H
         su+YxuT2/fjIIrj5x+grvyDdxn9k6bPgN+tlY4Xe7RBbp/hIW6XP9RlJYa/ys/6PX29L
         0ka0QIEQGFeVakK+VVEXuhPxg/fl1vDgdlQeY5CHYP+g7PUk95y/rrbp6eUsxnpY+v91
         EtZFsJwqdmS/2iw0C+Gz5/yEHhY4fQ9rgmjlpT0bpEoHKxW3CjghpBy2crIN57Eplba8
         C+EA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h82si3898152ybh.209.2019.05.19.01.55.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 01:55:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4J8pHrx087394
	for <linux-mm@kvack.org>; Sun, 19 May 2019 04:55:43 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sjyfk0fw3-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 19 May 2019 04:55:43 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Sun, 19 May 2019 09:55:42 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 19 May 2019 09:55:38 +0100
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4J8tbea57933866
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 19 May 2019 08:55:38 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CA26E42042;
	Sun, 19 May 2019 08:55:37 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 774024203F;
	Sun, 19 May 2019 08:55:36 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.199.50.203])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Sun, 19 May 2019 08:55:36 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org,
        linux-nvdimm@lists.01.org, Vaibhav Jain <vaibhav@linux.ibm.com>
Subject: Re: [PATCH] mm/nvdimm: Pick the right alignment default when creating dax devices
In-Reply-To: <de5cbe7d-bd47-6793-1f1a-2274c5c59eb5@linux.ibm.com>
References: <20190514025449.9416-1-aneesh.kumar@linux.ibm.com> <875zq9m8zx.fsf@vajain21.in.ibm.com> <de5cbe7d-bd47-6793-1f1a-2274c5c59eb5@linux.ibm.com>
Date: Sun, 19 May 2019 14:25:33 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19051908-4275-0000-0000-000003365BFF
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19051908-4276-0000-0000-00003845EA00
Message-Id: <87sgtaddru.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-19_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=990 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905190066
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hi Dan,

"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:

> On 5/17/19 8:19 PM, Vaibhav Jain wrote:
>> Hi Aneesh,
>> 

....

>>
>>> +	/*
>>> +	 * Check whether the we support the alignment. For Dax if the
>>> +	 * superblock alignment is not matching, we won't initialize
>>> +	 * the device.
>>> +	 */
>>> +	if (!nd_supported_alignment(align) &&
>>> +	    memcmp(pfn_sb->signature, DAX_SIG, PFN_SIG_LEN)) {
>> Suggestion to change this check to:
>> 
>> if (memcmp(pfn_sb->signature, DAX_SIG, PFN_SIG_LEN) &&
>>     !nd_supported_alignment(align))
>> 
>> It would look  a bit more natural i.e. "If the device has dax signature and alignment is
>> not supported".
>> 
>
> I guess that should be !memcmp()? . I will send an updated patch with 
> the hash failure details in the commit message.
>

We need clarification on what the expected failure behaviour should be.
The nd_pmem_probe doesn't really have a failure behaviour in this
regard. For example.

I created a dax device with 16M alignment

{                                          
  "dev":"namespace0.0",
  "mode":"devdax",                         
  "map":"dev",                             
  "size":"9.98 GiB (10.72 GB)",
  "uuid":"ba62ef22-ebdf-4779-96f5-e6135383ed22",
  "raw_uuid":"7b2492f9-7160-4ee9-9c3d-2f547d9ef3ee",
  "daxregion":{                            
    "id":0,                                
    "size":"9.98 GiB (10.72 GB)",
    "align":16777216,
    "devices":[                            
      {                                    
        "chardev":"dax0.0",
        "size":"9.98 GiB (10.72 GB)"
      }                                    
    ]                                      
  },                                       
  "align":16777216,                        
  "numa_node":0,                           
  "supported_alignments":[
    65536,                                 
    16777216                               
  ]                                        
}      

Now what we want is to fail the initialization of the device when we
boot a kernel that doesn't support 16M page size. But with the
nd_pmem_probe failure behaviour we now end up with

[
  {
    "dev":"namespace0.0",
    "mode":"fsdax",
    "map":"mem",
    "size":10737418240,
    "uuid":"7b2492f9-7160-4ee9-9c3d-2f547d9ef3ee",
    "blockdev":"pmem0"
  }
]

So it did fallthrough the

	/* if we find a valid info-block we'll come back as that personality */
	if (nd_btt_probe(dev, ndns) == 0 || nd_pfn_probe(dev, ndns) == 0
			|| nd_dax_probe(dev, ndns) == 0)
		return -ENXIO;

	/* ...otherwise we're just a raw pmem device */
	return pmem_attach_disk(dev, ndns);


Is it ok if i update the code such that we don't do that default
pmem_atach_disk if we have a label area?

-aneesh

