Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C46DE8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:59:55 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o17so8681101pgi.14
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 07:59:55 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id c76si13616734pga.70.2019.01.11.07.59.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 07:59:54 -0800 (PST)
Date: Fri, 11 Jan 2019 08:58:28 -0700
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCHv3 07/13] node: Add heterogenous memory access attributes
Message-ID: <20190111155828.GD21095@localhost.localdomain>
References: <20190109174341.19818-1-keith.busch@intel.com>
 <20190109174341.19818-8-keith.busch@intel.com>
 <87y37sit8x.fsf@linux.ibm.com>
 <20190110173016.GC21095@localhost.localdomain>
 <20190111113238.000068b0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190111113238.000068b0@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Fri, Jan 11, 2019 at 11:32:38AM +0000, Jonathan Cameron wrote:
> On Thu, 10 Jan 2019 10:30:17 -0700
> Keith Busch <keith.busch@intel.com> wrote:
> > I am not aware of a real platform that has an initiator-target pair with
> > better latency but worse bandwidth than any different initiator paired to
> > the same target. If such a thing exists and a subsystem wants to report
> > that, you can register any arbitrary number of groups or classes and
> > rank them according to how you want them presented.
> > 
> 
> It's certainly possible if you are trading off against pin count by going
> out of the soc on a serial bus for some large SCM pool and also have a local
> SCM pool on a ddr 'like' bus or just ddr on fairly small number of channels
> (because some one didn't put memory on all of them).
> We will see this fairly soon in production parts.
> 
> So need an 'ordering' choice for this circumstance that is predictable.

As long as the reported memory target access attributes are accurate for
the initiator nodes listed under an access class, I'm not sure that it
matters what order you use. All the information needed to make a choice
on which pair to use is available, and the order is just an implementation
specific decision.
