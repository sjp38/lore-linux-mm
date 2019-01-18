Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7A7178E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 08:16:19 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id e89so10004153pfb.17
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 05:16:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s36sor6743682pld.52.2019.01.18.05.16.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 Jan 2019 05:16:18 -0800 (PST)
Date: Sat, 19 Jan 2019 00:16:11 +1100
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCHv4 00/13] Heterogeneuos memory node attributes
Message-ID: <20190118131611.GG26056@350D>
References: <20190116175804.30196-1-keith.busch@intel.com>
 <20190117125821.GF26056@350D>
 <20190117154436.GB31543@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190117154436.GB31543@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Jan 17, 2019 at 08:44:37AM -0700, Keith Busch wrote:
> On Thu, Jan 17, 2019 at 11:58:21PM +1100, Balbir Singh wrote:
> > On Wed, Jan 16, 2019 at 10:57:51AM -0700, Keith Busch wrote:
> > > It had previously been difficult to describe these setups as memory
> > > rangers were generally lumped into the NUMA node of the CPUs. New
> > > platform attributes have been created and in use today that describe
> > > the more complex memory hierarchies that can be created.
> > > 
> > 
> > Could you please expand on this text -- how are these attributes
> > exposed/consumed by both the kernel and user space?
> > 
> > > This series' objective is to provide the attributes from such systems
> > > that are useful for applications to know about, and readily usable with
> > > existing tools and libraries.
> > 
> > I presume these tools and libraries are numactl and mbind()?
> 
> Yes, and numactl is used the examples provided in both changelogs and
> documentation in this series. Do you want to see those in the cover
> letter as well?

Not really, I was just reading through the cover letter and was curious

Balbir Singh.
