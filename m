Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id AC8C16B00EB
	for <linux-mm@kvack.org>; Thu, 17 May 2012 12:07:55 -0400 (EDT)
Date: Thu, 17 May 2012 11:07:53 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/4] slub: use __SetPageSlab function to set PG_slab
 flag
In-Reply-To: <1337269668-4619-4-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1205171107360.5144@router.home>
References: <1337269668-4619-1-git-send-email-js1304@gmail.com> <1337269668-4619-4-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 18 May 2012, Joonsoo Kim wrote:

> To set page-flag, using SetPageXXXX() and __SetPageXXXX() is more
> understandable and maintainable. So change it.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
