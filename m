Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id C20998E00D7
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 14:08:30 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id v64so10377178qka.5
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 11:08:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 33si704517qte.189.2019.01.25.11.08.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 11:08:29 -0800 (PST)
Date: Fri, 25 Jan 2019 14:08:22 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 0/5] [v4] Allow persistent memory to be used like normal
 RAM
Message-ID: <20190125190820.GC3237@redhat.com>
References: <20190124231441.37A4A305@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190124231441.37A4A305@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com, baiyaowei@cmss.chinamobile.com, tiwai@suse.de

On Thu, Jan 24, 2019 at 03:14:41PM -0800, Dave Hansen wrote:
> v3 spurred a bunch of really good discussion.  Thanks to everybody
> that made comments and suggestions!
> 
> I would still love some Acks on this from the folks on cc, even if it
> is on just the patch touching your area.
> 
> Note: these are based on commit d2f33c19644 in:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm.git libnvdimm-pending
> 
> Changes since v3:
>  * Move HMM-related resource warning instead of removing it
>  * Use __request_resource() directly instead of devm.
>  * Create a separate DAX_PMEM Kconfig option, complete with help text
>  * Update patch descriptions and cover letter to give a better
>    overview of use-cases and hardware where this might be useful.

This one looks good to me, i will give it a go on monday to
test against nouveau and HMM.

Cheers,
Jérôme
