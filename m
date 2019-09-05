Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDC44C3A5A5
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 05:45:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95AB720870
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 05:45:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95AB720870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2723F6B0003; Thu,  5 Sep 2019 01:45:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2243D6B0005; Thu,  5 Sep 2019 01:45:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0EB576B0006; Thu,  5 Sep 2019 01:45:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0119.hostedemail.com [216.40.44.119])
	by kanga.kvack.org (Postfix) with ESMTP id E01146B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 01:45:10 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 77E8D2C81
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 05:45:10 +0000 (UTC)
X-FDA: 75899778780.01.war23_2d1e0650c624e
X-HE-Tag: war23_2d1e0650c624e
X-Filterd-Recvd-Size: 6324
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 05:45:09 +0000 (UTC)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x855ghFU003471;
	Thu, 5 Sep 2019 01:45:08 -0400
Received: from ppma02dal.us.ibm.com (a.bd.3ea9.ip4.static.sl-reverse.com [169.62.189.10])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2utvcnrb31-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 05 Sep 2019 01:45:07 -0400
Received: from pps.filterd (ppma02dal.us.ibm.com [127.0.0.1])
	by ppma02dal.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x855dQGO022698;
	Thu, 5 Sep 2019 05:45:04 GMT
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by ppma02dal.us.ibm.com with ESMTP id 2uqgh7ea66-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 05 Sep 2019 05:45:04 +0000
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x855j3a551839376
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 5 Sep 2019 05:45:03 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B260BB2068;
	Thu,  5 Sep 2019 05:45:03 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7DA86B2064;
	Thu,  5 Sep 2019 05:45:02 +0000 (GMT)
Received: from [9.199.35.243] (unknown [9.199.35.243])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Thu,  5 Sep 2019 05:45:02 +0000 (GMT)
Subject: Re: [PATCH v8] libnvdimm/dax: Pick the right alignment default when
 creating dax devices
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Kirill A . Shutemov" <kirill@shutemov.name>,
        linux-nvdimm <linux-nvdimm@lists.01.org>,
        Linux MM <linux-mm@kvack.org>
References: <20190904065320.6005-1-aneesh.kumar@linux.ibm.com>
 <CAPcyv4hD8SAFNNAWBP9q55wdPf-HYTEjpS4m+rT0VPoGodZULw@mail.gmail.com>
 <33b377ac-86ea-b195-fd83-90c01df604cc@linux.ibm.com>
 <CAPcyv4hBHjrTSHRkwU8CQcXF4EHoz0rzu6L-U-QxRpWkPSAhUQ@mail.gmail.com>
 <d46212fb-7bbb-3db8-5a65-2c8799021fd6@linux.ibm.com>
 <CAPcyv4impX2OEd3ZATz_4_UjOvC4N78uU+PBPRK+id3Nh0EPCw@mail.gmail.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Message-ID: <3c5e4fe3-7cc7-3e55-6616-da084f10f9fd@linux.ibm.com>
Date: Thu, 5 Sep 2019 11:15:01 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <CAPcyv4impX2OEd3ZATz_4_UjOvC4N78uU+PBPRK+id3Nh0EPCw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-05_01:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1909050058
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/5/19 10:45 AM, Dan Williams wrote:
> On Wed, Sep 4, 2019 at 9:10 PM Aneesh Kumar K.V
> <aneesh.kumar@linux.ibm.com> wrote:
>>
>> On 9/5/19 8:29 AM, Dan Williams wrote:
>>>>> Keep this 'static' there's no usage of this routine outside of pfn_devs.c
>>>>>
>>>>>>     {
>>>>>> -       /*
>>>>>> -        * This needs to be a non-static variable because the *_SIZE
>>>>>> -        * macros aren't always constants.
>>>>>> -        */
>>>>>> -       const unsigned long supported_alignments[] = {
>>>>>> -               PAGE_SIZE,
>>>>>> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>>>>>> -               HPAGE_PMD_SIZE,
>>>>>> +       static unsigned long supported_alignments[3];
>>>>>
>>>>> Why is marked static? It's being dynamically populated each invocation
>>>>> so static is just wasting space in the .data section.
>>>>>
>>>>
>>>> The return of that function is address and that would require me to use
>>>> a global variable. I could add a check
>>>>
>>>> /* Check if initialized */
>>>>     if (supported_alignment[1])
>>>>           return supported_alignment;
>>>>
>>>> in the function to updating that array every time called.
>>>
>>> Oh true, my mistake. I was thrown off by the constant
>>> re-initialization. Another option is to pass in the storage since the
>>> array needs to be populated at run time. Otherwise I would consider it
>>> a layering violation for libnvdimm to assume that
>>> has_transparent_hugepage() gives a constant result. I.e. put this
>>>
>>>           unsigned long aligns[4] = { [0] = 0, };
>>>
>>> ...in align_store() and supported_alignments_show() then
>>> nd_pfn_supported_alignments() does not need to worry about
>>> zero-initializing the fields it does not set.
>>
>> That requires callers to track the size of aligns array. If we add
>> different alignment support later, we will end up updating all the call
>> site?
> 
> 2 sites for something that gets updated maybe once a decade?
> 
>>
>> How about?
>>
>> static const unsigned long *nd_pfn_supported_alignments(void)
>> {
>>          static unsigned long supported_alignments[4];
>>
>>          if (supported_alignments[0])
>>                  return supported_alignments;
>>
>>          supported_alignments[0] = PAGE_SIZE;
>>
>>          if (has_transparent_hugepage()) {
>>                  supported_alignments[1] = HPAGE_PMD_SIZE;
>>                  if (IS_ENABLED(CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD))
>>                          supported_alignments[2] = HPAGE_PUD_SIZE;
>>          }
> 
> Again, this makes assumptions that has_transparent_hugepage() always
> returns the same result every time it is called.
> 

That assuming is true right? For architectures supporting THP we don't 
support changing that during runtime. Allowing to change that during 
runtime would have other impacts.

-aneesh


