Return-Path: <SRS0=7uET=XD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5119C4332F
	for <linux-mm@archiver.kernel.org>; Sun,  8 Sep 2019 05:09:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 753E321734
	for <linux-mm@archiver.kernel.org>; Sun,  8 Sep 2019 05:09:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 753E321734
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A57FD6B0005; Sun,  8 Sep 2019 01:09:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A08C36B0006; Sun,  8 Sep 2019 01:09:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F6D36B0007; Sun,  8 Sep 2019 01:09:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0248.hostedemail.com [216.40.44.248])
	by kanga.kvack.org (Postfix) with ESMTP id 69CE36B0005
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 01:09:38 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 1DB0582437C9
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 05:09:38 +0000 (UTC)
X-FDA: 75910575636.23.bell79_36cf36f2e041d
X-HE-Tag: bell79_36cf36f2e041d
X-Filterd-Recvd-Size: 1900
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 05:09:36 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2F8FBAC64;
	Sun,  8 Sep 2019 05:09:34 +0000 (UTC)
Subject: Re: [PATCH 2/3] xen/ballon: Avoid calling dummy function
 __online_page_set_limits()
To: Souptick Joarder <jrdr.linux@gmail.com>, richard.weiyang@gmail.com,
 dan.j.williams@intel.com, sashal@kernel.org, sstabellini@kernel.org,
 cai@lca.pw, akpm@linux-foundation.org, haiyangz@microsoft.com,
 kys@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com,
 david@redhat.com, pasha.tatashin@soleen.com, Michal Hocko <mhocko@suse.com>,
 Oscar Salvador <osalvador@suse.com>
Cc: linux-mm@kvack.org, xen-devel@lists.xenproject.org,
 linux-hyperv@vger.kernel.org, linux-kernel@vger.kernel.org
References: <cover.1567889743.git.jrdr.linux@gmail.com>
 <cover.1567889743.git.jrdr.linux@gmail.com>
 <854db2cf8145d9635249c95584d9a91fd774a229.1567889743.git.jrdr.linux@gmail.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <6b666a74-da96-878a-9288-e0271428c0ee@suse.com>
Date: Sun, 8 Sep 2019 07:09:32 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <854db2cf8145d9635249c95584d9a91fd774a229.1567889743.git.jrdr.linux@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07.09.19 23:47, Souptick Joarder wrote:
> __online_page_set_limits() is a dummy function and an extra call
> to this function can be avoided.
> 
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

Reviewed-by: Juergen Gross <jgross@suse.com>


Juergen

