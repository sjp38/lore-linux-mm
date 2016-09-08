Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 82D556B0038
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 16:24:54 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id k83so136549022pfa.2
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 13:24:54 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id h8si24852527paw.241.2016.09.08.13.24.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Sep 2016 13:24:53 -0700 (PDT)
Subject: Re: [PATCH V4] mm: Add sysfs interface to dump each node's zonelist
 information
References: <1473150666-3875-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1473302818-23974-1-git-send-email-khandual@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57D1C914.9090403@intel.com>
Date: Thu, 8 Sep 2016 13:24:52 -0700
MIME-Version: 1.0
In-Reply-To: <1473302818-23974-1-git-send-email-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org

On 09/07/2016 07:46 PM, Anshuman Khandual wrote:
> after memory or node hot[un]plug is desirable. This change adds one
> new sysfs interface (/sys/devices/system/memory/system_zone_details)
> which will fetch and dump this information.

Doesn't this violate the "one value per file" sysfs rule?  Does it
belong in debugfs instead?

I also really question the need to dump kernel addresses out, filtered
or not.  What's the point?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
