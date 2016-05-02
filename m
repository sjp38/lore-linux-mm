Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 76F926B0253
	for <linux-mm@kvack.org>; Mon,  2 May 2016 11:01:13 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id s63so79814351wme.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 08:01:13 -0700 (PDT)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id mb4si34535527wjb.202.2016.05.02.08.01.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 08:01:12 -0700 (PDT)
Received: by mail-wm0-x22f.google.com with SMTP id v200so23026391wmv.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 08:01:12 -0700 (PDT)
Date: Mon, 2 May 2016 18:01:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: pages are not freed from lru_add_pvecs after process
 termination
Message-ID: <20160502150109.GB24419@node.shutemov.name>
References: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
 <5720F2A8.6070406@intel.com>
 <572766A7.9090406@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <572766A7.9090406@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Dave Hansen <dave.hansen@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On Mon, May 02, 2016 at 04:39:35PM +0200, Vlastimil Babka wrote:
> On 04/27/2016 07:11 PM, Dave Hansen wrote:
> >6. Perhaps don't use the LRU pagevecs for large pages.  It limits the
> >    severity of the problem.
> 
> I think that makes sense. Being large already amortizes the cost per base
> page much more than pagevecs do (512 vs ~22 pages?).

We try to do this already, don't we? Any spefic case where we have THPs on
pagevecs?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
