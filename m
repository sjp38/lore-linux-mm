Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 57B506B0035
	for <linux-mm@kvack.org>; Thu,  1 May 2014 03:43:07 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id bs8so237980wib.12
        for <linux-mm@kvack.org>; Thu, 01 May 2014 00:43:06 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id ft2si434305wib.35.2014.05.01.00.43.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 May 2014 00:43:03 -0700 (PDT)
Date: Thu, 1 May 2014 09:42:57 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] SCHED: remove proliferation of wait_on_bit action
 functions.
Message-ID: <20140501074257.GK11096@twins.programming.kicks-ass.net>
References: <20140501123738.3e64b2d2@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140501123738.3e64b2d2@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Oleg Nesterov <oleg@redhat.com>, David Howells <dhowells@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, dm-devel@redhat.com, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, Steve French <sfrench@samba.org>, Theodore Ts'o <tytso@mit.edu>, Trond Myklebust <trond.myklebust@primarydata.com>, Ingo Molnar <mingo@redhat.com>, Roland McGrath <roland@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, May 01, 2014 at 12:37:38PM +1000, NeilBrown wrote:
> +static inline int
> +wait_on_bit(void *word, int bit, unsigned mode)
> +{
> +	if (!test_bit(bit, word))
> +		return 0;
> +	return out_of_line_wait_on_bit(word, bit,
> +				       bit_wait,
> +				       mode & 65535);
> +}

Still puzzled by the 16 bit mask there ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
