Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id CEE9C6B0279
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 14:27:49 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id wk8so106157091pab.3
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 11:27:49 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id d186si76836665pfc.72.2016.09.21.11.27.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Sep 2016 11:27:49 -0700 (PDT)
Subject: Re: [PATCH 0/1] memory offline issues with hugepage size > memory
 block size
References: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>
 <bc000c05-3186-da92-e868-f2dbf0c28a98@oracle.com>
 <20160921182054.GK24210@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <57E2D124.9000108@linux.intel.com>
Date: Wed, 21 Sep 2016 11:27:48 -0700
MIME-Version: 1.0
In-Reply-To: <20160921182054.GK24210@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>

On 09/21/2016 11:20 AM, Michal Hocko wrote:
> I would even question the per page block offlining itself. Why would
> anybody want to offline few blocks rather than the whole node? What is
> the usecase here?

The original reason was so that you could remove a DIMM or a riser card
full of DIMMs, which are certainly a subset of a node.

With virtual machines, perhaps you only want to make a small adjustment
to the memory that a VM has.  Or, perhaps the VM only _has_ one node.
Granted, ballooning takes care of a lot of these cases, but memmap[]
starts to get annoying at some point if you balloon too much memory away.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
