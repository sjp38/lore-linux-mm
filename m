Received: from flecktone.americas.sgi.com (flecktone.americas.sgi.com [198.149.16.15])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j1G21fxT024424
	for <linux-mm@kvack.org>; Tue, 15 Feb 2005 20:01:41 -0600
Date: Tue, 15 Feb 2005 20:01:38 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: manual page migration -- issue list
Message-ID: <20050216020138.GC28354@lnx-holt.americas.sgi.com>
References: <42128B25.9030206@sgi.com> <20050215165106.61fd4954.pj@sgi.com> <20050215171709.64b155ec.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050215171709.64b155ec.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: raybry@sgi.com, linux-mm@kvack.org, holt@sgi.com, ak@muc.de, haveblue@us.ibm.com, marcello@cyclades.com, stevel@mwwireless.net, peterc@gelato.unsw.edu.au
List-ID: <linux-mm.kvack.org>

On Tue, Feb 15, 2005 at 05:17:09PM -0800, Paul Jackson wrote:
> As a straw man, let me push the factored migration call to the
> extreme, and propose a call:
> 
>   sys_page_migrate(pid, oldnode, newnode)

Go look at the mappings in /proc/<pid>/maps once and you will see
how painful this can make things.  Especially for an applications
with shared mappings.  Overlapping nodes with the above will make
a complete mess of your memory placement.

Robin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
