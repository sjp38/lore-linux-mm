Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E667C6B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 10:39:39 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id s63so79335438wme.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 07:39:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x5si34478322wjf.206.2016.05.02.07.39.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 May 2016 07:39:38 -0700 (PDT)
Subject: Re: mm: pages are not freed from lru_add_pvecs after process
 termination
References: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
 <5720F2A8.6070406@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <572766A7.9090406@suse.cz>
Date: Mon, 2 May 2016 16:39:35 +0200
MIME-Version: 1.0
In-Reply-To: <5720F2A8.6070406@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On 04/27/2016 07:11 PM, Dave Hansen wrote:
> 6. Perhaps don't use the LRU pagevecs for large pages.  It limits the
>     severity of the problem.

I think that makes sense. Being large already amortizes the cost per 
base page much more than pagevecs do (512 vs ~22 pages?).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
