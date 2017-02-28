Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C678D6B0393
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 05:12:18 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c143so3913201wmd.2
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 02:12:18 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id r186si2245869wmd.5.2017.02.28.02.12.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 02:12:17 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id m70so1533568wma.1
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 02:12:17 -0800 (PST)
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] do we really need PG_error at all?
References: <1488120164.2948.4.camel@redhat.com>
 <1488129033.4157.8.camel@HansenPartnership.com>
 <877f4cr7ew.fsf@notabene.neil.brown.name>
 <1488151856.4157.50.camel@HansenPartnership.com>
 <874lzgqy06.fsf@notabene.neil.brown.name>
 <1488208047.2876.6.camel@redhat.com>
 <DC27F5BA-BCCA-41FF-8D41-7BB99AA4DB26@dilger.ca>
 <87varvp5v1.fsf@notabene.neil.brown.name>
 <1488244308.7627.5.camel@redhat.com>
From: Boaz Harrosh <openosd@gmail.com>
Message-ID: <0bea2b1c-ddb1-f2bf-8ef7-b83d6a6404fc@gmail.com>
Date: Tue, 28 Feb 2017 12:12:14 +0200
MIME-Version: 1.0
In-Reply-To: <1488244308.7627.5.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>, NeilBrown <neilb@suse.com>, Andreas Dilger <adilger@dilger.ca>
Cc: linux-block@vger.kernel.org, linux-scsi <linux-scsi@vger.kernel.org>, lsf-pc <lsf-pc@lists.linuxfoundation.org>, Neil Brown <neilb@suse.de>, LKML <linux-kernel@vger.kernel.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 02/28/2017 03:11 AM, Jeff Layton wrote:
<>
> 
> I'll probably have questions about the read side as well, but for now it
> looks like it's mostly used in an ad-hoc way to communicate errors
> across subsystems (block to fs layer, for instance).

If memory does not fail me it used to be checked long time ago in the
read-ahead case. On the buffered read case, the first page is read synchronous
and any error is returned to the caller, but then a read-ahead chunk is
read async all the while the original thread returned to the application.
So any errors are only recorded on the page-bit, since otherwise the uptodate
is off and the IO will be retransmitted. Then the move to read_iter changed
all that I think.
But again this is like 5-6 years ago, and maybe I didn't even understand
very well.

> --
> Jeff Layton <jlayton@redhat.com>
> 

I would like a Documentation of all this as well please. Where are the
tests for this?

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
