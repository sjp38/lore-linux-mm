Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 19F6F6B0032
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 06:31:01 -0500 (EST)
Received: by wevm14 with SMTP id m14so9653472wev.13
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 03:31:00 -0800 (PST)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com. [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id bp6si723641wjb.180.2015.02.26.03.30.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Feb 2015 03:30:59 -0800 (PST)
Received: by wggy19 with SMTP id y19so9716920wgg.10
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 03:30:58 -0800 (PST)
Date: Thu, 26 Feb 2015 12:30:54 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v8 7/7] x86, mm: Add set_memory_wt() for WT
Message-ID: <20150226113054.GA4191@gmail.com>
References: <1424823301-30927-1-git-send-email-toshi.kani@hp.com>
 <1424823301-30927-8-git-send-email-toshi.kani@hp.com>
 <20150225072228.GA13061@gmail.com>
 <1424877601.17007.108.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1424877601.17007.108.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com


* Toshi Kani <toshi.kani@hp.com> wrote:

> On Wed, 2015-02-25 at 08:22 +0100, Ingo Molnar wrote:
> > * Toshi Kani <toshi.kani@hp.com> wrote:
> > 
> > > +int set_pages_array_wt(struct page **pages, int addrinarray)
> > > +{
> > > +	return _set_pages_array(pages, addrinarray, _PAGE_CACHE_MODE_WT);
> > > +}
> > > +EXPORT_SYMBOL(set_pages_array_wt);
> > 
> > So by default we make new APIs EXPORT_SYMBOL_GPL(): we 
> > don't want proprietary modules mucking around with new code 
> > PAT interfaces, we only want modules we can analyze and fix 
> > in detail.
> 
> Right.  I have one question for this case.  This 
> set_pages_array_wt() extends the set_pages_array_xx() 
> family, which are all exported with EXPORT_SYMBOL() 
> today.  In this case, should we keep them exported in the 
> consistent manner, or should we still use GPL when adding 
> a new one?

Still keep it GPL, it's a new API that old modules 
obviously don't use.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
