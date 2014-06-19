Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1F3F06B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 11:01:08 -0400 (EDT)
Received: by mail-qa0-f50.google.com with SMTP id m5so2085973qaj.9
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 08:01:07 -0700 (PDT)
Received: from mail-qg0-x233.google.com (mail-qg0-x233.google.com [2607:f8b0:400d:c04::233])
        by mx.google.com with ESMTPS id b35si6681336qgb.79.2014.06.19.08.01.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 08:01:07 -0700 (PDT)
Received: by mail-qg0-f51.google.com with SMTP id z60so2194368qgd.38
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 08:01:07 -0700 (PDT)
Date: Thu, 19 Jun 2014 11:01:04 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: percpu: micro-optimize round-to-even
Message-ID: <20140619150104.GH26904@htj.dyndns.org>
References: <1403172149-25353-1-git-send-email-linux@rasmusvillemoes.dk>
 <20140619132536.GF11042@htj.dyndns.org>
 <alpine.DEB.2.11.1406190925430.2785@gentwo.org>
 <20140619143458.GF26904@htj.dyndns.org>
 <alpine.DEB.2.11.1406190957030.2785@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1406190957030.2785@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 19, 2014 at 09:59:18AM -0500, Christoph Lameter wrote:
> On Thu, 19 Jun 2014, Tejun Heo wrote:
> 
> > Indeed, a patch?
> 
> Subject: percpu: Use ALIGN macro instead of hand coding alignment calculation
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Applied to percpu/for-3.17.  Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
