Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 1510E6B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 12:01:11 -0500 (EST)
Date: Fri, 22 Feb 2013 17:01:09 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] slub: correctly bootstrap boot caches
In-Reply-To: <alpine.DEB.2.02.1302221057430.7600@gentwo.org>
Message-ID: <0000013d02d9ee83-9b41b446-ee42-4498-863e-33b3175c007c-000000@email.amazonses.com>
References: <1361550000-14173-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.02.1302221034380.7600@gentwo.org> <alpine.DEB.2.02.1302221057430.7600@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>

Argh. This one was the final version:

https://patchwork.kernel.org/patch/2009521/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
