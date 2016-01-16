Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A5B7B828DF
	for <linux-mm@kvack.org>; Sat, 16 Jan 2016 03:08:33 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id e65so130144830pfe.0
        for <linux-mm@kvack.org>; Sat, 16 Jan 2016 00:08:33 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id z26si22542482pfa.30.2016.01.16.00.08.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Jan 2016 00:08:32 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id 65so9429095pff.2
        for <linux-mm@kvack.org>; Sat, 16 Jan 2016 00:08:32 -0800 (PST)
Date: Sat, 16 Jan 2016 17:06:50 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v2] zsmalloc: fix migrate_zspage-zs_free race condition
Message-ID: <20160116080650.GB566@swordfish>
References: <1452843551-4464-1-git-send-email-junil0814.lee@lge.com>
 <20160115143434.GA25332@blaptop.local>
 <56991514.9000609@suse.cz>
 <20160116040913.GA566@swordfish>
 <5699F4C9.1070902@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5699F4C9.1070902@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Junil Lee <junil0814.lee@lge.com>, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (01/16/16 08:44), Vlastimil Babka wrote:
> On 16.1.2016 5:09, Sergey Senozhatsky wrote:
> > On (01/15/16 16:49), Vlastimil Babka wrote:
> > [..]
> >>
> >> Could you please also help making the changelog more clear?
> >>
> >>>
> >>>> +		free_obj |= BIT(HANDLE_PIN_BIT);
> >>>>  		record_obj(handle, free_obj);
> >>
> >> I think record_obj() should use WRITE_ONCE() or something like that.
> >> Otherwise the compiler is IMHO allowed to reorder this, i.e. first to assign
> >> free_obj to handle, and then add the PIN bit there.
> > 
> > good note.
> > 
> > ... or do both things in record_obj() (per Minchan)
> > 
> > 	record_obj(handle, obj)
> > 	{
> > 	        *(unsigned long)handle = obj & ~(1<<HANDLE_PIN_BIT);
> 
> Hmm but that's an unpin, not a pin? A mistake or I'm missing something?

I'm sure it's just a compose-in-mail-app typo.

	-ss

> Anyway the compiler can do the same thing here without a WRITE_ONCE().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
