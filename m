Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA516B0037
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 13:47:41 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id z60so3676878qgd.5
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 10:47:41 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id g3si12169224qge.74.2014.07.24.10.47.40
        for <linux-mm@kvack.org>;
        Thu, 24 Jul 2014 10:47:40 -0700 (PDT)
Date: Thu, 24 Jul 2014 18:47:15 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] arm64: fix soft lockup due to large tlb flush range
Message-ID: <20140724174714.GN13371@arm.com>
References: <20140724142417.GE13371@arm.com>
 <1406213775-28617-1-git-send-email-msalter@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1406213775-28617-1-git-send-email-msalter@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Salter <msalter@redhat.com>
Cc: Eric Miao <eric.y.miao@gmail.com>, Will Deacon <Will.Deacon@arm.com>, Laura Abbott <lauraa@codeaurora.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Russell King <linux@arm.linux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Thu, Jul 24, 2014 at 03:56:15PM +0100, Mark Salter wrote:
> Under certain loads, this soft lockup has been observed:
> 
>    BUG: soft lockup - CPU#2 stuck for 22s! [ip6tables:1016]
>    Modules linked in: ip6t_rpfilter ip6t_REJECT cfg80211 rfkill xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw vfat fat efivarfs xfs libcrc32c

Merged (with minor tweaks, comment added). Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
