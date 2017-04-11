Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E3D756B03BB
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 15:39:53 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id a80so729892wrc.19
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 12:39:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m10si640093wmf.119.2017.04.11.12.39.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Apr 2017 12:39:52 -0700 (PDT)
Date: Tue, 11 Apr 2017 21:39:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Add additional consistency check
Message-ID: <20170411193948.GA29154@dhcp22.suse.cz>
References: <20170411134618.GN6729@dhcp22.suse.cz>
 <CAGXu5j+EVCU1WrjpMmr0PYW2N_RzF0tLUgFumDR+k4035uqthA@mail.gmail.com>
 <20170411141956.GP6729@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704111110130.24725@east.gentwo.org>
 <20170411164134.GA21171@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704111254390.25069@east.gentwo.org>
 <20170411183035.GD21171@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704111335540.6544@east.gentwo.org>
 <20170411185555.GE21171@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704111356460.6911@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1704111356460.6911@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 11-04-17 13:59:44, Cristopher Lameter wrote:
> On Tue, 11 Apr 2017, Michal Hocko wrote:
> 
> > I didn't say anything like that. Hence the proposed patch which still
> > needs some more thinking and evaluation.
> 
> This patch does not even affect kfree().

Ehm? Are we even talking about the same thing? The whole discussion was
to catch invalid pointers to _kfree_ and why BUG* is not the best way to
handle that. 

> Could you start another
> discussion thread where you discuss your suggestions for the changes in
> the allocators and how we could go about this?

I presume Kees will pursue
http://lkml.kernel.org/r/20170411141956.GP6729@dhcp22.suse.cz or
something along those lines.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
