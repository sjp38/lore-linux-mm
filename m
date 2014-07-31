Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0D86B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 05:25:06 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id q58so2481192wes.35
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 02:25:04 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gq8si10014275wjc.76.2014.07.31.02.25.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 31 Jul 2014 02:25:01 -0700 (PDT)
Date: Thu, 31 Jul 2014 11:24:52 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] kexec-export-free_huge_page-to-vmcoreinfo-fix (was: Re:
 mmotm 2014-07-30-15-57 uploaded)
Message-ID: <20140731092452.GB13561@dhcp22.suse.cz>
References: <53d978aa.dtIIGjOqrXXmAm4e%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <53d978aa.dtIIGjOqrXXmAm4e%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>, Baoquan He <bhe@redhat.com>, Vivek Goyal <vgoyal@redhat.com>

On Wed 30-07-14 15:58:50, Andrew Morton wrote:
> * kexec-export-free_huge_page-to-vmcoreinfo.patch

This one seems to be missing ifdef for CONFIG_HUGETLBFS
---
