Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F408C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 01:42:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6182206C1
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 01:42:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="XasiF8h7";
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="wa69hRGW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6182206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85B496B0008; Mon, 12 Aug 2019 21:42:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 807B86B000A; Mon, 12 Aug 2019 21:42:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D09E6B000C; Mon, 12 Aug 2019 21:42:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0238.hostedemail.com [216.40.44.238])
	by kanga.kvack.org (Postfix) with ESMTP id 466606B0008
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:42:42 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id EC9FF4FE2
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 01:42:41 +0000 (UTC)
X-FDA: 75815705322.03.death64_51b2a4ee92e54
X-HE-Tag: death64_51b2a4ee92e54
X-Filterd-Recvd-Size: 11602
Received: from aserp2120.oracle.com (aserp2120.oracle.com [141.146.126.78])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 01:42:41 +0000 (UTC)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7D1csG5025908;
	Tue, 13 Aug 2019 01:42:35 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : mime-version : content-transfer-encoding;
 s=corp-2019-08-05; bh=BBBgJHWDpE3974ehXMOJUCh+tK0rPjMp6VqtBjvyEG0=;
 b=XasiF8h71/edNlrX+r7tIBi/Nvz/KTzyFLfnI64/Ase4ZARfJ4OvjW+AcLIx9hjAcxsb
 h2c2AIRx7+qJsKhUndSsS74cubMAlMIRYcSWwekqPrTAZVnZ66Btiz0KkHhZ+T+KBskN
 /vuHsQVH8+e5pu+QdGvDg1Sacxj2/rYBXaoTZ9JcdRzqCz981eI4UtjH36r2MvQhKkN5
 FLLL7KTpf+8RGKe7LhCAtMRS+oo8h+cAl2l50mRZ0QhdUWy5hxWqAcpNrhTqJ0svzC00
 U6f9npIhLO6/fc4mbX3fkTf88abdv3jRfkGwFRlBLfK3bAJcA1k5Gprd7rXt5qgpufsF eQ== 
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : mime-version : content-transfer-encoding;
 s=corp-2018-07-02; bh=BBBgJHWDpE3974ehXMOJUCh+tK0rPjMp6VqtBjvyEG0=;
 b=wa69hRGWfqFlJoRwatoK1folQCoYJXGWr9xsbj+RkhmqOZtdWOSVv59eqU6qfpi9W/zh
 sVovN3NplULVs/2axclYD1n3SZzSVkQsh33NGtMsnEiI7K0+aYz7LtIs8nRClOqzLpdW
 L1jHOx4mLaJCTkVFnQed7Ex71pUchNQUVVzPFFfp/9GZTmh6XFUKJtlIaFBMRkrQ4MdH
 ymU8ZSGRDdFbIpC6afca6VnsWxrucwaSvejIAPG9Wg3FvZJIFUZg4AObvewC7THT+QtA
 vOsChfmJW4j9XMjJ7MZCS4cbufn329JRLHP7YnWLHG4+TjteIDsNYHxAcGHPc6K4SVa1 4A== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2120.oracle.com with ESMTP id 2u9nvp31w0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 13 Aug 2019 01:42:35 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7D1bVDt072860;
	Tue, 13 Aug 2019 01:40:34 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3020.oracle.com with ESMTP id 2u9n9hje19-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 13 Aug 2019 01:40:34 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x7D1ePJU005027;
	Tue, 13 Aug 2019 01:40:25 GMT
Received: from concerto.internal (/10.154.133.246)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 12 Aug 2019 18:40:25 -0700
From: Khalid Aziz <khalid.aziz@oracle.com>
To: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net,
        mhocko@suse.com, dan.j.williams@intel.com
Cc: Khalid Aziz <khalid.aziz@oracle.com>, osalvador@suse.de,
        richard.weiyang@gmail.com, hannes@cmpxchg.org, arunks@codeaurora.org,
        rppt@linux.vnet.ibm.com, jgg@ziepe.ca, amir73il@gmail.com,
        alexander.h.duyck@linux.intel.com, linux-mm@kvack.org,
        linux-kernel-mentees@lists.linuxfoundation.org,
        linux-kernel@vger.kernel.org
Subject: [RFC PATCH 0/2] Add predictive memory reclamation and compaction
Date: Mon, 12 Aug 2019 19:40:10 -0600
Message-Id: <20190813014012.30232-1-khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9347 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908130015
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9347 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908130015
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Page reclamation and compaction is triggered in response to reaching low
watermark. This makes reclamation/compaction reactive based upon a
snapshot of the system at a point in time. When that point is reached,
system is already suffering from free memory shortage and must now try
to recover. Recovery can often land system in direct
reclamation/compaction path and while recovery happens, workloads start
to experience unpredictable memory allocation latencies. In real life,
forced direct reclamation has been seen to cause sudden spike in time it
takes to populate a new database or an extraordinary unpredictable
latency in launching a new server on cloud platform. These events create
SLA violations which are expensive for businesses.

If the kernel could foresee a potential free page exhaustion or
fragmentation event well before it happens, it could start reclamation
proactively instead to avoid allocation stalls. A time based trend line
for available free pages can show such potential future events by
charting the current memory consumption trend on the system.

