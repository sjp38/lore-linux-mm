Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E02FC8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 10:54:42 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id s71so16280320pfi.22
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 07:54:42 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id n128si660227pga.423.2019.01.14.07.54.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 07:54:41 -0800 (PST)
Date: Mon, 14 Jan 2019 08:53:11 -0700
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCHv3 08/13] Documentation/ABI: Add node performance
 attributes
Message-ID: <20190114155310.GB22829@localhost.localdomain>
References: <20190109174341.19818-1-keith.busch@intel.com>
 <20190109174341.19818-9-keith.busch@intel.com>
 <20190113231012.GD18710@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190113231012.GD18710@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Mon, Jan 14, 2019 at 12:10:12AM +0100, Pavel Machek wrote:
> On Wed 2019-01-09 10:43:36, Keith Busch wrote:
> > +		This node's write latency in nanosecondss available to memory
> > +		initiators in nodes found in this class's
> > initiators_nodelist.
> 
> "nanosecondss", twice.

Thanks for the catch, fixed up for the next rev.
