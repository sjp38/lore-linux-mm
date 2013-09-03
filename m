Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 8408E6B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 19:06:15 -0400 (EDT)
Date: Tue, 3 Sep 2013 19:06:11 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: The scan_unevictable_pages sysctl/node-interface has been
 disabled
Message-ID: <20130903230611.GE1412@cmpxchg.org>
References: <CANkm-FgvMU-e0uxSvdV1+T5CbEdTCrj=2LVYnVEOALF8myoMxw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANkm-FgvMU-e0uxSvdV1+T5CbEdTCrj=2LVYnVEOALF8myoMxw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander R <aleromex@gmail.com>
Cc: linux-mm@kvack.org

On Tue, Sep 03, 2013 at 11:53:24PM +0400, Alexander R wrote:
> [2000266.127978] nr_pdflush_threads exported in /proc is scheduled for
> removal
> [2000266.128022] sysctl: The scan_unevictable_pages sysctl/node-interface
> has been disabled for lack of a legitimate use case.  If you have one,
> please send an email to linux-mm@kvack.org.

Well, do you have one? :-)

Or is this just leftover in a script somewhere?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
