Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 235EA6B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 04:17:14 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id p66so52149688wmp.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 01:17:14 -0800 (PST)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id w191si24098731wme.107.2015.12.14.01.17.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 01:17:13 -0800 (PST)
Received: by mail-wm0-x22a.google.com with SMTP id n186so35767579wmn.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 01:17:12 -0800 (PST)
Date: Mon, 14 Dec 2015 10:17:09 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/6] mm: Add a vm_special_mapping .fault method
Message-ID: <20151214091709.GA29878@gmail.com>
References: <cover.1449803537.git.luto@kernel.org>
 <4e911d2752d3b9e52d7496e46b389fc630cdc3a8.1449803537.git.luto@kernel.org>
 <20151211142814.25cc806e3f5180d525ee807e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151211142814.25cc806e3f5180d525ee807e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@kernel.org>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> > +	} else {
> > +		struct vm_special_mapping *sm = vma->vm_private_data;
> > +
> > +		if (sm->fault)
> > +			return sm->fault(sm, vma, vmf);
> > +
> > +		pages = sm->pages;
> > +	}
> >  
> >  	for (pgoff = vmf->pgoff; pgoff && *pages; ++pages)
> >  		pgoff--;
> 
> Otherwise looks OK.  I'll assume this will be merged via an x86 tree.

Yeah, was hoping to be able to do that with your Acked-by.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
