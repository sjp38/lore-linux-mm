Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D0DE66B0253
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:04:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n18so20091105pfe.7
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:04:30 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y88si16589925pfi.101.2016.10.24.11.04.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 11:04:30 -0700 (PDT)
Subject: Re: [RFC 0/8] Define coherent device memory node
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <580E4D2D.2070408@intel.com>
Date: Mon, 24 Oct 2016 11:04:29 -0700
MIME-Version: 1.0
In-Reply-To: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

On 10/23/2016 09:31 PM, Anshuman Khandual wrote:
> 	To achieve seamless integration  between system RAM and coherent
> device memory it must be able to utilize core memory kernel features like
> anon mapping, file mapping, page cache, driver managed pages, HW poisoning,
> migrations, reclaim, compaction, etc.

So, you need to support all these things, but not autonuma or hugetlbfs?
 What's the reasoning behind that?

If you *really* don't want a "cdm" page to be migrated, then why isn't
that policy set on the VMA in the first place?  That would keep "cdm"
pages from being made non-cdm.  And, why would autonuma ever make a
non-cdm page and migrate it in to cdm?  There will be no NUMA access
faults caused by the devices that are fed to autonuma.

I'm confused.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
