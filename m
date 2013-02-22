Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id D58E76B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 12:07:58 -0500 (EST)
Message-ID: <5127A607.3040603@parallels.com>
Date: Fri, 22 Feb 2013 21:08:23 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] slub: correctly bootstrap boot caches
References: <1361550000-14173-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.02.1302221034380.7600@gentwo.org> <alpine.DEB.2.02.1302221057430.7600@gentwo.org> <0000013d02d9ee83-9b41b446-ee42-4498-863e-33b3175c007c-000000@email.amazonses.com>
In-Reply-To: <0000013d02d9ee83-9b41b446-ee42-4498-863e-33b3175c007c-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun
 Heo <tj@kernel.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>

On 02/22/2013 09:01 PM, Christoph Lameter wrote:
> Argh. This one was the final version:
> 
> https://patchwork.kernel.org/patch/2009521/
> 

It seems it would work. It is all the same to me.
Which one do you prefer?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
