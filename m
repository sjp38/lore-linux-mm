Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBB93C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 11:17:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59924205F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 11:17:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="sr7q2DuZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59924205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B39508E0008; Wed, 20 Feb 2019 06:17:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE6D98E0002; Wed, 20 Feb 2019 06:17:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 987E88E0008; Wed, 20 Feb 2019 06:17:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4F61B8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 06:17:19 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id z1so6342794pln.11
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 03:17:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:content-transfer-encoding
         :mime-version:subject:message-id:date:to;
        bh=8yfozOGmH82u2AWnV7ygGPHczsbRyAAPKipKRdT7+q0=;
        b=gI6SWDFZZv86TLQFEJRWHHV26AJRpfvFxqA32ZaWiO46HZ5mGT7meNaCTywGEIr7Kg
         F2ywpPVimv3booOi1jsiT7KzNlgEzOJ/Upjr+WzkopGCt/XV6PT47CITpKhIZSO1GLpE
         NHCWlCD9ve2ftvYlAidvUCLj/nwKjnYB0FJAklN5QlmlGIcNTQ8oLk7fcCHwajSf3Okt
         tVcc72hFnHEFyUYByBbthydI/mWgwLYYUZyijwHOKAWdOV1UhQnxuiACMAUKwhz8NZ2D
         xefqp468OqYqxG/GQwYy7XnVXZz/ppAAxA88OUrJSu5bIPxA19N9u8Y4Fed3b9QPLcqq
         zi4A==
X-Gm-Message-State: AHQUAuZ5aY2RSzvfPyl/wtjg8Hgh+jGTf2k0++UV9AFg2oArOr0JnjYI
	3weSymxgaM1881n4uUg/baVt9yrb8SN5bKkPN8x6iWMn5HfRuZDZWf3O0Soy4YVg1Bz2KRwizbk
	TsPpCSt90yULt5aWpMd6wVnm/2Pxfuz/pe6UnQvATPFDM6kuznH8h4plQYSC2ObIkvA==
X-Received: by 2002:a17:902:b101:: with SMTP id q1mr36171455plr.135.1550661438784;
        Wed, 20 Feb 2019 03:17:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibw91L9CKa+97P9s/ZdF/GHiWgc1aCGJMu2thyx+izUBp+7OLbfOj+/6WBgdtOOJmTX1Ne6