These patches propose a way to capture enough memory usage information
to compute a trend line based upon most recent data. Trend line is
graphed with x-axis showing time and y-axis showing number of free
pages. The proposal is to capture the number of free pages at opportune
moments along with the current timestamp. Once system has enough data
points (the lookback window for trend analysis), fit a line of the form
y=3Dmx+c to these points using least sqaure regression method.  As time
advances, these points can be updated with new data points and a new
best fit line can be computed. Capturing these data points and computing
trend line for pages of order 0-MAX_ORDER allows us to not only foresee
free pages exhaustion point but also severe fragmentation points in
future.

If the line representing trend for total free pages has a negative slope
(hence trending downward), solving y=3Dmx+c for x with y=3D0 tells us if
the current trend continues, at what point would the system run out of
free pages. If average rate of page reclamation is computed by observing
page reclamation behavior, that information can be used to compute the
time to start reclamation at so that number of free pages does not fall
to 0 or below low watermark if current memory consumption trend were to
continue.

Similarly, if kernel tracks the level of fragmentation for each order
page (which can be done by computing the number of free pages below this
order), a trend line for each order can be used to compute the point in
time when no more pages of that order will be available for allocation.
If the trend line represents number of unusable pages for that order,
the intersection of this line with line representing number of free
pages is the point of 100% fragmentation. This holds true because at
this intersection point all free pages are of lower order. Intersetion
point for two lines y0=3Dm0x0+c0 and y1=3Dm1x1+c1 can be computed
mathematically which yields x and y coordinates on time and free pages
graph. If average rate of compaction is computed by timing previous
compaction runs, kernel can compute how soon does it need to start
compaction to avoid this 100% fragmentation point.

Patch 1 adds code to maintain a sliding lookback window of (time, number
of free pages) points which can be updated continuously and adds code to
compute best fit line across these points. It also adds code to use the
best fit lines to determine if kernel must start reclamation or
compaction.

Patch 2 adds code to collect data points on free pages of various orders
at different points in time, uses code in patch 1 to update sliding
lookback window with these points and kicks off reclamation or
compaction based upon the results it gets.

Patch 1 maintains a fixed size lookback window. A fixed size lookback
window limits the amount of data that has to be maintained to compute a
best fit line. Routine mem_predict() in patch 1 uses best fit line to
determine the immediate need for reclamation or compaction. To simplify
initial concept implementation, it uses a fixed time threshold when
compaction should start in anticipation of impending fragmentation.
Similarly it uses a fixed minimum precentage free pages as criteria to
detrmine if it is time to start reclamation if the current trend line
shows continued drop in number of free pages. Both of these criteria can
be improved upon in final implementation by taking rate of compaction
and rate of reclamation into account.

Patch 2 collects data points for best fit line in kswapd before we
decide if kswapd should go to sleep or continue reclamation. It then
uses that data to delay kswapd from sleeping and continue reclamation.
Potential fragmentation information obtained from best fit line is used
to decide if zone watermark should be boosted to avert impending
fragmentation. This data is also used in balance_pgdat() to determine if
kcompatcd should be woken up to start compaction.
get_page_from_freelist() might be a better place to gather data points
and make decision on starting reclamation or comapction but it can also
impact page allocation latency. Another possibility is to create a
separate kernel thread that gathers page usage data periodically and
wakes up kswapd or kcompactd as needed based upon trend analysis. This
is something that can be finalized before final implementation of this
proposal.

Impact of this implementation was measured using two sets of tests.
First test consists of three concurrent dd processes writing large
amounts of data (66 GB, 131 GB and 262 GB) to three different SSDs
causing large number of free pages to be used up for buffer/page cache.
Number of cumulative allocation stalls as reported by /proc/vmstat were
recorded for 5 runs of this test.

5.3-rc2
-------

allocstall_dma 0
allocstall_dma32 0
allocstall_normal 15
allocstall_movable 1629
compact_stall 0

Total =3D 1644


5.3-rc2 + this patch series
---------------------------

allocstall_dma 0
allocstall_dma32 0
allocstall_normal 182
allocstall_movable 1266
compact_stall 0

Total =3D 1544

There was no significant change in system time between these runs. This
was a ~6.5% improvement in number of allocation stalls.

A scond test used was the parallel dd test from mmtests. Average number
of stalls over 4 runs with unpatched 5.3-rc2 kernel was 6057. Average
number of stalls over 4 runs after applying these patches was 5584. This
was an ~8% improvement in number of allocation stalls.

This work is complementary to other allocation/compaction stall
improvements. It attempts to address potential stalls proactively before
they happen and will make use of any improvements made to the
reclamation/compaction code.

Any feedback on this proposal and associated implementation will be
greatly appreciated. This is work in progress.

Khalid Aziz (2):
  mm: Add trend based prediction algorithm for memory usage
  mm/vmscan: Add fragmentation prediction to kswapd

 include/linux/mmzone.h |  72 +++++++++++
 mm/Makefile            |   2 +-
 mm/lsq.c               | 273 +++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c        |  27 ----
 mm/vmscan.c            | 116 ++++++++++++++++-
 5 files changed, 456 insertions(+), 34 deletions(-)
 create mode 100644 mm/lsq.c

--=20
2.20.1


