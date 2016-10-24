Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D6BB06B0262
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 13:09:28 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id i85so127450086pfa.5
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:09:28 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 19si16360249pgc.314.2016.10.24.10.09.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 10:09:28 -0700 (PDT)
Subject: Re: [RFC 1/8] mm: Define coherent device memory node
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1477283517-2504-2-git-send-email-khandual@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <580E4043.4090200@intel.com>
Date: Mon, 24 Oct 2016 10:09:23 -0700
MIME-Version: 1.0
In-Reply-To: <1477283517-2504-2-git-send-email-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

> +#ifdef CONFIG_COHERENT_DEVICE
> +#define node_cdm(nid)          (NODE_DATA(nid)->coherent_device)
> +#define set_cdm_isolation(nid) (node_cdm(nid) = 1)
> +#define clr_cdm_isolation(nid) (node_cdm(nid) = 0)
> +#define isolated_cdm_node(nid) (node_cdm(nid) == 1)
> +#else
> +#define set_cdm_isolation(nid) ()
> +#define clr_cdm_isolation(nid) ()
> +#define isolated_cdm_node(nid) (0)
> +#endif

FWIW, I think adding all this "cdm" gunk in the names is probably a bad
thing.

I can think of other memory types that are coherent, but
non-device-based that might want behavior like this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
