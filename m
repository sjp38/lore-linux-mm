Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9544C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 04:07:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59B9820843
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 04:07:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="tVUjv4Kp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59B9820843
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9D216B0003; Tue, 23 Apr 2019 00:07:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A49746B0006; Tue, 23 Apr 2019 00:07:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EC336B0007; Tue, 23 Apr 2019 00:07:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 515666B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 00:07:40 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 132so9215456pgc.18
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 21:07:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:to:cc:from:subject:message-id
         :date:user-agent:mime-version:content-language
         :content-transfer-encoding;
        bh=k7+6BSM8oK42LBfrwAQFm5AsEwXn9us3zgPOcGHMauk=;
        b=VPRkeWx9PUwHD+FXcTwvVuZWplF2fKKjW+TB+VtrTiASjVCtWQOo6NDLP75xmw5Yp2
         tnzrN2qx0hblcSPIroQaLnKXU8FmDVLYTNk2xYShWBKehxwy7lqeuYDJWzen8EuNnbfN
         3i8lKiGO+jgGd2yfPMXH4++bHftRf9XUQOBa/nfv7FOAv/IavpOOSuWufSCSQBhX32FD
         h86/nwbtmKp7gnElSkoZTLC9JlM2pvMtca53Z2WDsdCt+HDaR50tQ5vOvnnbH1rifvag
         YFlMNZDVpEo0++3yrJYwQH63/YAlVn8zB2GnLjKiHdqwDbZW7JYmPSeL7PvJoOle9kL6
         LFOQ==
X-Gm-Message-State: APjAAAWBibGKy4ywbFS9LsIhg0ixiGRk5rlE0wmYaaDwYsYt6zMdgwmB
	sGL3htW7/pDc8Es0PkzbLntsNXC4NQNiYyVAHEsvBPFhDr9g0DCC9V/iFrZGYTR0cx7lWlrqMWe
	yp3x/yTdyMuwBXAeWxN3ICsO7g8GYNNiGgrtGD5kdSN5VdiBegBy6N+iW0EzdNi0BTQ==
X-Received: by 2002:a63:ff26:: with SMTP id k38mr22558030pgi.123.1555992459679;
        Mon, 22 Apr 2019 21:07:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPhAGiEDncKEbTK4r5xcX32uifrNkdTh1e9yZON2xmAeCMgck56cHKnxXU6EkAwgJAvfxJ
X-Received: by 2002:a63:ff26:: with SMTP id k38mr22557981pgi.123.1555992458738;
        Mon, 22 Apr 2019 21:07:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555992458; cv=none;
        d=google.com; s=arc-20160816;
        b=k6CVQROom1McIFYX+uytt73jkemEiIxtbBbkabJSqEojsjwefXkHeKpBPJM6bxbQJB
         rfGY6DK8re5VlLZZ+G+7HXE97/M/VJkOxyC4Eq3RaECjOEVRtHl/zZXTc5D0GSoQ4HJu
         crYI3hNFlInWgsSHA1X0HzmE91PJk25whVuQ14vkmmDBT4uj3qEyDYXXDUobD82xfMub
         8yZG+NsNgX7evnHrWHFt5TQ4Z8TXydr47qQmifhd205bxlmBJtoK/16HIJXIqHlsrpMx
         QrO9cuwpcoOXJqSCbqOyZmwHUCB3/QG8ZvLbormMvObJpWHfanlqj7MdP6kHEyNVhGOU
         hdsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:subject:from:cc:to:dkim-signature;
        bh=k7+6BSM8oK42LBfrwAQFm5AsEwXn9us3zgPOcGHMauk=;
        b=zroDLKVBZHzCljd3Kmn15RomPELwXmun5JkxxpV2qxGUx4a4PkxDLMmpxQv1tHQorf
         Rf0DDN/1ETpc+hxLpl0LeMp4qNpXXA+zWg4jQCpYtfzt+9nJb88LJ+Cw/KAXZkkpAJHK
         VOGl9uAd2aCUmgnplSPoPm2UoTcIl6HyHpJMiBoHN7l711swOT55E6rsj1rYjPbxIpLg
         X019w6W6y7Ql8n0E2e2vkM5WGKVXdGsarIWdQxUrUuBC6JUo4Sh/wpIynuWJdEowyTK/
         6Xi3ObqlvGdGBOUyrOzRdUiEZBd+WqhHCHbeAC2tc0qURxNNFMUyHsFnLxb8o8toajRi
         opzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=tVUjv4Kp;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id h72si15289334pfd.86.2019.04.22.21.07.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 21:07:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=tVUjv4Kp;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3N44Mjt195522;
	Tue, 23 Apr 2019 04:07:35 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=to : cc : from :
 subject : message-id : date : mime-version : content-type :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=k7+6BSM8oK42LBfrwAQFm5AsEwXn9us3zgPOcGHMauk=;
 b=tVUjv4KpTRT2YKBooSrTLi5Bf3BqdOIXX5+Tju0BWfEFQFpaJ5YTjHcvX4bdUvkan6oa
 O5/PNDyB9ZJQ0jVN01+3D8NOFzPttoDZW6620OrHGG9qIo1ff+uPJBXSyDoX+nM/RuSR
 goDfVJkyGhRvAIFhq0Ur6I5vYE7KGHWDjBogkYGcXX+OyHZMIgj3gCiSGnBeCESOqL6X
 qMO1xrF20CHn9+B/pvReqjktiz3G01AApfvZbFgtuQyg8UpR9QyI+4ziBdj46smZ875y
 lMMY/GZ6iK3UK82zLiqHj3rMiUoGtV8AIAQyEN12B2aqlBlyUwy/3BtjaYBdT0BLcKsr TA== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2130.oracle.com with ESMTP id 2ryrxcsr4w-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 23 Apr 2019 04:07:35 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3N46O54134864;
	Tue, 23 Apr 2019 04:07:35 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2s0f0v96ge-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 23 Apr 2019 04:07:34 +0000
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x3N47Tcs004188;
	Tue, 23 Apr 2019 04:07:30 GMT
