Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 848ED6B002B
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 11:06:06 -0500 (EST)
Date: Thu, 27 Dec 2012 16:06:05 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: assign refcount for kmalloc_caches
In-Reply-To: <1356449082-3016-1-git-send-email-js1304@gmail.com>
Message-ID: <0000013bdd1d06aa-03085f43-6fa4-41dd-86aa-f0bf152e2851-000000@email.amazonses.com>
References: <CAAvDA15U=KCOujRYA5k3YkvC9Z=E6fcG5hopPUJNgULYj_MAJw@mail.gmail.com> <1356449082-3016-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Paul Hargrove <phhargrove@lbl.gov>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 26 Dec 2012, Joonsoo Kim wrote:

> This patch assign initial refcount 1 to kmalloc_caches, so fix this
> errornous situtation.

Ok Only for 3.7:

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
