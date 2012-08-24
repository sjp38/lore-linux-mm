Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 8F9FC6B007B
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 12:12:56 -0400 (EDT)
Date: Fri, 24 Aug 2012 16:12:55 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] slub: rename cpu_partial to max_cpu_object
In-Reply-To: <1345824303-30292-1-git-send-email-js1304@gmail.com>
Message-ID: <0000013959685cfc-8f8f9570-98ba-4dd5-b2a5-25faba405d79-000000@email.amazonses.com>
References: <Yes> <1345824303-30292-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 25 Aug 2012, Joonsoo Kim wrote:

> cpu_partial of kmem_cache struct is a bit awkward.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
