Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2EE016B000D
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 13:14:29 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u63-v6so13254327oia.8
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:14:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 201-v6sor15603167oib.294.2018.06.11.10.14.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Jun 2018 10:14:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <29908ce4-a8cf-bda6-4952-86c0afc3a9a2@linux.vnet.ibm.com>
References: <152850182079.38390.8280340535691965744.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152850183221.38390.15042297366983937566.stgit@dwillia2-desk3.amr.corp.intel.com>
 <29908ce4-a8cf-bda6-4952-86c0afc3a9a2@linux.vnet.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 11 Jun 2018 10:14:27 -0700
Message-ID: <CAPcyv4iAHbRgDXjPy2tVSuP1uqRAFNgNTfOpNUdyDSGMm3AyRQ@mail.gmail.com>
Subject: Re: [PATCH v4 02/12] device-dax: Cleanup vm_fault de-reference chains
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>

On Mon, Jun 11, 2018 at 10:12 AM, Laurent Dufour
<ldufour@linux.vnet.ibm.com> wrote:
> On 09/06/2018 01:50, Dan Williams wrote:
>> Define a local 'vma' variable rather than repetitively de-referencing
>> the passed in 'struct vm_fault *' instance.
>
> Hi Dan,
>
> Why is this needed ?
>
> I can't see the real benefit, having the vma deferenced from the vm_fault
> structure is not obfuscating the code and it eases to follow the use of vmf->vma.
>
> Am I missing something ?

No, and now that I take another look it's just noise. I'll drop it.

Thanks for the poke.
