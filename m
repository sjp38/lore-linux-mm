From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/2] Relax restrictions on setting CONFIG_NUMA on x86 II
Date: Wed, 23 Jan 2008 12:15:56 +0100
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie> <200801231145.14915.andi@firstfloor.org> <20080123105757.GE21455@csn.ul.ie>
In-Reply-To: <20080123105757.GE21455@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200801231215.56741.andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Anyways from your earlier comments it sounds like you're trying to add SRAT 
parsing to CONFIG_NUMAQ. Since that's redundant with the old implementation
it doesn't sound like a very useful thing to do.

But the patch is applied already i think. Well I'm sure it passed 
checkpatch.pl at least.

-Andi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