X-Received: by 2002:a17:902:b101:: with SMTP id q1mr36171371plr.135.1550661437567;
        Wed, 20 Feb 2019 03:17:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550661437; cv=none;
        d=google.com; s=arc-20160816;
        b=rhva/VrGloONKILmpjIG27oD5hyLjeA/cGkeCZdlwAsYujwQJVn7dIj4C95Je/KU04
         W6Q6PmR7p6YX3o246REUAx2rqiHIn13iTRTsJvHlaUgKbMN5fgqLdK7urerNN3f6KPex
         zFAp4ys1IPfnG067ZVdmLXXUUtY75cgeBrQL3LxuNfJEjiE/GMZdM2cingAuO/NAHY7r
         Ho7Ix+6nn7qW/jXYUs9NFs2TQhx/uvvDbIO8XtnFNrnVx6vtWAvdFeDAtlVUVtv3Ra+p
         N28pMv6ZTH6HjnLivD8A2t5Pie7mkWvTwjZQjGy33Z3HSTCzNI/lHpSPOp1hE5fhgy+r
         ErGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:date:message-id:subject:mime-version:content-transfer-encoding
         :from:dkim-signature;
        bh=8yfozOGmH82u2AWnV7ygGPHczsbRyAAPKipKRdT7+q0=;
        b=LoxEv4KarbrWp+iwx2bOHeJ3gj+NQ1f7a56H/bKFJeZMghz96Zegmc+qo61yU9Cene
         6S1I7NVo7BdaYFJ9mH6L4dhW7xQ8Ljm2BBZjxpwDBlmr2Nu8/zYL/svjEn4NB2Xs4m8U
         D7iKmjUZNbKBPuLQGUtm0jp9Ky8LdsG5nNT2c4VcudnFmOah1ervh+BTXhadOItN2/i9
         /Si+xQA71WUHFFFWywYotLzr9xfnnZMyOvnidZ9P2YW4DIfra9qPSQk1DfeVLrEXkqhz
         05JbMlTbXAMp+T0Ef9Jj6iN8R7B/yDZ6RSRbyUMPKBA0qctBtegk1siw5GnUt3PpEuU4
         s8DQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=sr7q2DuZ;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 91si19283708ply.214.2019.02.20.03.17.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 03:17:17 -0800 (PST)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=sr7q2DuZ;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1KBE3Dm001346;
	Wed, 20 Feb 2019 11:17:16 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : content-type :
 content-transfer-encoding : mime-version : subject : message-id : date :
 to; s=corp-2018-07-02; bh=8yfozOGmH82u2AWnV7ygGPHczsbRyAAPKipKRdT7+q0=;
 b=sr7q2DuZV3JOAVLyIQbppxKb5HwYMhDEhf5o1jTgRVkP13qYTwt45zPEAQ4UGamhUkh1
 tu0H9N1CxZZLhhdpODJflLsTEk5+o9KtK89pGWV/NUW51qrMH+qfJbJXQILopmfHxK2Q
 yx9O2EA9kWowdoCtjr7XkOt6Hid2wXKE3D5mkOBuJc4WXDJNH2IkjTB16zhUqUOvYDuW
 sNbNixbL4BobIIOw5oMBO+DXUXyqJR8CSoFohE52EhNVIHcxyAi6RgVCra0IEvU8HILR
 vhx5LoWdWy7nTdrUzOUPbNY5E/YMg0OhNeuqb8bYEuUoA4ZjHQuoyHpCIdDf+CTXjQo+ aQ== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2qpb5rgsr1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Feb 2019 11:17:16 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1KBHFks017454
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Feb 2019 11:17:15 GMT
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1KBHEjV016376;
	Wed, 20 Feb 2019 11:17:14 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 20 Feb 2019 03:17:14 -0800
From: William Kucharski <william.kucharski@oracle.com>
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.2\))
Subject: [LSF/MM TOPIC ][LSF/MM ATTEND] Read-only Mapping of Program Text
 using Large THP Pages
Message-Id: <379F21DD-006F-4E33-9BD5-F81F9BA75C10@oracle.com>
Date: Wed, 20 Feb 2019 04:17:13 -0700
To: lsf-pc@lists.linux-foundation.org, Linux-MM <linux-mm@kvack.org>,
        linux-fsdevel@vger.kernel.org
X-Mailer: Apple Mail (2.3445.104.2)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9172 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902200082
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For the past year or so I have been working on further developing my =
original
prototype support of mapping read-only program text using large THP =
pages.

I developed a prototype described below which I continue to work on, but =
the
major issues I have yet to solve involve page cache integration and =
filesystem
support.

