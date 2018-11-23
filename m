Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5202E6B3269
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 14:21:03 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id g12-v6so16018111plo.14
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 11:21:03 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id d25si42630562pgd.88.2018.11.23.11.21.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 11:21:02 -0800 (PST)
Subject: Re: [PATCH 0/7] ACPI HMAT memory sysfs representation
References: <20181114224902.12082-1-keith.busch@intel.com>
 <1ed406b2-b85f-8e02-1df0-7c39aa21eca9@arm.com>
 <4ea6e80f-80ba-6992-8aa0-5c2d88996af7@intel.com>
 <b79804b0-32ee-03f9-fa62-a89684d46be6@arm.com>
 <c6abb754-0d82-8739-fe08-24e9402bae75@intel.com>
 <aae34dde-fa70-870a-9b74-fff9e385bfc9@arm.com>
 <f5315662-5c1a-68a3-4d04-21b4b5ca94b1@intel.com>
 <ac942498-8966-6a9b-0e55-c79ae167c679@arm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <9015e51a-3584-7bb2-cc5e-25b0ec8e5494@intel.com>
Date: Fri, 23 Nov 2018 11:21:00 -0800
MIME-Version: 1.0
In-Reply-To: <ac942498-8966-6a9b-0e55-c79ae167c679@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>, Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dan Williams <dan.j.williams@intel.com>

On 11/22/18 10:42 PM, Anshuman Khandual wrote:
> Are we willing to go in the direction for inclusion of a new system
> call, subset of it appears on sysfs etc ? My primary concern is not
> how the attribute information appears on the sysfs but lack of it's
> completeness.

A new system call makes total sense to me.  I have the same concern
about the completeness of what's exposed in sysfs, I just don't see a
_route_ to completeness with sysfs itself.  Thus, the minimalist
approach as a first step.
