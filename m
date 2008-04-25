Date: Fri, 25 Apr 2008 19:55:03 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 05/18] hugetlb: multiple hstates
Message-ID: <20080425175503.GG3265@one.firstfloor.org>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.162027000@nick.local0.net> <20080425173827.GC9680@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080425173827.GC9680@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

> Unnecessary initializations (and whitespace)?

Actually gcc generates exactly the same code for 0 and no initialization.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
