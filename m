Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 379506B0031
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 05:16:36 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id y10so3062628wgg.10
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 02:16:35 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gg4si874193wjc.150.2014.01.29.02.16.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Jan 2014 02:16:34 -0800 (PST)
Date: Wed, 29 Jan 2014 10:16:31 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] Other tracks I'm interested in (was Re:
 Persistent memory)
Message-ID: <20140129101631.GC6732@suse.de>
References: <CALCETrV2mtkKCMp6H+5gzoxi9kj9mx0GgsfiXqgn53AikCzFMw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CALCETrV2mtkKCMp6H+5gzoxi9kj9mx0GgsfiXqgn53AikCzFMw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Linux FS Devel <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jan 28, 2014 at 09:30:25AM -0800, Andy Lutomirski wrote:
> On Thu, Jan 16, 2014 at 4:56 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> > I'm interested in a persistent memory track.  There seems to be plenty
> > of other emails about this, but here's my take:
> 
> I should add that I'm also interested in topics relating to the
> performance of mm and page cache under various abusive workloads.
> These include database-like things and large amounts of locked memory.
> 

Out of curiousity, is there any data available on this against a recent
kernel? Locked memory should not cause the kernel to go to hell as the
pages should end up on the unevictable LRU list. If that is not happening,
it could be a bug. More details on the database configuration and test
case would also be welcome as it would help establish if the problem is
a large amount of memory being dirtied and then an fsync destroying the
world or something else.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
