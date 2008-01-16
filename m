Subject: Re: [PATCH 00/10] x86: Reduce memory and intra-node effects with large count NR_CPUs V3
In-reply-To: <20080116170902.006151000@sgi.com>
References: <20080116170902.006151000@sgi.com>
Message-Id: <E1JFCZo-000618-8r@faramir.fjphome.nl>
From: Frans Pop <elendil@planet.nl>
Date: Wed, 16 Jan 2008 19:01:24 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: ak@suse.de, akpm@linux-foundation.org, clameter@sgi.com, dada1@cosmosbay.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

travis@sgi.com wrote:
>    8472457 Total          30486950 +259%          30342823 +258%

Hmmm. The table for previous versions looked a lot more impressive.

now:    8472457 Total	 +22014493 +259%	 +21870366 +258%
V2 :    7172678 Total    +23314404 +325%           -147590   -2%
(recalculated for comparison)

Did something go wrong with the "after" data?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
