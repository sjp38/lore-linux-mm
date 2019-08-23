Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEC49C3A5A2
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 05:32:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 816E122CF7
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 05:32:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ozlabs.org header.i=@ozlabs.org header.b="J/JhSKyJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 816E122CF7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=ozlabs.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08F846B037D; Fri, 23 Aug 2019 01:32:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0415B6B0380; Fri, 23 Aug 2019 01:32:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E965A6B0381; Fri, 23 Aug 2019 01:32:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0053.hostedemail.com [216.40.44.53])
	by kanga.kvack.org (Postfix) with ESMTP id C95866B037D
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 01:32:54 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 609F5181AC9AE
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 05:32:54 +0000 (UTC)
X-FDA: 75852573468.17.wound32_3654af5bd2753
X-HE-Tag: wound32_3654af5bd2753
X-Filterd-Recvd-Size: 3198
Received: from ozlabs.org (ozlabs.org [203.11.71.1])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 05:32:53 +0000 (UTC)
Received: by ozlabs.org (Postfix, from userid 1003)
	id 46F95q6lYyz9s3Z; Fri, 23 Aug 2019 15:32:47 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=ozlabs.org; s=201707;
	t=1566538367; bh=z02FCq36ZOlybuIQo9saHjlkCOE1r+GbTnZ2u8ZYozQ=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=J/JhSKyJna3dO+hzVwvKqr555OfMsYkSc6rEU4HDI6t7UXTZHTXFw0kUqNtRyy1fT
	 XZyG/guq1JZXAD1JYZyREjzSKwT6GNg2EdxDMBXY+ve7kgOG8szGrIaMMU/8EKCnyd
	 aqmdM2IfW0NRJlzhmm0iNJfc2uKXKdhv4xxiOzyxO5RBad4beOWcisAo4QRjQvL3uZ
	 L08pjXagLF/YR+8V5WEbqt0bH/8AvagOKgWfNO33k8vwEm3ehMt6BldhXCpwlAKll+
	 Swt7Wc9SWo0muhF2IbJRhtyIOpv1eFZ2DG4ba8glK3yeGGJCS6v7LuIh+B0hvTl8zy
	 vgO9sc3zYRUcA==
Date: Fri, 23 Aug 2019 14:17:47 +1000
From: Paul Mackerras <paulus@ozlabs.org>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org,
	linux-mm@kvack.org, paulus@au1.ibm.com,
	aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
	linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
	cclaudio@linux.ibm.com, hch@lst.de
Subject: Re: [PATCH v7 0/7] KVMPPC driver to manage secure guest pages
Message-ID: <20190823041747.ctquda5uwvy2eiqz@oak.ozlabs.ibm.com>
References: <20190822102620.21897-1-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190822102620.21897-1-bharata@linux.ibm.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 03:56:13PM +0530, Bharata B Rao wrote:
> Hi,
> 
> A pseries guest can be run as a secure guest on Ultravisor-enabled
> POWER platforms. On such platforms, this driver will be used to manage
> the movement of guest pages between the normal memory managed by
> hypervisor(HV) and secure memory managed by Ultravisor(UV).
> 
> Private ZONE_DEVICE memory equal to the amount of secure memory
> available in the platform for running secure guests is created.
> Whenever a page belonging to the guest becomes secure, a page from
> this private device memory is used to represent and track that secure
> page on the HV side. The movement of pages between normal and secure
> memory is done via migrate_vma_pages(). The reverse movement is driven
> via pagemap_ops.migrate_to_ram().
> 
> The page-in or page-out requests from UV will come to HV as hcalls and
> HV will call back into UV via uvcalls to satisfy these page requests.
> 
> These patches are against hmm.git
> (https://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git/log/?h=hmm)
> 
> plus
> 
> Claudio Carvalho's base ultravisor enablement patchset v6
> (https://lore.kernel.org/linuxppc-dev/20190822034838.27876-1-cclaudio@linux.ibm.com/T/#t)

How are you thinking these patches will go upstream?  Are you going to
send them via the hmm tree?

I assume you need Claudio's patchset as a prerequisite for your series
to compile, which means the hmm maintainers would need to pull in a
topic branch from Michael Ellerman's powerpc tree, or something like
that.

Paul.

