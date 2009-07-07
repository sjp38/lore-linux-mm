Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E571C6B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 07:37:01 -0400 (EDT)
Subject: Re: [PATCH] bump up nr_to_write in xfs_vm_writepage
References: <4A4D26C5.9070606@redhat.com>
	<bzyd48cc14d.fsf@fransum.emea.sgi.com>
	<20090707101946.GB1934@infradead.org>
From: Olaf Weber <olaf@sgi.com>
Date: Tue, 07 Jul 2009 13:37:05 +0200
In-Reply-To: <20090707101946.GB1934@infradead.org> (Christoph Hellwig's message of "Tue, 7 Jul 2009 06:19:46 -0400")
Message-ID: <bzy8wj0bu72.fsf@fransum.emea.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Eric Sandeen <sandeen@redhat.com>, linux-mm@kvack.org, "MASON, CHRISTOPHER" <CHRIS.MASON@oracle.com>, xfs mailing list <xfs@oss.sgi.com>
List-ID: <linux-mm.kvack.org>

Christoph Hellwig writes:
> On Tue, Jul 07, 2009 at 11:07:30AM +0200, Olaf Weber wrote:

>> If the nr_to_write calculation really yields a value that is too
>> small, shouldn't it be fixed elsewhere?

> In theory it should.  But given the amazing feedback of the VM people
> on this I'd rather make sure we do get the full HW bandwith on large
> arrays instead of sucking badly and not just wait forever.

So how do you feel about making the fudge factor tunable?  I don't
have a good sense myself of what the value should be, whether the
hard-coded 4 is good enough in general.

-- 
Olaf Weber                 SGI               Phone:  +31(0)30-6696752
                           Veldzigt 2b       Fax:    +31(0)30-6696799
Technical Lead             3454 PW de Meern  Vnet:   955-7151
Storage Software           The Netherlands   Email:  olaf@sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
