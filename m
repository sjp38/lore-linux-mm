Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 87AC96B0037
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 18:30:51 -0500 (EST)
Received: by mail-yh0-f41.google.com with SMTP id f11so3466506yha.0
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 15:30:51 -0800 (PST)
Received: from mail-yh0-x22c.google.com (mail-yh0-x22c.google.com [2607:f8b0:4002:c01::22c])
        by mx.google.com with ESMTPS id y62si22041863yhc.294.2013.11.25.15.30.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 15:30:50 -0800 (PST)
Received: by mail-yh0-f44.google.com with SMTP id f64so3497574yha.31
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 15:30:50 -0800 (PST)
Date: Mon, 25 Nov 2013 15:30:47 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] mm, mempolicy: silence gcc warning
In-Reply-To: <20131125123108.79c80eb59c2b1bc41c879d9e@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1311251529260.5495@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1311121811310.29891@chino.kir.corp.google.com> <20131120141534.06ea091ca53b1dec60ace63d@linux-foundation.org> <CAHGf_=ooNHx=2HeUDGxrZFma-6YRvL42ViDMkSOqLOffk8MVsw@mail.gmail.com>
 <20131125123108.79c80eb59c2b1bc41c879d9e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Fengguang Wu <fengguang.wu@intel.com>, Kees Cook <keescook@chromium.org>, Rik van Riel <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, 25 Nov 2013, Andrew Morton wrote:

> > > It worries me that the CONFIG_NUMA=n version of mpol_to_str() doesn't
> > > stick a '\0' into *buffer.  Hopefully it never gets called...
> > 
> > Don't worry. It never happens. Currently, all of caller depend on CONFIG_NUMA.
> > However it would be nice if CONFIG_NUMA=n version of mpol_to_str() is
> > implemented
> > more carefully. I don't know who's mistake.
> 
> Put a BUG() in there?
> 

Why make it a fatal runtime error when it can simply be a compile time 
error since calling mpol_to_str() without CONFIG_NUMA is unnecessary?  
There wouldn't be a mempolicy to convert, the struct has no fields in such 
a configuration.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
