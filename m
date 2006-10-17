Date: Mon, 16 Oct 2006 18:10:20 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Page allocator: Single Zone optimizations
Message-Id: <20061016181020.7fbd9915.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Oct 2006 17:50:26 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> The current code in 2.6.19-rc1-mm1 already allows the configuration of a 
> system with a single zone. We observed significant performance gains which 
> were likely due to the reduced cache footprint (removal of the zone_table 
> also contributed).
> 
> This patch continues that line of work making the zone protection logic 
> optional throwing out moreVM overhead that is not needed in the single 
> zone case (which hopefully in the far future most of us will be able to 
> use).
> 
> Also several macros can become constant if we know that only
> a single zone exists (ZONES_SHIFT == 0) which will remove more code
> from the VM and avoid runtime branching.

akpm:/home/akpm> grep '^+#if' x
+#if ZONES_SHIFT > 0
+#if ZONES_SHIFT > 0
+#if ZONES_SHIFT == 0
+#if ZONES_SHIFT > 0
+#if ZONES_SHIFT > 0
+#if ZONES_SHIFT > 0
+#if ZONES_SHIFT > 0
+#if ZONES_SHIFT > 0
+#if ZONES_SHIFT > 0
+#if ZONES_SHIFT > 0
+#if ZONES_SHIFT > 0
+#if ZONES_SHIFT > 0
+#if ZONES_SHIFT > 0

Now that just goes too far.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
