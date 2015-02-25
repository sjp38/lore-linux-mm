Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5BF846B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 02:22:35 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id bs8so2769362wib.4
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 23:22:34 -0800 (PST)
Received: from mail-wg0-x235.google.com (mail-wg0-x235.google.com. [2a00:1450:400c:c00::235])
        by mx.google.com with ESMTPS id c6si71576354wje.211.2015.02.24.23.22.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 23:22:33 -0800 (PST)
Received: by wggy19 with SMTP id y19so1703834wgg.13
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 23:22:33 -0800 (PST)
Date: Wed, 25 Feb 2015 08:22:28 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v8 7/7] x86, mm: Add set_memory_wt() for WT
Message-ID: <20150225072228.GA13061@gmail.com>
References: <1424823301-30927-1-git-send-email-toshi.kani@hp.com>
 <1424823301-30927-8-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1424823301-30927-8-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com


* Toshi Kani <toshi.kani@hp.com> wrote:

> +int set_pages_array_wt(struct page **pages, int addrinarray)
> +{
> +	return _set_pages_array(pages, addrinarray, _PAGE_CACHE_MODE_WT);
> +}
> +EXPORT_SYMBOL(set_pages_array_wt);

So by default we make new APIs EXPORT_SYMBOL_GPL(): we 
don't want proprietary modules mucking around with new code 
PAT interfaces, we only want modules we can analyze and fix 
in detail.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
