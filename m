Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 509E46B0292
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 21:24:55 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id j32so10046028iod.15
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 18:24:55 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id m71si6344756ith.196.2017.08.09.18.24.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 18:24:53 -0700 (PDT)
Subject: Re: [PATCH RFC v2] Add /proc/pid/smaps_rollup
References: <20170808132554.141143-1-dancol@google.com>
 <20170810001557.147285-1-dancol@google.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <6d20ced6-a7ca-f4b9-81eb-e34517f97644@infradead.org>
Date: Wed, 9 Aug 2017 18:24:43 -0700
MIME-Version: 1.0
In-Reply-To: <20170810001557.147285-1-dancol@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Colascione <dancol@google.com>, linux-kernel@vger.kernel.org, timmurray@google.com, joelaf@google.com, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 08/09/2017 05:15 PM, Daniel Colascione wrote:
> 
> diff --git a/Documentation/ABI/testing/procfs-smaps_rollup b/Documentation/ABI/testing/procfs-smaps_rollup
> new file mode 100644
> index 000000000000..fd5a3699edf1
> --- /dev/null
> +++ b/Documentation/ABI/testing/procfs-smaps_rollup
> @@ -0,0 +1,34 @@
> +What:		/proc/pid/smaps_Rollup

        		          smaps_rollup

\although I would prefer smaps_summary. whatever.

> +Date:		August 2017
> +Contact:	Daniel Colascione <dancol@google.com>
> +Description:
> +		This file provides pre-summed memory information for a
> +		process.  The format is identical to /proc/pid/smaps,
> +		except instead of an entry for each VMA in a process,
> +		smaps_rollup has a single entry (tagged "[rollup]")
> +		for which each field is the sum of the corresponding
> +		fields from all the maps in /proc/pid/smaps.
> +		For more details, see the procfs man page.


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
