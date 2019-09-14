Return-Path: <SRS0=RN4K=XJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6320FC4CEC9
	for <linux-mm@archiver.kernel.org>; Sat, 14 Sep 2019 09:47:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F331B20854
	for <linux-mm@archiver.kernel.org>; Sat, 14 Sep 2019 09:47:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="SlFvsOvC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F331B20854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82D1D6B0005; Sat, 14 Sep 2019 05:47:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DCE16B0006; Sat, 14 Sep 2019 05:47:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F4876B0007; Sat, 14 Sep 2019 05:47:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0150.hostedemail.com [216.40.44.150])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9556B0005
	for <linux-mm@kvack.org>; Sat, 14 Sep 2019 05:47:47 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id D3042824CA27
	for <linux-mm@kvack.org>; Sat, 14 Sep 2019 09:47:46 +0000 (UTC)
X-FDA: 75933049332.16.crush12_43db34b916f53
X-HE-Tag: crush12_43db34b916f53
X-Filterd-Recvd-Size: 7234
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 14 Sep 2019 09:47:46 +0000 (UTC)
Received: from localhost (unknown [77.137.89.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 608CE20693;
	Sat, 14 Sep 2019 09:47:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1568454465;
	bh=o1C1eO0XQdj1YbvGrXjBSYKylVEgbJNTPOZGcdRTRG0=;
	h=Date:From:To:Cc:Subject:From;
	b=SlFvsOvC8hnWCiNiFh1dPTLmNHt4DUC71thWfCK7ukAo8OmodVKQFCFggWrmQpDNE
	 7yfj/ZwjookpdlbXK/bUOxzXXsHZb7odDaACo/6wQkxAeGRmZuAckeHm02reG3wJb7
	 xWPpsTP2JOIEoW5wa3PJngDX0TqZLhV6BkIs5ml4=
Date: Sat, 14 Sep 2019 12:47:30 +0300
From: Leon Romanovsky <leon@kernel.org>
To: RDMA mailing list <linux-rdma@vger.kernel.org>
Cc: Jason Gunthorpe <jgg@mellanox.com>, Doug Ledford <dledford@redhat.com>,
	linux-mm <linux-mm@kvack.org>, Jonathan Corbet <corbet@lwn.net>,
	Christoph Hellwig <hch@lst.de>, Sagi Grimberg <sagi@grimberg.me>
Subject: 4th RDMA Microconference Summary
Message-ID: <20190914094730.GL6601@unreal>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
User-Agent: Mutt/1.12.1 (2019-06-15)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

This is summary of 4th RDMA microconference co-located with Linux
Plumbers Conference 2019.

We would like to thank you for all presenters and attendees of our RDMA
track, it is you who made this event so successful.

Special thanks goes to Doug Ledford who volunteered to take notes
and Jason Gunthorpe who helped to run this event smoothly.

The original etherpad is located at [2] and below you will find the copy
of those notes:
-------------------------------------------------------------------------=
-----------------------
1. GUP and ZONE_DEVICE pages. [3]
   Jason Gunthorpe, John Hubbard and Don Dutile

 * Make the interface to use p2p mechanism be via sysfs. (PCI???).
 * Try to kill PTE flag for dev memory to make it easier to support
   on things like s390.
 * s390 will have mapping issues, arm/x86/PowerPC should be fine.
 * Looking to map partial BARs so they can be partitioned between
   different users.
 * Total BAR space could exceed 1TB in some scenarios
   (lots of GPUs in an HPC machine with persistent memory, etc.).
 * Initially use struct page element but try to remove it later.
 * Unlikely to be able to remove struct page, so maybe make it less painf=
ul
   by doing something like forcing all zone mappings to use hugepages ioc=
tl no, sysfs yes.
 * PCI SIG talking about peer-2-peer too.
 * Distance might not be the best function name for the pci p2p checking =
function.
 * Conceptually, looking for new type of page fault, DMA fault, that will=
 make a page
   visible to DMA even if we don=E2=80=99t care if it=E2=80=99s visible t=
o the CPU GUP API makes really
   weak promise, no one could possibly think that it=E2=80=99s that weak,=
 so everyone assumed
   it was stronger they were wrong.
 * It really is that weak wrappers around the GUP flags? 17+ flags curren=
tly,
   combinational matrix is extreme, some internal only flags can be abuse=
d by callers.
 * Possible to set "opposite" GUP flags.
 * Most (if not all) out of core code (drivers) get_user_pages users
   need same flags.

2. RDMA, File Systems, and DAX. [4]
   Ira Weiny
 * There was a bug in previous versions of patch set. It=E2=80=99s fixed.
 * New file_pin object to track relationship between mmaped files
   and DMA mappings to the underlying pages.
 * If owners of lease tries to do something that requires changes
   to the file layout: deadlock of application (current patch set, but no=
t settled).
 * Write lease/fallocate/downgrade to read/unbreakable lease - fix race i=
ssue
   with fallocate and lease chicken and egg problem.

3. Discussion about IBNBD/IBTRS, upstreaming and action items. [5]
   Jinpu Wang, Danil Kipnis
 * IBTRS is standalone transfer engine that can be used with any ULP.
 * IBTRS only uses RDMA_WRITE with IMM and so is limited to fabrics
   that support this.
 * Server does not unmap after write from client so data can change
   when the server is flushing to disk.
 * Need to think about transfer model as the current one appears
   to be vulnerable to a nefarious kernel module.
 * It is worth to consider to unite 4 kernel modules to be 2 kernel
 * modules. One responsible for transfer (server + client) and another
   is responsible for block operations.
 * Security concern should be cleared first before in-depth review.
 * No objections to see IBTRS in kernel, but needs to be renamed to
   something more general, because it works on many fabrics and not only
   IB.

5. Improving RDMA performance through the use of contiguous memory and la=
rger pages for files. [6]
   Christopher Lameter
 * The main problem is that contiguous physical memory being limited
   resource in real life systems. The difference in system performance
   so visible that it is worth to reboot servers every couple of days
   (depend on workload).
 * The reason to it, existence of unmovable pages.
 * HugePages help, but pinned objects over time end up breaking up the hu=
ge
   pages and eventually system flows down Need movable objects: dentry an=
d inode
   are the big culprits.
 * Typical use case used to trigger degradation is copying both very larg=
e
   and very small files on the same machine.
 * Attempts to allocate unmovable pages in specific place causes to
   situations where system experiences OOM despite being enough memory.
 * x86 has 4K page size, while PowerPC has 64K. The bigger page size
   gives better performance, but wastes more memory for small objects.

4. Shared IB objects. [7]
   Yuval Shaia
 * There was lively discussion between various models of sharing
   objects, through file description, or uverbs context, or PD.
 * People would like to stick to the file handle model so you share
   the file handle and get everything you need as being simplest
   approach.
 * Is the security model resolved?  Right now, the model assumes trusted
   processes are allowed to share only.
 * Simple (FD) model creates challenge to properly release HW objects
   after main process exits and leaves HW objects which were in use by
   itself and not by shared processes.
 * Refcount needs to be in the API to track when the shared object is fre=
eable
 * API requires shared memory first, then import PD and import MR.  This =
model
   (as opposed to sharing the fd of the in context), allows for safe clea=
nup on
   process death without interfering with other users of the shared PD/MR=
.

Thanks

[1] https://linuxplumbersconf.org/event/4/sessions/64/#20190911
[2] https://etherpad.net/p/LPC2019_RDMA
[3] https://www.linuxplumbersconf.org/event/4/contributions/369/
[4] https://linuxplumbersconf.org/event/4/contributions/368/
[5] https://linuxplumbersconf.org/event/4/contributions/367/
[6] https://linuxplumbersconf.org/event/4/contributions/371/
[7] https://www.linuxplumbersconf.org/event/4/contributions/371/

