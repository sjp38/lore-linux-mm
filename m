Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id CAB506B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 12:00:09 -0500 (EST)
Date: Fri, 22 Feb 2013 17:00:08 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] slub: correctly bootstrap boot caches
In-Reply-To: <alpine.DEB.2.02.1302221034380.7600@gentwo.org>
Message-ID: <0000013d02d8ff60-45eb2a10-d2fd-4011-b849-0e51aeb47f79-000000@email.amazonses.com>
References: <1361550000-14173-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.02.1302221034380.7600@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>

An earlier fix to this is available here:

https://patchwork.kernel.org/patch/1975301/

and

https://lkml.org/lkml/2013/1/15/55

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
