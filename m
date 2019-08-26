Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2F1AC3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 16:03:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F6DA20674
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 16:03:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F6DA20674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D87156B05AD; Mon, 26 Aug 2019 12:03:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D10CC6B05AF; Mon, 26 Aug 2019 12:03:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD8D56B05B0; Mon, 26 Aug 2019 12:03:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0106.hostedemail.com [216.40.44.106])
	by kanga.kvack.org (Postfix) with ESMTP id 93FC56B05AD
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 12:03:13 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 4034782437CF
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 16:03:13 +0000 (UTC)
X-FDA: 75865048266.16.hole14_3920d3709a91c
X-HE-Tag: hole14_3920d3709a91c
X-Filterd-Recvd-Size: 8282
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 16:03:12 +0000 (UTC)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7QFmpRx058972;
	Mon, 26 Aug 2019 12:02:23 -0400
Received: from pps.reinject (localhost [127.0.0.1])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2umffnr0g8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Mon, 26 Aug 2019 12:02:21 -0400
Received: from m0098410.ppops.net (m0098410.ppops.net [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x7QFnNSd060609;
	Mon, 26 Aug 2019 12:02:20 -0400
Received: from ppma01wdc.us.ibm.com (fd.55.37a9.ip4.static.sl-reverse.com [169.55.85.253])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2umffnr0bm-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Mon, 26 Aug 2019 12:02:19 -0400
Received: from pps.filterd (ppma01wdc.us.ibm.com [127.0.0.1])
	by ppma01wdc.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x7QFofiZ028532;
	Mon, 26 Aug 2019 16:02:09 GMT
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by ppma01wdc.us.ibm.com with ESMTP id 2ujvv65reu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Mon, 26 Aug 2019 16:02:09 +0000
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7QG28wN11273076
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 26 Aug 2019 16:02:08 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 55E7BB2078;
	Mon, 26 Aug 2019 16:02:08 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3051CB2067;
	Mon, 26 Aug 2019 16:01:54 +0000 (GMT)
Received: from [9.199.38.251] (unknown [9.199.38.251])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Mon, 26 Aug 2019 16:01:53 +0000 (GMT)
Subject: Re: [PATCH v2 0/6] mm/memory_hotplug: Consider all zones when
 removing memory
To: David Hildenbrand <david@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Alexander Duyck <alexander.h.duyck@linux.intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Andy Lutomirski
 <luto@kernel.org>,
        Anshuman Khandual <anshuman.khandual@arm.com>,
        Arun KS <arunks@codeaurora.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Borislav Petkov <bp@alien8.de>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Christophe Leroy <christophe.leroy@c-s.fr>,
        Dan Williams <dan.j.williams@intel.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Fenghua Yu
 <fenghua.yu@intel.com>,
        Gerald Schaefer <gerald.schaefer@de.ibm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Halil Pasic <pasic@linux.ibm.com>,
        Heiko Carstens
 <heiko.carstens@de.ibm.com>,
        "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
        Ira Weiny <ira.weiny@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Jun Yao <yaojun8558363@gmail.com>,
        Logan Gunthorpe <logang@deltatee.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        "Matthew Wilcox (Oracle)" <willy@infradead.org>,
        Mel Gorman <mgorman@techsingularity.net>,
        Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>,
        Mike Rapoport <rppt@linux.ibm.com>, Oscar Salvador <osalvador@suse.de>,
        Paul Mackerras <paulus@samba.org>,
        Pavel Tatashin
 <pasha.tatashin@soleen.com>,
        Pavel Tatashin <pavel.tatashin@microsoft.com>,
        Peter Zijlstra <peterz@infradead.org>, Qian Cai <cai@lca.pw>,
        Rich Felker <dalias@libc.org>, Robin Murphy <robin.murphy@arm.com>,
        Steve Capper <steve.capper@arm.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Tom Lendacky <thomas.lendacky@amd.com>,
        Tony Luck <tony.luck@intel.com>, Vasily Gorbik <gor@linux.ibm.com>,
        Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>,
        Wei Yang <richardw.yang@linux.intel.com>,
        Will Deacon <will@kernel.org>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Yu Zhao <yuzhao@google.com>
References: <20190826101012.10575-1-david@redhat.com>
 <87pnksm0zx.fsf@linux.ibm.com>
 <194da076-364e-267d-0d51-64940925e2e4@redhat.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Message-ID: <a30b7156-7679-a04a-f74a-c5407b922979@linux.ibm.com>
Date: Mon, 26 Aug 2019 21:31:52 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <194da076-364e-267d-0d51-64940925e2e4@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-26_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908260160
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/26/19 9:13 PM, David Hildenbrand wrote:
> On 26.08.19 16:53, Aneesh Kumar K.V wrote:
>> David Hildenbrand <david@redhat.com> writes:
>>
>>> 

....

>>
>> I did report a variant of the issue at
>>
>> https://lore.kernel.org/linux-mm/20190514025354.9108-1-aneesh.kumar@linux.ibm.com/
>>
>> This patch series still doesn't handle the fact that struct page backing
>> the start_pfn might not be initialized. ie, it results in crash like
>> below
> 
> Okay, that's a related but different issue I think.
> 
> I can see that current shrink_zone_span() might read-access the
> uninitialized struct page of a PFN if
> 
> 1. The zone has holes and we check for "zone all holes". If we get
> pfn_valid(pfn), we check if "page_zone(pfn_to_page(pfn)) != zone".
> 
> 2. Via find_smallest_section_pfn() / find_biggest_section_pfn() find a
> spanned pfn_valid(). We check
> - pfn_to_nid(start_pfn) != nid
> - zone != page_zone(pfn_to_page(start_pfn)
> 
> So we don't actually use the zone/nid, only use it to sanity check. That
> might result in false-positives (not that bad).
> 
> It all boils down to shrink_zone_span() not working only on active
> memory, for which the PFN is not only valid but also initialized
> (something for which we need a new section flag I assume).
> 
> Which access triggers the issue you describe? pfn_to_nid()?
> 
>>
>>      pc: c0000000004bc1ec: shrink_zone_span+0x1bc/0x290
>>      lr: c0000000004bc1e8: shrink_zone_span+0x1b8/0x290
>>      sp: c0000000dac7f910
>>     msr: 800000000282b033
>>    current = 0xc0000000da2fa000
>>    paca    = 0xc00000000fffb300   irqmask: 0x03   irq_happened: 0x01
>>      pid   = 1224, comm = ndctl
>> kernel BUG at /home/kvaneesh/src/linux/include/linux/mm.h:1088!
>> Linux version 5.3.0-rc6-17495-gc7727d815970-dirty (kvaneesh@ltc-boston123) (gcc version 7.4.0 (Ubuntu 7.4.0-1ubuntu1~18.04.1)) #183 SMP Mon Aug 26 09:37:32 CDT 2019
>> enter ? for help
> 
> Which exact kernel BUG are you hitting here? (my tree doesn't seem t
> have any BUG statement around  include/linux/mm.h:1088). 



This is against upstream linus with your patches applied.


static inline int page_to_nid(const struct page *page)
{
	struct page *p = (struct page *)page;

	return (PF_POISONED_CHECK(p)->flags >> NODES_PGSHIFT) & NODES_MASK;
}


#define PF_POISONED_CHECK(page) ({					\
		VM_BUG_ON_PGFLAGS(PagePoisoned(page), page);		\
		page; })
#


It is the node id access.

-aneesh

