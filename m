Received: from inet-mail1.oracle.com (localhost [127.0.0.1])
	by inet-mail1.oracle.com (Switch-2.2.6/Switch-2.2.5) with ESMTP id h3EHoIg09453
	for <linux-mm@kvack.org>; Mon, 14 Apr 2003 10:50:18 -0700 (PDT)
Received: from rgmgw6.us.oracle.com (rgmgw6.us.oracle.com [138.1.191.15])
	by inet-mail1.oracle.com (Switch-2.2.6/Switch-2.2.5) with ESMTP id h3EHoHA09432
	for <linux-mm@kvack.org>; Mon, 14 Apr 2003 10:50:17 -0700 (PDT)
Received: from rgmgw6.us.oracle.com (localhost [127.0.0.1])
	by rgmgw6.us.oracle.com (Switch-2.1.5/Switch-2.1.0) with ESMTP id h3EHoAu13190
	for <linux-mm@kvack.org>; Mon, 14 Apr 2003 11:50:12 -0600 (MDT)
Received: from rgmum1.us.oracle.com (rgmum1.us.oracle.com [138.1.191.22])
	by rgmgw6.us.oracle.com (Switch-2.1.5/Switch-2.1.0) with ESMTP id h3EHnwZ12604
	for <linux-mm@kvack.org>; Mon, 14 Apr 2003 11:49:59 -0600 (MDT)
Date: Mon, 14 Apr 2003 10:48:18 -0700
From: Joel Becker <Joel.Becker@oracle.com>
Subject: Re: 2.5.67-mm2
Message-ID: <20030414174818.GR4917@ca-server1.us.oracle.com>
References: <20030412180852.77b6c5e8.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030412180852.77b6c5e8.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 12, 2003 at 06:08:52PM -0700, Andrew Morton wrote:
> . I've changed the 32-bit dev_t patch to provide a 12:20 split rather than
>   16:16.  This patch is starting to drag a bit and unless someone stops me I
>   might just go submit the thing.

	Cool, but before you go off and push, maybe kick the appropriate
folks about making the 32/64 decision?

Joel

-- 

"When choosing between two evils, I always like to try the one
 I've never tried before."
        - Mae West

Joel Becker
Senior Member of Technical Staff
Oracle Corporation
E-mail: joel.becker@oracle.com
Phone: (650) 506-8127
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
