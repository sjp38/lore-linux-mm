Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F70BC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 23:46:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 205CB21883
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 23:46:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="hSmwubqr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 205CB21883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFD056B0007; Tue,  3 Sep 2019 19:46:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAC5E6B0008; Tue,  3 Sep 2019 19:46:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9B0C6B000A; Tue,  3 Sep 2019 19:46:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0218.hostedemail.com [216.40.44.218])
	by kanga.kvack.org (Postfix) with ESMTP id 821276B0007
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 19:46:22 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id DF2D052D9
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 23:46:21 +0000 (UTC)
X-FDA: 75895245762.30.aunt06_378230dda0a04
X-HE-Tag: aunt06_378230dda0a04
X-Filterd-Recvd-Size: 7361
Received: from userp2130.oracle.com (userp2130.oracle.com [156.151.31.86])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 23:46:21 +0000 (UTC)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x83NiMgm016233;
	Tue, 3 Sep 2019 23:46:10 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : references : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2019-08-05;
 bh=gVzd1xf9o+fcSS2lfDeJltPXEjbUtM30OmGuZGgNO7M=;
 b=hSmwubqrsY25Qx8aIq/54/tJiLgh28xXXlaE0aNL0uV9fXey2tXHfMl0THru4K7mEjr9
 oZag18RuzqILZ9Cg9xZUYVU/7L/ZpfkToycFo1IE6TraQKhwh6rdwSDw/hOYY7QjE1Ec
 q02lZeb892ymnKgpkKK9/31TDcipl2reZmoXAJe4dbsIHaqnEcowWrONpgec1otShh5C
 eV7VMyIcACsuK3r41bdRNt4dxUaWo1+RH8WhdhyesJxQwWc00L9TljBtURYSfJLWRkiT
 G8fqrPSjXVNb9xteZdgoXIv5K1yYMXoRlR1HPqE6gqA7f1Lj1LdPS+3LqCwUuEGhA27n Sg== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2ut23tg065-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 03 Sep 2019 23:46:09 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x83NhNr7016728;
	Tue, 3 Sep 2019 23:44:09 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3020.oracle.com with ESMTP id 2ut1hmh6sy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 03 Sep 2019 23:44:09 +0000
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x83Ni2e1013424;
	Tue, 3 Sep 2019 23:44:02 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 03 Sep 2019 16:44:02 -0700
Subject: Re: [PATCH v3 0/6] hugetlb_cgroup: Add hugetlb_cgroup reservation
 limits
From: Mike Kravetz <mike.kravetz@oracle.com>
To: Michal Hocko <mhocko@kernel.org>, Mina Almasry <almasrymina@google.com>
Cc: shuah <shuah@kernel.org>, David Rientjes <rientjes@google.com>,
        Shakeel Butt <shakeelb@google.com>, Greg Thelen <gthelen@google.com>,
        Andrew Morton <akpm@linux-foundation.org>, khalid.aziz@oracle.com,
        open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
        linux-kselftest@vger.kernel.org, cgroups@vger.kernel.org,
        Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>,
        =?UTF-8?Q?Michal_Koutn=c3=bd?= <mkoutny@suse.com>,
        Tejun Heo
 <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        Li Zefan <lizefan@huawei.com>
References: <20190826233240.11524-1-almasrymina@google.com>
 <20190828112340.GB7466@dhcp22.suse.cz>
 <CAHS8izPPhPoqh-J9LJ40NJUCbgTFS60oZNuDSHmgtMQiYw72RA@mail.gmail.com>
 <20190829071807.GR28313@dhcp22.suse.cz>
 <cb7ebcce-05c5-3384-5632-2bbac9995c15@oracle.com>
Message-ID: <e7f91a50-5957-249c-8756-25ea87c77fc4@oracle.com>
Date: Tue, 3 Sep 2019 16:44:00 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <cb7ebcce-05c5-3384-5632-2bbac9995c15@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9369 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1909030239
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9369 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1909030239
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/3/19 10:57 AM, Mike Kravetz wrote:
> On 8/29/19 12:18 AM, Michal Hocko wrote:
>> [Cc cgroups maintainers]
>>
>> On Wed 28-08-19 10:58:00, Mina Almasry wrote:
>>> On Wed, Aug 28, 2019 at 4:23 AM Michal Hocko <mhocko@kernel.org> wrote:
>>>>
>>>> On Mon 26-08-19 16:32:34, Mina Almasry wrote:
>>>>>  mm/hugetlb.c                                  | 493 ++++++++++++------
>>>>>  mm/hugetlb_cgroup.c                           | 187 +++++--
>>>>
>>>> This is a lot of changes to an already subtle code which hugetlb
>>>> reservations undoubly are.
>>>
>>> For what it's worth, I think this patch series is a net decrease in
>>> the complexity of the reservation code, especially the region_*
>>> functions, which is where a lot of the complexity lies. I removed the
>>> race between region_del and region_{add|chg}, refactored the main
>>> logic into smaller code, moved common code to helpers and deleted the
>>> duplicates, and finally added lots of comments to the hard to
>>> understand pieces. I hope that when folks review the changes they will
>>> see that! :)
>>
>> Post those improvements as standalone patches and sell them as
>> improvements. We can talk about the net additional complexity of the
>> controller much easier then.
> 
> All such changes appear to be in patch 4 of this series.  The commit message
> says "region_add() and region_chg() are heavily refactored to in this commit
> to make the code easier to understand and remove duplication.".  However, the
> modifications were also added to accommodate the new cgroup reservation
> accounting.  I think it would be helpful to explain why the existing code does
> not work with the new accounting.  For example, one change is because
> "existing code coalesces resv_map entries for shared mappings.  new cgroup
> accounting requires that resv_map entries be kept separate for proper
> uncharging."
> 
> I am starting to review the changes, but it would help if there was a high
> level description.  I also like Michal's idea of calling out the region_*
> changes separately.  If not a standalone patch, at least the first patch of
> the series.  This new code will be exercised even if cgroup reservation
> accounting not enabled, so it is very important than no subtle regressions
> be introduced.

While looking at the region_* changes, I started thinking about this no
coalesce change for shared mappings which I think is necessary.  Am I
mistaken, or is this a requirement?

If it is a requirement, then think about some of the possible scenarios
such as:
- There is a hugetlbfs file of size 10 huge pages.
- Task A has reservations for pages at offset 1 3 5 7 and 9
- Task B then mmaps the entire file which should result in reservations
  at 0 2 4 6 and 8.
- region_chg will return 5, but will also need to allocate 5 resv_map
  entries for the subsequent region_add which can not fail.  Correct?
  The code does not appear to handle this.

BTW, this series will BUG when running libhugetlbfs test suite.  It will
hit this in resv_map_release().

	VM_BUG_ON(resv_map->adds_in_progress);

-- 
Mike Kravetz

