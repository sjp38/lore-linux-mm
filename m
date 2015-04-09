Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id CEBAD6B0038
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 16:50:28 -0400 (EDT)
Received: by paboj16 with SMTP id oj16so161213275pab.0
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 13:50:28 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p1si23061173pds.164.2015.04.09.13.50.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Apr 2015 13:50:28 -0700 (PDT)
Date: Thu, 9 Apr 2015 13:50:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1 linux-next] slob: statify slob_alloc_node() and
 remove symbol
Message-Id: <20150409135026.d5d49573f3495c6dfa57ef06@linux-foundation.org>
In-Reply-To: <1428612247-319-1-git-send-email-fabf@skynet.be>
References: <1428612247-319-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fabian Frederick <fabf@skynet.be>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

On Thu,  9 Apr 2015 22:44:07 +0200 Fabian Frederick <fabf@skynet.be> wrote:

> slob_alloc_node() is only used in slob.c
> This patch removes EXPORT_SYMBOL and statify function
> 

Call me old-fashioned, but I refuse to make "statify" a word ;)


: From: Fabian Frederick <fabf@skynet.be>
: Subject: slob: make slob_alloc_node() static and remove EXPORT_SYMBOL()
: 
: slob_alloc_node() is only used in slob.c.  Remove the EXPORT_SYMBOL and
: make slob_alloc_node() static.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
