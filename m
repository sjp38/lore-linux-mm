Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E6BE6B6FBA
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 11:56:59 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id y8so9297681pgq.12
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 08:56:59 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id d32si18185152pla.136.2018.12.04.08.56.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 08:56:57 -0800 (PST)
Date: Tue, 4 Dec 2018 09:54:11 -0700
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCH 1/7] node: Link memory nodes to their compute nodes
Message-ID: <20181204165411.GA16666@localhost.localdomain>
References: <20181114224921.12123-2-keith.busch@intel.com>
 <20181115135710.GD19286@bombadil.infradead.org>
 <20181115145920.GG11416@localhost.localdomain>
 <20181115203654.GA28246@bombadil.infradead.org>
 <20181116183254.GD14630@localhost.localdomain>
 <87sgzd5mca.fsf@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87sgzd5mca.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Tue, Dec 04, 2018 at 09:13:33PM +0530, Aneesh Kumar K.V wrote:
> Keith Busch <keith.busch@intel.com> writes:
> >
> > Indeed, that particular example is out of scope for this series. The
> > first objective is to aid a process running in node B's CPUs to allocate
> > memory in B1. Anything that crosses QPI are their own.
> 
> But if you can extrapolate how such a system can possibly be expressed
> using what is propsed here, it would help in reviewing this.

Expressed to what end? This proposal is not trying to express anything
other than the best possible pairings because that is the most common
information applications will want to know.

> Also how
> do we intent to express the locality of memory w.r.t to other computing
> units like GPU/FPGA?

The HMAT parsing at the end of the series provides an example for how
others may use the proposed interfaces.

> I understand that this is looked at as ACPI HMAT in sysfs format.
> But as mentioned by others in this thread, if we don't do this platform
> and device independent way, we can have application portability issues
> going forward?

Only the last patch is specific to HMAT. If there are other ways to get
the same attributes, then those drivers or subsystems may also register
them with these new kernel interfaces.
