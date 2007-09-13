Date: Wed, 12 Sep 2007 17:26:59 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 07 of 24] balance_pgdat doesn't return the number of
 pages freed
In-Reply-To: <20070912051858.76a69996.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0709121724280.4489@schroedinger.engr.sgi.com>
References: <patchbomb.1187786927@v2.random> <b66d8470c04ed836787f.1187786934@v2.random>
 <20070912051858.76a69996.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007, Andrew Morton wrote:

> I'll skip this due to its dependency on
> [PATCH 06 of 24] reduce the probability of an OOM livelock

The return value of balance_pgdat() is never used independently of the 
prior patch.

The only user of balance_pgdat() is kswapd():


	finish_wait(&pgdat->kswapd_wait, &wait);
           if (!try_to_freeze()) {
                        /* We can speed up thawing tasks if we don't call
                         * balance_pgdat after returning from the refrigerator
                         */
                        balance_pgdat(pgdat, order);
          }
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
