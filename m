Message-ID: <3CD8B2CD.DF42503D@zip.com.au>
Date: Tue, 07 May 2002 22:08:29 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: Why *not* rmap, anyway?
References: <Pine.LNX.4.33.0205071625570.1579-100000@erol> <E175Avp-0000Tm-00@starship> <20020507195007.GW15756@holomorphy.com> <E175Dy8-0000U6-00@starship> <20020508000857.GA15756@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Rik van Riel <riel@conectiva.com.br>, Christian Smith <csmith@micromuse.com>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> zap_page_range() has ridiculous latencies.

prefetch in zap_pte_range() would help?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
