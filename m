Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB5C6B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 10:20:36 -0500 (EST)
Received: by padfb1 with SMTP id fb1so5919890pad.8
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 07:20:36 -0800 (PST)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id xu8si6731667pbc.86.2015.02.25.07.20.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Feb 2015 07:20:35 -0800 (PST)
Message-ID: <1424877601.17007.108.camel@misato.fc.hp.com>
Subject: Re: [PATCH v8 7/7] x86, mm: Add set_memory_wt() for WT
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 25 Feb 2015 08:20:01 -0700
In-Reply-To: <20150225072228.GA13061@gmail.com>
References: <1424823301-30927-1-git-send-email-toshi.kani@hp.com>
	 <1424823301-30927-8-git-send-email-toshi.kani@hp.com>
	 <20150225072228.GA13061@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com

On Wed, 2015-02-25 at 08:22 +0100, Ingo Molnar wrote:
> * Toshi Kani <toshi.kani@hp.com> wrote:
> 
> > +int set_pages_array_wt(struct page **pages, int addrinarray)
> > +{
> > +	return _set_pages_array(pages, addrinarray, _PAGE_CACHE_MODE_WT);
> > +}
> > +EXPORT_SYMBOL(set_pages_array_wt);
> 
> So by default we make new APIs EXPORT_SYMBOL_GPL(): we 
> don't want proprietary modules mucking around with new code 
> PAT interfaces, we only want modules we can analyze and fix 
> in detail.

Right.  I have one question for this case.  This set_pages_array_wt()
extends the set_pages_array_xx() family, which are all exported with
EXPORT_SYMBOL() today.  In this case, should we keep them exported in
the consistent manner, or should we still use GPL when adding a new one?

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
