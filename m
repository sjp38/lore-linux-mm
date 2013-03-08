Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 150EB6B0006
	for <linux-mm@kvack.org>; Fri,  8 Mar 2013 03:40:20 -0500 (EST)
Date: Fri, 8 Mar 2013 10:42:46 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mmap vs fs cache
Message-ID: <20130308084246.GA4411@shutemov.name>
References: <5136320E.8030109@symas.com>
 <20130307154312.GG6723@quack.suse.cz>
 <20130308020854.GC23767@cmpxchg.org>
 <5139975F.9070509@symas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5139975F.9070509@symas.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Howard Chu <hyc@symas.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, Mar 07, 2013 at 11:46:39PM -0800, Howard Chu wrote:
> You're misreading the information then. slapd is doing no caching of
> its own, its RSS and SHR memory size are both the same. All it is
> using is the mmap, nothing else. The RSS == SHR == FS cache, up to
> 16GB. RSS is always == SHR, but above 16GB they grow more slowly
> than the FS cache.

It only means, that some pages got unmapped from your process. It can
happned, for instance, due page migration. There's nothing worry about: it
will be mapped back on next page fault to the page and it's only minor
page fault since the page is in pagecache anyway.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
