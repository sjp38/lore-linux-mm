Date: Mon, 8 Sep 2003 11:39:36 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Differences between VM structs
Message-ID: <20030908183936.GI29479@holomorphy.com>
References: <3F5CADD3.2070404@movaris.com> <20030908182138.GH29479@holomorphy.com> <Pine.GSO.4.51.0309081425350.25054@aria.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.51.0309081425350.25054@aria.ncl.cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Raghu R. Arur" <rra2002@aria.ncl.cs.columbia.edu>
Cc: Kirk True <ktrue@movaris.com>, Linux Memory Manager List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

At some point in the past, I wrote:
>> mmap() needed very few extensions to handle the anonymous case.

On Mon, Sep 08, 2003 at 02:26:50PM -0400, Raghu R. Arur wrote:
>  What are these extensions in mmap() that need to handle anonymous pages??
>  Thanks a lot,
>  Raghu

MAP_ANONYMOUS.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
