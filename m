Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 699A36B04EC
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 19:08:06 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t193so3182410pgc.4
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 16:08:06 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id x1si3741822plm.825.2017.08.24.16.08.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 16:08:04 -0700 (PDT)
Subject: Re: [RFC PATCH v2 1/7] ktask: add documentation
References: <20170824205004.18502-1-daniel.m.jordan@oracle.com>
 <20170824205004.18502-2-daniel.m.jordan@oracle.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <ebada9e9-038c-71b5-2115-1693cd1e202e@infradead.org>
Date: Thu, 24 Aug 2017 16:07:56 -0700
MIME-Version: 1.0
In-Reply-To: <20170824205004.18502-2-daniel.m.jordan@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, mgorman@techsingularity.net, mhocko@kernel.org, mike.kravetz@oracle.com, pasha.tatashin@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com

On 08/24/2017 01:49 PM, Daniel Jordan wrote:
> Motivates and explains the ktask API for kernel clients.
> 
> Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> Reviewed-by: Steve Sistare <steven.sistare@oracle.com>
> Cc: Aaron Lu <aaron.lu@intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
> Cc: Tim Chen <tim.c.chen@intel.com>
> ---
>  Documentation/core-api/index.rst |   1 +
>  Documentation/core-api/ktask.rst | 104 +++++++++++++++++++++++++++++++++++++++
>  2 files changed, 105 insertions(+)
>  create mode 100644 Documentation/core-api/ktask.rst
> 
> diff --git a/Documentation/core-api/ktask.rst b/Documentation/core-api/ktask.rst
> new file mode 100644
> index 000000000000..cb4b0d87c8c6
> --- /dev/null
> +++ b/Documentation/core-api/ktask.rst
> @@ -0,0 +1,104 @@
> +============================================
> +ktask: parallelize cpu-intensive kernel work
> +============================================

Hi,

I would prefer to use CPU instead of cpu.
Otherwise, Reviewed-by: Randy Dunlap <rdunlap@infradead.org>


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
