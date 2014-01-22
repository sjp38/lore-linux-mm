Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id B9B596B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 00:20:57 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id hr1so5230726wib.14
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 21:20:57 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id mg5si5370044wic.40.2014.01.21.21.20.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 21:20:56 -0800 (PST)
Date: Wed, 22 Jan 2014 05:20:53 +0000
From: Joel Becker <jlbec@evilplan.org>
Subject: Re: [LSF/MM TOPIC] really large storage sectors - going beyond 4096
 bytes
Message-ID: <20140122052052.GM10565@ZenIV.linux.org.uk>
References: <20131220093022.GV11295@suse.de>
 <52DF353D.6050300@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52DF353D.6050300@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Wheeler <rwheeler@redhat.com>
Cc: linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, linux-kernel@vger.kernel.org

On Tue, Jan 21, 2014 at 10:04:29PM -0500, Ric Wheeler wrote:
> One topic that has been lurking forever at the edges is the current
> 4k limitation for file system block sizes. Some devices in
> production today and others coming soon have larger sectors and it
> would be interesting to see if it is time to poke at this topic
> again.
> 
> LSF/MM seems to be pretty much the only event of the year that most
> of the key people will be present, so should be a great topic for a
> joint session.

Oh yes, I want in on this.  We handle 4k/16k/64k pages "seamlessly," and
we would want to do the same for larger sectors.  In theory, our code
should handle it with the appropriate defines updated.

Joel

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
