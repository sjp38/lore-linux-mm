Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id B3E0E8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 07:58:27 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id l9so5984064plt.7
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 04:58:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j1sor2108494plk.57.2019.01.17.04.58.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 04:58:26 -0800 (PST)
Date: Thu, 17 Jan 2019 23:58:21 +1100
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCHv4 00/13] Heterogeneuos memory node attributes
Message-ID: <20190117125821.GF26056@350D>
References: <20190116175804.30196-1-keith.busch@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190116175804.30196-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, Jan 16, 2019 at 10:57:51AM -0700, Keith Busch wrote:
> The series seems quite calm now. I've received some approvals of the
> on the proposal, and heard no objections on the new core interfaces.
> 
> Please let me know if there is anyone or group of people I should request
> and wait for a review. And if anyone reading this would like additional
> time as well before I post a potentially subsequent version, please let
> me know.
> 
> I also wanted to inquire on upstream strategy if/when all desired
> reviews are received. The series is spanning a few subsystems, so I'm
> not sure who's tree is the best candidate. I could see an argument for
> driver-core, acpi, or mm as possible paths. Please let me know if there's
> a more appropriate option or any other gating concerns.
> 
> == Changes from v3 ==
> 
>   I've fixed the documentation issues that have been raised for v3 
> 
>   Moved the hmat files according to Rafael's recommendation
> 
>   Added received Reviewed-by's
> 
> Otherwise this v4 is much the same as v3.
> 
> == Background ==
> 
> Platforms may provide multiple types of cpu attached system memory. The
> memory ranges for each type may have different characteristics that
> applications may wish to know about when considering what node they want
> their memory allocated from. 
> 
> It had previously been difficult to describe these setups as memory
> rangers were generally lumped into the NUMA node of the CPUs. New
> platform attributes have been created and in use today that describe
> the more complex memory hierarchies that can be created.
> 

Could you please expand on this text -- how are these attributes
exposed/consumed by both the kernel and user space?

> This series' objective is to provide the attributes from such systems
> that are useful for applications to know about, and readily usable with
> existing tools and libraries.

I presume these tools and libraries are numactl and mbind()?

Balbir Singh.
