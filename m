Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AF4956B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 05:39:33 -0400 (EDT)
Date: Tue, 7 Jul 2009 06:19:46 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] bump up nr_to_write in xfs_vm_writepage
Message-ID: <20090707101946.GB1934@infradead.org>
References: <4A4D26C5.9070606@redhat.com> <bzyd48cc14d.fsf@fransum.emea.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bzyd48cc14d.fsf@fransum.emea.sgi.com>
Sender: owner-linux-mm@kvack.org
To: Olaf Weber <olaf@sgi.com>
Cc: Eric Sandeen <sandeen@redhat.com>, xfs mailing list <xfs@oss.sgi.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, "MASON, CHRISTOPHER" <CHRIS.MASON@oracle.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 07, 2009 at 11:07:30AM +0200, Olaf Weber wrote:
> If the nr_to_write calculation really yields a value that is too
> small, shouldn't it be fixed elsewhere?

In theory it should.  But given the amazing feedback of the VM people
on this I'd rather make sure we do get the full HW bandwith on large
arrays instead of sucking badly and not just wait forever.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
