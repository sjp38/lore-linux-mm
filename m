Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 3964C6B0125
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 19:35:00 -0400 (EDT)
Date: Thu, 21 Jun 2012 16:34:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2012-06-21-16-20 uploaded
Message-Id: <20120621163458.89459d7a.akpm@linux-foundation.org>
In-Reply-To: <20120621232149.F0286A026A@akpm.mtv.corp.google.com>
References: <20120621232149.F0286A026A@akpm.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On Thu, 21 Jun 2012 16:21:49 -0700
akpm@linux-foundation.org wrote:

> The mm-of-the-moment snapshot 2012-06-21-16-20 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/

Exciting updates to http://www.ozlabs.org/~akpm/mmotm/mmotm-readme.txt:

: The directory http://www.ozlabs.org/~akpm/mmots/ (mm-of-the-second)
: contains daily snapshots of the -mm tree.  It is updated more frequently
: than mmotm, and is untested.

It takes me 1.5 hours to 1.5 days to do a -mm release, depending on how
many screwups people have been merging and sending.  This makes the
releases less frequent than I'd like.

So I will do daily dumps of the -mm patches into
http://www.ozlabs.org/~akpm/mmots/.  They are the same as the mmotm
patches (use the same script), except they will be unannounced and
untested.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
