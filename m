Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A3B7F6B000D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 19:41:36 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id i22-v6so13702095pfj.1
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 16:41:36 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id w8-v6si26491615plz.213.2018.11.14.16.41.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 16:41:35 -0800 (PST)
Subject: Re: [PATCH 5/7] doc/vm: New documentation for memory cache
References: <20181114224921.12123-2-keith.busch@intel.com>
 <20181114224921.12123-6-keith.busch@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <c86b7a76-fff1-0b15-163f-75bdf732ce6a@intel.com>
Date: Wed, 14 Nov 2018 16:41:35 -0800
MIME-Version: 1.0
In-Reply-To: <20181114224921.12123-6-keith.busch@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dan Williams <dan.j.williams@intel.com>

On 11/14/18 2:49 PM, Keith Busch wrote:
> +	# tree sys/devices/system/node/node0/cache/
> +	/sys/devices/system/node/node0/cache/
> +	|-- index1
> +	|   |-- associativity
> +	|   |-- level
> +	|   |-- line_size
> +	|   |-- size
> +	|   `-- write_policy

Whoops, and here it is...
