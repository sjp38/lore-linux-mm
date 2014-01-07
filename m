Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id EC3B56B0031
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 14:43:04 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id en1so4611643wid.5
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 11:43:04 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id n5si1491720wiv.69.2014.01.07.11.43.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 11:43:04 -0800 (PST)
Date: Tue, 7 Jan 2014 11:42:54 -0800
From: Joel Becker <jlbec@evilplan.org>
Subject: Re: [LSF/MM ATTEND] testing.
Message-ID: <20140107194254.GM5272@localhost>
References: <20140103141020.GA12846@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140103141020.GA12846@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Fri, Jan 03, 2014 at 09:10:20AM -0500, Dave Jones wrote:
> My recent enhancements to trinity have turned up a whole bunch of VM bugs
> (mostly involving huge-pages), many of which have been there for years
> without anyone tripping over them.
> 
> I'm interesting in attending LSF/MM summit to get more feedback on other
> mm/vfs areas that could use more attention from targetted testing like this.

Yeah, I've seen Trinity turn up some cool things.  It would be neat to
try and grow beyond basic xfstest stuff.  Perhaps shape them
differently.

Joel


-- 

Life's Little Instruction Book #306

	"Take a nap on Sunday afternoons."

			http://www.jlbec.org/
			jlbec@evilplan.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
