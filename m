Date: Thu, 25 Jan 2001 18:16:21 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: limit on number of kmapped pages
Message-ID: <20010125181621.W11607@redhat.com>
References: <y7rsnmav0cv.fsf@sytry.doc.ic.ac.uk> <m1r91udt59.fsf@frodo.biederman.org> <y7rofwxeqin.fsf@sytry.doc.ic.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <y7rofwxeqin.fsf@sytry.doc.ic.ac.uk>; from dpw@doc.ic.ac.uk on Wed, Jan 24, 2001 at 12:35:12AM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Wragg <dpw@doc.ic.ac.uk>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jan 24, 2001 at 12:35:12AM +0000, David Wragg wrote:
> 
> > And why do the pages need to be kmapped? 
> 
> They only need to be kmapped while data is being copied into them.

But you only need to kmap one page at a time during the copy.  There
is absolutely no need to copy the whole chunk at once.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
