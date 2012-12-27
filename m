Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id BA06F6B002B
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 11:00:25 -0500 (EST)
Date: Thu, 27 Dec 2012 16:00:24 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: PageHead macro broken?
In-Reply-To: <CAEDV+gLg838ua2Bgu0sTRjSAWYGPwELtH=ncoKPP-5t7_gxUYw@mail.gmail.com>
Message-ID: <0000013bdd17d2fd-5a694644-bcf1-4233-af7d-5c590940367d-000000@email.amazonses.com>
References: <CAEDV+gLg838ua2Bgu0sTRjSAWYGPwELtH=ncoKPP-5t7_gxUYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoffer Dall <cdall@cs.columbia.edu>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, clameter@sgi.com, Will Deacon <Will.Deacon@arm.com>, Steve Capper <Steve.Capper@arm.com>, "kvmarm@lists.cs.columbia.edu" <kvmarm@lists.cs.columbia.edu>

On Mon, 24 Dec 2012, Christoffer Dall wrote:

> I think I may have found an issue with the PageHead macro, which
> returns true for tail compound pages when CONFIG_PAGEFLAGS_EXTENDED is
> not defined.

Yep that all looks sane.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
