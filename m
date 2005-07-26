Date: Tue, 26 Jul 2005 16:59:57 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: Memory pressure handling with iSCSI
In-Reply-To: <1122399331.6433.29.camel@dyn9047017102.beaverton.ibm.com>
Message-ID: <Pine.LNX.4.61.0507261659250.1786@chimarrao.boston.redhat.com>
References: <1122399331.6433.29.camel@dyn9047017102.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.61.0507261659252.1786@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jul 2005, Badari Pulavarty wrote:

> After KS & OLS discussions about memory pressure, I wanted to re-do
> iSCSI testing with "dd"s to see if we are throttling writes.  

Could you also try with shared writable mmap, to see if that
works ok or triggers a deadlock ?

-- 
The Theory of Escalating Commitment: "The cost of continuing mistakes is
borne by others, while the cost of admitting mistakes is borne by yourself."
  -- Joseph Stiglitz, Nobel Laureate in Economics
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
