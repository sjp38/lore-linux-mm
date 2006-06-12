From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH 19/21] swap_prefetch: Conversion of nr_unstable to ZVC
Date: Tue, 13 Jun 2006 09:59:47 +1000
References: <20060612211244.20862.41106.sendpatchset@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0606121647090.22052@schroedinger.engr.sgi.com> <200606130957.28414.kernel@kolivas.org>
In-Reply-To: <200606130957.28414.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606130959.48006.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, Hugh Dickins <hugh@veritas.com>, Marcelo Tosatti <marcelo@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Dave Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 13 June 2006 09:57, Con Kolivas wrote:
> On Tuesday 13 June 2006 09:48, Christoph Lameter wrote:
> > On Tue, 13 Jun 2006, Con Kolivas wrote:
> > > Nack. You're changing some other code unintentionally.
> >
> > Is this okay?
>
> Not quite.
>
> Remove the test_pagestate variable entirely and leave the check something
> like:
>
> 	if (!(sp_stat.prefetched_pages % SWAP_CLUSTER_MAX) &&
> 		above_background_load())
> 			goto out;
>
> Thanks

Oh and

The comment should read something like:
	/*
	 * above_background_load() is expensive so we only perform
	 * it every SWAP_CLUSTER_MAX prefetched_pages.
	 * We test to see if we're above_background_load as disk activity
	 * even at low priority can cause interrupt induced scheduling
	 * latencies.
	 */

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
