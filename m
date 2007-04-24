Date: Mon, 23 Apr 2007 20:08:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
Message-Id: <20070423200859.e2e9ab3d.akpm@linux-foundation.org>
In-Reply-To: <462D713D.6050401@redhat.com>
References: <46247427.6000902@redhat.com>
	<20070420135715.f6e8e091.akpm@linux-foundation.org>
	<462932BE.4020005@redhat.com>
	<20070420150618.179d31a4.akpm@linux-foundation.org>
	<4629524C.5040302@redhat.com>
	<462ACA40.8070407@yahoo.com.au>
	<462B0156.9020407@redhat.com>
	<462BFAF3.4040509@yahoo.com.au>
	<462C2DC7.5070709@redhat.com>
	<462C2F33.8090508@redhat.com>
	<462C7A6F.9030905@redhat.com>
	<462C88B1.8080906@yahoo.com.au>
	<462C8B0A.8060801@redhat.com>
	<462C8BFF.2050405@yahoo.com.au>
	<462D713D.6050401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shak <dshaks@redhat.com>, jakub@redhat.com, drepper@redhat.com
List-ID: <linux-mm.kvack.org>

On Mon, 23 Apr 2007 22:53:49 -0400 Rik van Riel <riel@redhat.com> wrote:

> I don't see why we need the attached, but in case you find
> a good reason, here's my signed-off-by line for Andrew :)

Andew is in a defensive crouch trying to work his way through all the bugs
he's been sent.  After I've managed to release 2.6.21-rc7-mm1 (say, December)
I expect I'll drop the MADV_FREE stuff, give you a run at creating a new
patch series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
