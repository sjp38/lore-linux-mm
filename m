Received: from flecktone.americas.sgi.com (flecktone.americas.sgi.com [198.149.16.15])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j1GG8dxT004636
	for <linux-mm@kvack.org>; Wed, 16 Feb 2005 10:08:39 -0600
Date: Wed, 16 Feb 2005 10:08:23 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: manual page migration -- issue list
Message-ID: <20050216160823.GA10620@lnx-holt.americas.sgi.com>
References: <42128B25.9030206@sgi.com> <20050215165106.61fd4954.pj@sgi.com> <20050216015622.GB28354@lnx-holt.americas.sgi.com> <20050215202214.4b833bf3.pj@sgi.com> <20050216092011.GA6616@lnx-holt.americas.sgi.com> <20050216022009.7afb2e6d.pj@sgi.com> <20050216113047.GA8388@lnx-holt.americas.sgi.com> <20050216074550.313b1300.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050216074550.313b1300.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Robin Holt <holt@sgi.com>, raybry@sgi.com, linux-mm@kvack.org, ak@muc.de, haveblue@us.ibm.com, marcello@cyclades.com, stevel@mwwireless.net, peterc@gelato.unsw.edu.au
List-ID: <linux-mm.kvack.org>

On Wed, Feb 16, 2005 at 07:45:50AM -0800, Paul Jackson wrote:
> Hmmm ... wait just a minute ... isn't parsing the maps files in /proc
> really scanning the virtual addresses of tasks.  In your example of a
> few hours ago, which seemed to only require 3 system calls and one full
> scan of any task address space, did you read all the /proc/*/maps files,
> for all 256 of the tasks involved?  I would think you would have to have

Reading /proc/<pid>maps just scans through the vmas and not the
address space.  Very different things!

> Could you redo your example, including scans implied by reading maps
> files, and including system calls needed to do those reads, and needed
> to migrate any private pages they might have?  Perhaps your preferred
> API doesn't have such an insane advantage after all.

Ray, do you have your userland stuff in anywhere close to presentable
condition?  If so, that might be the best for this part of the discussion.

Robin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
