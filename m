Date: Wed, 17 Oct 2001 21:58:18 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: Under what conditions are VMAs merged?
Message-ID: <20011017215818.A2804@redhat.com>
References: <3BCE20DF.6090103@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3BCE20DF.6090103@zytor.com>; from hpa@zytor.com on Wed, Oct 17, 2001 at 05:22:55PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On Wed, Oct 17, 2001 at 05:22:55PM -0700, H. Peter Anvin wrote:
> In the checkpoint routine I thought doing an mprotect(PROT_READ) on the
> entire region as a single system call would coalesce the VMAs, but
> apparently that is not the case; after running my standard stress-test
> application, /proc/pid/maps show 51635 mappings, most of them contiguous
> and otherwise matching the surrounding mappings in every way; a dump of

Only anonymous vmas are candidates for merging.  Take it up with the head 
penguin.  No merging at all is done for shared vmas.

		-ben
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
