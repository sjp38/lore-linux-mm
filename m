Date: Wed, 28 Jun 2000 19:06:12 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: kmap_kiobuf()
Message-ID: <20000628190612.E2392@redhat.com>
References: <200006281652.LAA19162@jen.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200006281652.LAA19162@jen.americas.sgi.com>; from lord@sgi.com on Wed, Jun 28, 2000 at 11:52:40AM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lord@sgi.com
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, David Woodhouse <dwmw2@infradead.org>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 28, 2000 at 11:52:40AM -0500, lord@sgi.com wrote:
> 
> I am not a VM guy either, Ben, is the cost of the TLB flush mostly in
> the synchronization between CPUs, or is it just expensive anyway you
> look at it?

The TLB IPI is by far the biggest factor here.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
