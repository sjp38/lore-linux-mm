From: brian@worldcontrol.com
Date: Thu, 20 Sep 2001 12:56:16 -0700
Subject: Re: Process not given >890MB on a 4MB machine ?????????
Message-ID: <20010920125616.A14985@top.worldcontrol.com>
References: <5D2F375D116BD111844C00609763076E050D164D@exch-staff1.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5D2F375D116BD111844C00609763076E050D164D@exch-staff1.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Gabriel.Leen" <Gabriel.Leen@ul.ie>
Cc: "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 20, 2001 at 08:25:37PM +0100, Gabriel.Leen wrote:
> Hello,
> The problem in a nutshell is:
> 
> a) I have a 4GB ram 1.7Gh Xeon box
> b) I'm running a process which requires around 3GB of ram
> c) RedHat 2.4.9 will only give it 890MB, then core dumps with the warning
> "segmentation fault"
> when it reaches this memory usage and "asks for more"

That is exacly what I've seen.

The limit I ran into was in glibc.  My code used malloc, and apparently
some versions of malloc in glibc try "harder" than others to allocate
memory.  Check your version of glibc and try a later one if available.



-- 
Brian Litzinger <brian@worldcontrol.com>

    Copyright (c) 2000 By Brian Litzinger, All Rights Reserved
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
