Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A5AC86B0005
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 13:02:17 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e16-v6so4833477pfn.5
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 10:02:17 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id w16-v6si54516010plq.141.2018.06.07.10.02.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 10:02:15 -0700 (PDT)
Date: Thu, 7 Jun 2018 10:02:14 -0700
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH v3 08/12] x86/memory_failure: Introduce {set,
 clear}_mce_nospec()
Message-ID: <20180607170214.GA21636@agluck-desk>
References: <152815389835.39010.13253559944508110923.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152815394224.39010.16927947197432406234.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAPcyv4jHV+2esMsoP-zDQ_kOCuWawN=V09nWYKuR7vht28p0=w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jHV+2esMsoP-zDQ_kOCuWawN=V09nWYKuR7vht28p0=w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, linux-edac@vger.kernel.org, X86 ML <x86@kernel.org>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>

On Wed, Jun 06, 2018 at 09:42:28PM -0700, Dan Williams wrote:
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > Cc: Ingo Molnar <mingo@redhat.com>
> > Cc: "H. Peter Anvin" <hpa@zytor.com>
> > Cc: Tony Luck <tony.luck@intel.com>
> 
> Tony, safe to assume you are ok with this patch now that the
> decoy_addr approach is back?
> 

Yes. s/Cc/Acked-by/ for my line above.

-Tony
