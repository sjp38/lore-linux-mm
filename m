Date: Tue, 31 Oct 2000 20:13:01 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.4.0-test10-pre6 TLB flush race in establish_pte
Message-ID: <20001031201301.B9227@athlon.random>
References: <C1256989.0066C1B8.00@d12mta01.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <C1256989.0066C1B8.00@d12mta01.de.ibm.com>; from Ulrich.Weigand@de.ibm.com on Tue, Oct 31, 2000 at 07:42:21PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich.Weigand@de.ibm.com
Cc: slpratt@us.ibm.com, linux-kernel@vger.kernel.org, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 31, 2000 at 07:42:21PM +0100, Ulrich.Weigand@de.ibm.com wrote:
> IMO you should apply Steve's patch (without any #ifdef __s390__) now.

Agreed.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
