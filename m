Subject: Re: [PATCH] mm/filemap.c: unconditionally call mark_page_accessed
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca>
References: <Pine.GSO.4.64.0703081612290.1080@cpu102.cs.uwaterloo.ca>
	 <20070312142012.GH30777@atrey.karlin.mff.cuni.cz>
	 <20070312143900.GB6016@wotan.suse.de> <20070312151355.GB23532@duck.suse.cz>
	 <Pine.GSO.4.64.0703121247210.7679@cpu102.cs.uwaterloo.ca>
	 <20070312173500.GF23532@duck.suse.cz>
	 <Pine.GSO.4.64.0703131438580.8193@cpu102.cs.uwaterloo.ca>
	 <20070313185554.GA5105@duck.suse.cz>
	 <Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca>
Content-Type: text/plain
Date: Thu, 15 Mar 2007 11:39:14 +0100
Message-Id: <1173955154.25356.28.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ashif Harji <asharji@cs.uwaterloo.ca>
Cc: linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-03-14 at 15:58 -0400, Ashif Harji wrote:
> This patch unconditionally calls mark_page_accessed to prevent pages, 
> especially for small files, from being evicted from the page cache despite 
> frequent access.

Since we're hackling over the use-once stuff again...

/me brings up: http://marc.info/?l=linux-mm&m=115316894804385&w=2 and
ducks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
