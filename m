Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 380296B00F3
	for <linux-mm@kvack.org>; Thu, 17 May 2012 12:08:35 -0400 (EDT)
Date: Thu, 17 May 2012 11:08:32 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/4] slub: refactoring some code in slub
In-Reply-To: <1337269668-4619-1-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1205171108000.5144@router.home>
References: <1337269668-4619-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 18 May 2012, Joonsoo Kim wrote:

> Two patches were submitted 1 weeks ago, but doesn't receive ack or nack
> from MAINTAINER for slub. So I re-send these.

Could you combine the first two patches into one? They do the same thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
