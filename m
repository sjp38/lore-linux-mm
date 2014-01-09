Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id BB2D16B0036
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 21:26:28 -0500 (EST)
Received: by mail-yh0-f44.google.com with SMTP id f64so698210yha.17
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 18:26:28 -0800 (PST)
Received: from mail-gg0-x22f.google.com (mail-gg0-x22f.google.com [2607:f8b0:4002:c02::22f])
        by mx.google.com with ESMTPS id q66si2975829yhm.229.2014.01.08.18.26.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 18:26:28 -0800 (PST)
Received: by mail-gg0-f175.google.com with SMTP id c2so26839ggn.6
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 18:26:27 -0800 (PST)
Date: Wed, 8 Jan 2014 18:26:24 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] mm: prevent set a value less than 0 to min_free_kbytes
In-Reply-To: <20140108084242.GA10485@localhost.localdomain>
Message-ID: <alpine.DEB.2.02.1401081825470.15616@chino.kir.corp.google.com>
References: <20140108084242.GA10485@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Han Pingtian <hanpt@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave.hansen@intel.com>

On Wed, 8 Jan 2014, Han Pingtian wrote:

> If echo -1 > /proc/vm/sys/min_free_kbytes, the system will hang.
> Changing proc_dointvec() to proc_dointvec_minmax() in the
> min_free_kbytes_sysctl_handler() can prevent this to happen.
> 
> Signed-off-by: Han Pingtian <hanpt@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

Nice catch!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
