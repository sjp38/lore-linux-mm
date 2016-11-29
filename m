Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8316B025E
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 12:57:27 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 83so268630017pfx.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 09:57:27 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id s15si324639pfg.96.2016.11.29.09.57.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 09:57:26 -0800 (PST)
Subject: Re: [RFC 1/4] mm: Define coherent device memory node
References: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1479824388-30446-2-git-send-email-khandual@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <692074f0-184f-e506-40a1-8fc078d1e706@intel.com>
Date: Tue, 29 Nov 2016 09:57:26 -0800
MIME-Version: 1.0
In-Reply-To: <1479824388-30446-2-git-send-email-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com

On 11/22/2016 06:19 AM, Anshuman Khandual wrote:
> @@ -393,6 +393,9 @@ enum node_states {
>  	N_MEMORY = N_HIGH_MEMORY,
>  #endif
>  	N_CPU,		/* The node has one or more cpus */
> +#ifdef CONFIG_COHERENT_DEVICE
> +	N_COHERENT_DEVICE,
> +#endif
>  	NR_NODE_STATES
>  };

Don't we really want this to be N_MEMORY_ISOLATED?  Or, better yet,
N_MEMORY_UNISOLATED so that we can just drop the bitmap in for N_MEMORY
and not have to do any bit manipulation operations at runtime.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
