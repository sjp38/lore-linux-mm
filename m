Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5333D6B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 17:00:18 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id h5-v6so1028533pgs.13
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 14:00:18 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id z13-v6si9731018pgk.127.2018.07.23.14.00.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 14:00:17 -0700 (PDT)
Date: Mon, 23 Jul 2018 14:00:15 -0700
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH 0/4] ia64: switch to NO_BOOTMEM
Message-ID: <20180723210015.GA7058@agluck-desk>
References: <1532325418-22617-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1532325418-22617-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Michal Hocko <mhocko@kernel.org>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 23, 2018 at 08:56:54AM +0300, Mike Rapoport wrote:
> Hi,
> 
> These patches convert ia64 to use NO_BOOTMEM.
> 
> The first two patches are cleanups, the third patches reduces usage of
> 'struct bootmem_data' for easier transition and the forth patch actually
> replaces bootmem with memblock + nobootmem.
> 
> I've tested the sim_defconfig with the ski simulator and build tested other
> defconfigs.

Boots OK on my real ia64 system.

Unless somebody else sees an issue I'll push to Linus nest merge window.

-Tony
