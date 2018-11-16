Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA5BF6B0A7B
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 11:55:22 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id k14-v6so17556072pls.21
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 08:55:22 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id x10si30052805pgl.209.2018.11.16.08.55.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 08:55:21 -0800 (PST)
Subject: Re: [PATCH 0/7] ACPI HMAT memory sysfs representation
References: <20181114224902.12082-1-keith.busch@intel.com>
 <1ed406b2-b85f-8e02-1df0-7c39aa21eca9@arm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <4ea6e80f-80ba-6992-8aa0-5c2d88996af7@intel.com>
Date: Fri, 16 Nov 2018 08:55:20 -0800
MIME-Version: 1.0
In-Reply-To: <1ed406b2-b85f-8e02-1df0-7c39aa21eca9@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>, Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dan Williams <dan.j.williams@intel.com>

On 11/15/18 10:27 PM, Anshuman Khandual wrote:
> Not able to see the patches from this series either on the list or on the
> archive (https://lkml.org/lkml/2018/11/15/331). IIRC last time we discussed
> about this and the concern which I raised was in absence of a broader NUMA
> rework for multi attribute memory it might not a good idea to settle down
> and freeze sysfs interface for the user space. 

This *is* the broader NUMA rework.  I think it's just a bit more
incremental that what you originally had in mind.

Did you have an alternative for how you wanted this to look?
