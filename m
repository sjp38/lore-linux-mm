Date: Tue, 9 Jul 2002 09:59:09 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
Message-ID: <20020709095909.C20486@redhat.com>
References: <1048271645.1025997192@[10.10.2.3]> <9820000.1026149363@flay> <3D2A55D0.35C5F523@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D2A55D0.35C5F523@zip.com.au>; from akpm@zip.com.au on Mon, Jul 08, 2002 at 08:17:36PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 08, 2002 at 08:17:36PM -0700, Andrew Morton wrote:
> -D(9)	KM_TYPE_NR
> +D(9)	KM_FILEMAP,
> +D(10)	KM_TYPE_NR

Reusing KM_USER[01] would be better than adding yet another 
kmap type.

		-ben
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
