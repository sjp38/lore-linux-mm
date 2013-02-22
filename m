Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 01C4E6B0006
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 12:23:30 -0500 (EST)
Date: Fri, 22 Feb 2013 17:23:28 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] slub: correctly bootstrap boot caches
In-Reply-To: <5127A607.3040603@parallels.com>
Message-ID: <0000013d02ee5bf7-a2d47cfc-64fb-4faa-b92e-e567aeb6b587-000000@email.amazonses.com>
References: <1361550000-14173-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.02.1302221034380.7600@gentwo.org> <alpine.DEB.2.02.1302221057430.7600@gentwo.org> <0000013d02d9ee83-9b41b446-ee42-4498-863e-33b3175c007c-000000@email.amazonses.com>
 <5127A607.3040603@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>

On Fri, 22 Feb 2013, Glauber Costa wrote:

> On 02/22/2013 09:01 PM, Christoph Lameter wrote:
> > Argh. This one was the final version:
> >
> > https://patchwork.kernel.org/patch/2009521/
> >
>
> It seems it would work. It is all the same to me.
> Which one do you prefer?

Flushing seems to be simpler and less code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
