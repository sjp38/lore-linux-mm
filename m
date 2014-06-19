Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3C12C6B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 10:35:03 -0400 (EDT)
Received: by mail-qa0-f50.google.com with SMTP id m5so1998165qaj.23
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 07:35:02 -0700 (PDT)
Received: from mail-qc0-x22f.google.com (mail-qc0-x22f.google.com [2607:f8b0:400d:c01::22f])
        by mx.google.com with ESMTPS id 40si6606930qgf.28.2014.06.19.07.35.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 07:35:02 -0700 (PDT)
Received: by mail-qc0-f175.google.com with SMTP id i8so2209090qcq.20
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 07:35:02 -0700 (PDT)
Date: Thu, 19 Jun 2014 10:34:58 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: percpu: micro-optimize round-to-even
Message-ID: <20140619143458.GF26904@htj.dyndns.org>
References: <1403172149-25353-1-git-send-email-linux@rasmusvillemoes.dk>
 <20140619132536.GF11042@htj.dyndns.org>
 <alpine.DEB.2.11.1406190925430.2785@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1406190925430.2785@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 19, 2014 at 09:29:52AM -0500, Christoph Lameter wrote:
> > > -	if (unlikely(size & 1))
> > > -		size++;
> > > +	size += size & 1;
> >
> > I'm not gonna apply this.  This isn't that hot a path.  It's not
> > worthwhile to micro optimize code like this.
> 
> Dont we have an ALIGN() macro for this?

Indeed, a patch?

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
