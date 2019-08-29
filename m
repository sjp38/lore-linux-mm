Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E3B1C3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 08:36:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBFE32073F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 08:36:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBFE32073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 626796B0006; Thu, 29 Aug 2019 04:36:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B0206B000C; Thu, 29 Aug 2019 04:36:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4502E6B000D; Thu, 29 Aug 2019 04:36:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0073.hostedemail.com [216.40.44.73])
	by kanga.kvack.org (Postfix) with ESMTP id 1C4696B0006
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 04:36:48 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id CB106A2CD
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 08:36:47 +0000 (UTC)
X-FDA: 75874809654.06.rings97_757d4a31da234
X-HE-Tag: rings97_757d4a31da234
X-Filterd-Recvd-Size: 3440
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 08:36:47 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3AFDAAC97;
	Thu, 29 Aug 2019 08:36:45 +0000 (UTC)
Date: Thu, 29 Aug 2019 10:36:43 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andy Lutomirski <luto@kernel.org>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Arun KS <arunks@codeaurora.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Gerald Schaefer <gerald.schaefer@de.ibm.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Halil Pasic <pasic@linux.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	Ira Weiny <ira.weiny@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Jun Yao <yaojun8558363@gmail.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Oscar Salvador <osalvador@suse.de>,
	Paul Mackerras <paulus@samba.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Peter Zijlstra <peterz@infradead.org>, Qian Cai <cai@lca.pw>,
	Rich Felker <dalias@libc.org>, Robin Murphy <robin.murphy@arm.com>,
	Steve Capper <steve.capper@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tom Lendacky <thomas.lendacky@amd.com>,
	Tony Luck <tony.luck@intel.com>, Vasily Gorbik <gor@linux.ibm.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Wei Yang <richard.weiyang@gmail.com>,
	Wei Yang <richardw.yang@linux.intel.com>,
	Will Deacon <will@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Yu Zhao <yuzhao@google.com>
Subject: Re: [PATCH v2 0/6] mm/memory_hotplug: Consider all zones when
 removing memory
Message-ID: <20190829083643.GV28313@dhcp22.suse.cz>
References: <20190826101012.10575-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190826101012.10575-1-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 26-08-19 12:10:06, David Hildenbrand wrote:
> Working on virtio-mem, I was able to trigger a kernel BUG (with debug
> options enabled) when removing memory that was never onlined. I was able
> to reproduce with DIMMs. As far as I can see the same can also happen
> without debug configs enabled, if we're unlucky and the uninitialized
> memmap contains selected garbage .

Could you be more specific please?
-- 
Michal Hocko
SUSE Labs

