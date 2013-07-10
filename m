Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 9685A6B0034
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 22:00:25 -0400 (EDT)
Date: Tue, 9 Jul 2013 21:59:36 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [REGRESSION] x86 vmalloc issue from recent 3.10.0+ commit
Message-ID: <20130710015936.GC13855@redhat.com>
References: <51DCBE24.3030406@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51DCBE24.3030406@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael L. Semon" <mlsemon35@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, d.hatayama@jp.fujitsu.com, akpm@linux-foundation.org

On Tue, Jul 09, 2013 at 09:51:32PM -0400, Michael L. Semon wrote:

 > kernel: [ 2580.395592] vmap allocation for size 20480 failed: use vmalloc=<size> to increase size.
 > kernel: [ 2580.395761] vmalloc: allocation failure: 16384 bytes

I was seeing a lot of these recently too.
(Though I also saw memory corruption afterwards possibly caused by
 a broken fallback path somewhere when that vmalloc fails)

http://comments.gmane.org/gmane.linux.kernel.mm/102895

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
