Date: Tue, 26 Jul 2005 12:12:50 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Memory pressure handling with iSCSI
Message-Id: <20050726121250.0ba7d744.akpm@osdl.org>
In-Reply-To: <20050726114824.136d3dad.akpm@osdl.org>
References: <1122399331.6433.29.camel@dyn9047017102.beaverton.ibm.com>
	<20050726111110.6b9db241.akpm@osdl.org>
	<1122403152.6433.39.camel@dyn9047017102.beaverton.ibm.com>
	<20050726114824.136d3dad.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pbadari@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@osdl.org> wrote:
>
> Can you please reduce the number of filesystems, see if that reduces the
>  dirty levels?

Also, it's conceivable that ext3 is implicated here, so it might be saner
to perform initial investigation on ext2.

(when kjournald writes back a page via its buffers, the page remains
"dirty" as far as the VFS is concerned.  Later, someone tries to do a
writepage() on it and we'll discover the buffers' cleanness and the page
will be cleaned without any I/O being performed.  All the throttling
_should_ work OK in this case.  But ext2 is more straightforward.)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
