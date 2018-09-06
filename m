Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8F2856B7948
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 10:59:07 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id b6-v6so5635803pls.16
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 07:59:07 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id p12-v6si4699179pls.53.2018.09.06.07.59.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 07:59:06 -0700 (PDT)
Subject: Re: [PATCH v2 1/2] mm: Move page struct poisoning to
 CONFIG_DEBUG_VM_PAGE_INIT_POISON
References: <20180905211041.3286.19083.stgit@localhost.localdomain>
 <20180905211328.3286.71674.stgit@localhost.localdomain>
 <20180906054735.GJ14951@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <0c1c36f7-f45a-8fe9-dd52-0f60b42064a9@intel.com>
Date: Thu, 6 Sep 2018 07:59:03 -0700
MIME-Version: 1.0
In-Reply-To: <20180906054735.GJ14951@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alexander.h.duyck@intel.com, pavel.tatashin@microsoft.com, akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com

On 09/05/2018 10:47 PM, Michal Hocko wrote:
> why do you have to keep DEBUG_VM enabled for workloads where the boot
> time matters so much that few seconds matter?

There are a number of distributions that run with it enabled in the
default build.  Fedora, for one.  We've basically assumed for a while
that we have to live with it in production environments.

So, where does leave us?  I think we either need a _generic_ debug
option like:

	CONFIG_DEBUG_VM_SLOW_AS_HECK

under which we can put this an other really slow VM debugging.  Or, we
need some kind of boot-time parameter to trigger the extra checking
instead of a new CONFIG option.
