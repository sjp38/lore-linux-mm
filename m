Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1ADD46B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 10:44:54 -0400 (EDT)
Date: Tue, 7 Jul 2009 10:46:01 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] bump up nr_to_write in xfs_vm_writepage
Message-ID: <20090707144601.GA705@infradead.org>
References: <4A4D26C5.9070606@redhat.com> <bzyd48cc14d.fsf@fransum.emea.sgi.com> <20090707101946.GB1934@infradead.org> <bzy8wj0bu72.fsf@fransum.emea.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bzy8wj0bu72.fsf@fransum.emea.sgi.com>
Sender: owner-linux-mm@kvack.org
To: Olaf Weber <olaf@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, Eric Sandeen <sandeen@redhat.com>, linux-mm@kvack.org, "MASON, CHRISTOPHER" <CHRIS.MASON@oracle.com>, xfs mailing list <xfs@oss.sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 07, 2009 at 01:37:05PM +0200, Olaf Weber wrote:
> > In theory it should.  But given the amazing feedback of the VM people
> > on this I'd rather make sure we do get the full HW bandwith on large
> > arrays instead of sucking badly and not just wait forever.
> 
> So how do you feel about making the fudge factor tunable?  I don't
> have a good sense myself of what the value should be, whether the
> hard-coded 4 is good enough in general.

A tunable means exposing an ABI, which I'd rather not do for a hack like
this.  If you don't like the number feel free to experiment around with
it, SGI should have enough large systems that can be used to test this
out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
