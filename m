Date: Thu, 26 Jun 2008 10:23:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 5/5] Convert anon_vma spinlock to rw semaphore
In-Reply-To: <20080626010510.GC6938@duo.random>
Message-ID: <Pine.LNX.4.64.0806261019440.7392@schroedinger.engr.sgi.com>
References: <20080626003632.049547282@sgi.com> <20080626003833.966166360@sgi.com>
 <20080626010510.GC6938@duo.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: linux-mm@kvack.org, apw@shadowen.org, Hugh Dickins <hugh@veritas.com>, holt@sgi.com, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 26 Jun 2008, Andrea Arcangeli wrote:

> You dropped the benchmark numbers from the comment, that was useful
> data. You may want to re-run the benchmark on different hardware just
> to be sure it was valid though (just to be sure it's a significant
> regression for AIM).

I could not reproduce it with the recent versions. The degradation was 
less than expected.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