Received: from [192.168.1.222] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 22 Apr 2019 21:07:29 -0700
To: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>,
        Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>,
        Johannes Weiner <hannes@cmpxchg.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [Question] Should direct reclaim time be bounded?
Message-ID: <d38a095e-dc39-7e82-bb76-2c9247929f07@oracle.com>
Date: Mon, 22 Apr 2019 21:07:28 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9235 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904230029
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9235 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904230029
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I was looking into an issue on our distro kernel where allocation of huge
pages via "echo X > /proc/sys/vm/nr_hugepages" was taking a LONG time.
In this particular case, we were actually allocating huge pages VERY slowly
at the rate of about one every 30 seconds.  I don't want to talk about the
code in our distro kernel, but the situation that caused this issue exists
upstream and appears to be worse there.

One thing to note is that hugetlb page allocation can really stress the
page allocator.  The routine alloc_pool_huge_page is of special concern.

/*
 * Allocates a fresh page to the hugetlb allocator pool in the node interleaved
 * manner.
 */
static int alloc_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
{
	struct page *page;
	int nr_nodes, node;
	gfp_t gfp_mask = htlb_alloc_mask(h) | __GFP_THISNODE;

	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
		page = alloc_fresh_huge_page(h, gfp_mask, node, nodes_allowed);
		if (page)
			break;
	}

	if (!page)
		return 0;

	put_page(page); /* free it into the hugepage allocator */

	return 1;
}

This routine is called for each huge page the user wants to allocate.  If
they do "echo 4096 > nr_hugepages", this is called 4096 times.
alloc_fresh_huge_page() will eventually call __alloc_pages_nodemask with
__GFP_COMP|__GFP_RETRY_MAYFAIL|__GFP_NOWARN in addition to __GFP_THISNODE.
That for_each_node_mask_to_alloc() macro is hugetlbfs specific and attempts
to allocate huge pages in a round robin fashion.  When asked to allocate a
huge page, it first tries the 'next_nid_to_alloc'.  If that fails, it goes
to the next allowed node.  This is 'documented' in kernel docs as:

"On a NUMA platform, the kernel will attempt to distribute the huge page pool
 over all the set of allowed nodes specified by the NUMA memory policy of the
 task that modifies nr_hugepages.  The default for the allowed nodes--when the
 task has default memory policy--is all on-line nodes with memory.  Allowed
 nodes with insufficient available, contiguous memory for a huge page will be
 silently skipped when allocating persistent huge pages.  See the discussion
 below of the interaction of task memory policy, cpusets and per node attributes
 with the allocation and freeing of persistent huge pages.

 The success or failure of huge page allocation depends on the amount of
 physically contiguous memory that is present in system at the time of the
 allocation attempt.  If the kernel is unable to allocate huge pages from
 some nodes in a NUMA system, it will attempt to make up the difference by
 allocating extra pages on other nodes with sufficient available contiguous
 memory, if any."

However, consider the case of a 2 node system where:
node 0 has 2GB memory
node 1 has 4GB memory

Now, if one wants to allocate 4GB of huge pages they may be tempted to simply,
"echo 2048 > nr_hugepages".  At first this will go well until node 0 is out
of memory.  When this happens, alloc_pool_huge_page() will continue to be
called.  Because of that for_each_node_mask_to_alloc() macro, it will likely
attempt to first allocate a page from node 0.  It will call direct reclaim and
compaction until it fails.  Then, it will successfully allocate from node 1.

In our distro kernel, I am thinking about making allocations try "less hard"
on nodes where we start to see failures.  less hard == NORETRY/NORECLAIM.
I was going to try something like this on an upstream kernel when I noticed
that it seems like direct reclaim may never end/exit.  It 'may' exit, but I
instrumented __alloc_pages_slowpath() and saw it take well over an hour
before I 'tricked' it into exiting.

[ 5916.248341] hpage_slow_alloc: jiffies 5295742  tries 2   node 0 success
[ 5916.249271]                   reclaim 5295741  compact 1

This is where it stalled after "echo 4096 > nr_hugepages" on a little VM
with 8GB total memory.

I have not started looking at the direct reclaim code to see exactly where
we may be stuck, or trying really hard.  My question is, "Is this expected
or should direct reclaim be somewhat bounded?"  With __alloc_pages_slowpath
getting 'stuck' in direct reclaim, the documented behavior for huge page
allocation is not going to happen.
-- 
Mike Kravetz

