Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id B38336B006E
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 09:45:28 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id vb8so11201648obc.12
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 06:45:28 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id fm4si547753obb.52.2015.02.26.06.45.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Feb 2015 06:45:27 -0800 (PST)
Message-ID: <1424961893.17007.139.camel@misato.fc.hp.com>
Subject: Re: [PATCH v8 7/7] x86, mm: Add set_memory_wt() for WT
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 26 Feb 2015 07:44:53 -0700
In-Reply-To: <20150226113054.GA4191@gmail.com>
References: <1424823301-30927-1-git-send-email-toshi.kani@hp.com>
	 <1424823301-30927-8-git-send-email-toshi.kani@hp.com>
	 <20150225072228.GA13061@gmail.com>
	 <1424877601.17007.108.camel@misato.fc.hp.com>
	 <20150226113054.GA4191@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com

On Thu, 2015-02-26 at 12:30 +0100, Ingo Molnar wrote:
> * Toshi Kani <toshi.kani@hp.com> wrote:
> 
> > On Wed, 2015-02-25 at 08:22 +0100, Ingo Molnar wrote:
> > > * Toshi Kani <toshi.kani@hp.com> wrote:
> > > 
> > > > +int set_pages_array_wt(struct page **pages, int addrinarray)
> > > > +{
> > > > +	return _set_pages_array(pages, addrinarray, _PAGE_CACHE_MODE_WT);
> > > > +}
> > > > +EXPORT_SYMBOL(set_pages_array_wt);
> > > 
> > > So by default we make new APIs EXPORT_SYMBOL_GPL(): we 
> > > don't want proprietary modules mucking around with new code 
> > > PAT interfaces, we only want modules we can analyze and fix 
> > > in detail.
> > 
> > Right.  I have one question for this case.  This 
> > set_pages_array_wt() extends the set_pages_array_xx() 
> > family, which are all exported with EXPORT_SYMBOL() 
> > today.  In this case, should we keep them exported in the 
> > consistent manner, or should we still use GPL when adding 
> > a new one?
> 
> Still keep it GPL, it's a new API that old modules 
> obviously don't use.

Got it. Thanks for the clarification.
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
