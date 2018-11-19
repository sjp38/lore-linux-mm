Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A87AA6B1BB9
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 12:37:56 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id x7so957209pll.23
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 09:37:56 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id u11si6780617plq.287.2018.11.19.09.37.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 09:37:55 -0800 (PST)
Subject: Re: [PATCH 0/7] ACPI HMAT memory sysfs representation
References: <20181114224902.12082-1-keith.busch@intel.com>
 <1ed406b2-b85f-8e02-1df0-7c39aa21eca9@arm.com>
 <4ea6e80f-80ba-6992-8aa0-5c2d88996af7@intel.com>
 <b79804b0-32ee-03f9-fa62-a89684d46be6@arm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <c6abb754-0d82-8739-fe08-24e9402bae75@intel.com>
Date: Mon, 19 Nov 2018 09:37:51 -0800
MIME-Version: 1.0
In-Reply-To: <b79804b0-32ee-03f9-fa62-a89684d46be6@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>, Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dan Williams <dan.j.williams@intel.com>

On 11/18/18 9:44 PM, Anshuman Khandual wrote:
> IIUC NUMA re-work in principle involves these functional changes
> 
> 1. Enumerating compute and memory nodes in heterogeneous environment (short/medium term)

This patch set _does_ that, though.

> 2. Enumerating memory node attributes as seen from the compute nodes (short/medium term)

It does that as well (a subset at least).

It sounds like the subset that's being exposed is insufficient for yo
We did that because we think doing anything but a subset in sysfs will
just blow up sysfs:  MAX_NUMNODES is as high as 1024, so if we have 4
attributes, that's at _least_ 1024*1024*4 files if we expose *all*
combinations.

Do we agree that sysfs is unsuitable for exposing attributes in this manner?