At present, the conventional methodology of reading a single base PAGE =
and
using readahead to fill in additional pages isn't useful as the entire =
(in my
prototype) PMD page needs to be read in before the page can be mapped =
(and at
that point it is unclear whether readahead of additional PMD sized pages =
would
be of benefit or too costly.

Additionally, there are no good interfaces at present to tell filesystem =
layers
that content is desired in chunks larger than a hardcoded limit of 64K, =
or to
to read disk blocks in chunks appropriate for PMD sized pages.

I very briefly discussed some of this work with Kirill in the past, and =
am
currently somewhat blocked on progress with my prototype due to issues =
with
multiorder page size support in the radix tree page cache. I don't feel =
it is
worth the time to debug those issues since the radix tree page cache is =
dead,
and it's much more useful to help Matthew Wilcox get multiorder page =
support
for XArray tested and approved upstream.

The following is a backgrounder on the work I have done to date and some
performance numbers.

Since it's just a prototype, I am unsure as to whether it would make a =
good topic
of a discussion talk per se, but should I be invited to attend it could
certainly engender a good amount of discussion as a BOF/cross-discipline =
topic
between the MM and FS tracks.

Thanks,
    William Kucharski

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

One of the downsides of THP as currently implemented is that it only =
supports
large page mappings for anonymous pages.

I embarked upon this prototype on the theory that it would be =
advantageous to=20
be able to map large ranges of read-only text pages using THP as well.

The idea is that the kernel will attempt to allocate and map the range =
using a=20
PMD sized THP page upon first fault; if the allocation is successful the =
page=20
will be populated (at present using a call to kernel_read()) and the =
page will=20
be mapped at the PMD level. If memory allocation fails, the page fault =
routines=20
will drop through to the conventional PAGESIZE-oriented routines for =
mapping=20
the faulting page.

Since this approach will map a PMD size block of the memory map at a =
time, we=20
should see a slight uptick in time spent in disk I/O but a substantial =
drop in=20
page faults as well as a reduction in iTLB misses as address ranges will =
be=20
mapped with the larger page. Analysis of a test program that consists of =
a very=20
large text area (483,138,032 bytes in size) that thrashes D$ and I$ =
shows this=20
does occur and there is a slight reduction in program execution time.

The text segment as seen from readelf:

LOAD          0x0000000000000000 0x0000000000400000 0x0000000000400000
              0x000000001ccc19f0 0x000000001ccc19f0 R E    0x200000

As currently implemented for test purposes, the prototype will only use =
large=20
pages to map an executable with a particular filename ("testr"), =
enabling easy=20
comparison of the same executable using 4K and 2M (x64) pages on the =
same=20
kernel. It is understood that this is just a proof of concept =
implementation=20
and much more work regarding enabling the feature and overall system =
usage of=20
it would need to be done before it was submitted as a kernel patch. =
However, I=20
felt it would be worthy to send it out as an RFC so I can find out =
whether=20
there are huge objections from the community to doing this at all, or a =
better=20
understanding of the major concerns that must be assuaged before it =
would even=20
be considered. I currently hardcode CONFIG_TRANSPARENT_HUGEPAGE to the=20=

equivalent of "always" and bypass some checks for anonymous pages by =
simply=20
#ifdefing the code out; obviously I would need to determine the right =
thing to=20
do in those cases.

Current comparisons of 4K vs 2M pages as generated by "perf stat -d -d =
-d -r10"=20
follow; the 4K pagesize program was named "foo" and the 2M pagesize =
program=20
"testr" (as noted above) - please note that these numbers do vary from =
run to=20
run, but the orders of magnitude of the differences between the two =
versions=20
remain relatively constant:

4K Pages:
=3D=3D=3D=3D=3D=3D=3D=3D=3D
Performance counter stats for './foo' (10 runs):

  307054.450421      task-clock:u (msec)       #    1.000 CPUs utilized  =
          ( +-  0.21% )
              0      context-switches:u        #    0.000 K/sec
              0      cpu-migrations:u          #    0.000 K/sec
          7,728      page-faults:u             #    0.025 K/sec          =
          ( +-  0.00% )
1,401,295,823,265      cycles:u                #    4.564 GHz            =
          ( +-  0.19% )  (30.77%)
562,704,668,718      instructions:u            #    0.40  insn per cycle =
          ( +-  0.00% )  (38.46%)
 20,100,243,102      branches:u                #   65.461 M/sec          =
          ( +-  0.00% )  (38.46%)
      2,628,944      branch-misses:u           #    0.01% of all =
branches          ( +-  3.32% )  (38.46%)
180,885,880,185      L1-dcache-loads:u         #  589.100 M/sec          =
          ( +-  0.00% )  (38.46%)
 40,374,420,279      L1-dcache-load-misses:u   #   22.32% of all =
L1-dcache hits    ( +-  0.01% )  (38.46%)
    232,184,583      LLC-loads:u               #    0.756 M/sec          =
          ( +-  1.48% )  (30.77%)
     23,990,082      LLC-load-misses:u         #   10.33% of all =
LL-cache hits     ( +-  1.48% )  (30.77%)
<not supported>      L1-icache-loads:u
 74,897,499,234      L1-icache-load-misses:u                             =
          ( +-  0.00% )  (30.77%)
180,990,026,447      dTLB-loads:u              #  589.440 M/sec          =
          ( +-  0.00% )  (30.77%)
        707,373      dTLB-load-misses:u        #    0.00% of all dTLB =
cache hits   ( +-  4.62% )  (30.77%)
      5,583,675      iTLB-loads:u              #    0.018 M/sec          =
          ( +-  0.31% )  (30.77%)
  1,219,514,499      iTLB-load-misses:u        # 21840.71% of all iTLB =
cache hits  ( +-  0.01% )  (30.77%)
<not supported>      L1-dcache-prefetches:u
<not supported>      L1-dcache-prefetch-misses:u

307.093088771 seconds time elapsed                                       =
   ( +-  0.20% )

2M Pages:
=3D=3D=3D=3D=3D=3D=3D=3D=3D
Performance counter stats for './testr' (10 runs):

  289504.209769      task-clock:u (msec)       #    1.000 CPUs utilized  =
          ( +-  0.19% )
              0      context-switches:u        #    0.000 K/sec
              0      cpu-migrations:u          #    0.000 K/sec
            598      page-faults:u             #    0.002 K/sec          =
          ( +-  0.03% )
1,323,835,488,984      cycles:u                #    4.573 GHz            =
          ( +-  0.19% )  (30.77%)
562,658,682,055      instructions:u            #    0.43  insn per cycle =
          ( +-  0.00% )  (38.46%)
 20,099,662,528      branches:u                #   69.428 M/sec          =
          ( +-  0.00% )  (38.46%)
      2,877,086      branch-misses:u           #    0.01% of all =
branches          ( +-  4.52% )  (38.46%)
180,899,297,017      L1-dcache-loads:u         #  624.859 M/sec          =
          ( +-  0.00% )  (38.46%)
 40,209,140,089      L1-dcache-load-misses:u   #   22.23% of all =
L1-dcache hits    ( +-  0.00% )  (38.46%)
    135,968,232      LLC-loads:u               #    0.470 M/sec          =
          ( +-  1.56% )  (30.77%)
      6,704,890      LLC-load-misses:u         #    4.93% of all =
LL-cache hits     ( +-  1.92% )  (30.77%)
<not supported>      L1-icache-loads:u
 74,955,673,747      L1-icache-load-misses:u                             =
          ( +-  0.00% )  (30.77%)
180,987,794,366      dTLB-loads:u              #  625.165 M/sec          =
          ( +-  0.00% )  (30.77%)
            835      dTLB-load-misses:u        #    0.00% of all dTLB =
cache hits   ( +- 14.35% )  (30.77%)
      6,386,207      iTLB-loads:u              #    0.022 M/sec          =
          ( +-  0.42% )  (30.77%)
     51,929,869      iTLB-load-misses:u        #  813.16% of all iTLB =
cache hits   ( +-  1.61% )  (30.77%)
<not supported>      L1-dcache-prefetches:u
<not supported>      L1-dcache-prefetch-misses:u

289.551551387 seconds time elapsed                                       =
   ( +-  0.20% )

A check of /proc/meminfo with the test program running shows the large =
mappings:

ShmemPmdMapped:   471040 kB

The obvious problem with this first swipe at things is the large pages =
are not
placed into the page cache, so for example multiple concurrent =
executions of the
test program allocate and map the large pages each time.

A greater architectural issue is the best way to support large pages in =
the page
cache, which is something Matthew Wilcox's multiorder page support in =
XArray
should solve.

Some questions:

* What is the best approach to deal with large pages when PAGESIZE =
mappings exist?
At present, the prototype evicts PAGESIZE pages from the page cache, =
replacing
them with a mapping for the large page, and future mappings of a =
PAGESIZE range
should map using an offset into the PMD sized physical page used to map =
the PMD
sized virtual page.

* Do we need to create per-filesystem routines to handle large pages or =
can
we delay that (ideally we would want to be able to read in the contents
of large pages without having to read_iter however many PAGESIZE pages
we need.)

I am happy to take whatever approach is best to add large pages to the =
page
cache, but it seems useful and crucuial that a way be provided for the =
system to
automatically use THP to map large text pages if so desired, read-only =
to begin
but eventually read/write to accommodate applications that self-modify =
code such
as databases and Java.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=

