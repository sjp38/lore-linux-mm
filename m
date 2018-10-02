Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 95C9B6B0278
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 10:59:33 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c26-v6so1424269eda.7
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 07:59:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x9-v6si759230edm.375.2018.10.02.07.59.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 07:59:32 -0700 (PDT)
Date: Tue, 2 Oct 2018 16:59:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] migration/mm: Add WARN_ON to try_offline_node
Message-ID: <20181002145922.GZ18290@dhcp22.suse.cz>
References: <20181001185616.11427.35521.stgit@ltcalpine2-lp9.aus.stglabs.ibm.com>
 <20181001202724.GL18290@dhcp22.suse.cz>
 <bdbca329-7d35-0535-1737-94a06a19ae28@linux.vnet.ibm.com>
 <df95f828-1963-d8b9-ab58-6d29d2d152d2@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <df95f828-1963-d8b9-ab58-6d29d2d152d2@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Bringmann <mwb@linux.vnet.ibm.com>
Cc: Tyrel Datwyler <tyreld@linux.vnet.ibm.com>, Thomas Falcon <tlfalcon@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Mathieu Malaterre <malat@debian.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Nicholas Piggin <npiggin@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Juliet Kim <minkim@us.ibm.com>, Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>

On Tue 02-10-18 09:51:40, Michael Bringmann wrote:
[...]
> When the device-tree affinity attributes have changed for memory,
> the 'nid' affinity calculated points to a different node for the
> memory block than the one used to install it, previously on the
> source system.  The newly calculated 'nid' affinity may not yet
> be initialized on the target system.  The current memory tracking
> mechanisms do not record the node to which a memory block was
> associated when it was added.  Nathan is looking at adding this
> feature to the new implementation of LMBs, but it is not there
> yet, and won't be present in earlier kernels without backporting a
> significant number of changes.

Then the patch you have proposed here just papers over a real issue, no?
IIUC then you simply do not remove the memory if you lose the race.
-- 
Michal Hocko
SUSE Labs
