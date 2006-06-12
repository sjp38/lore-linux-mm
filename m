From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH 08/21] swap_prefetch: Split NR_ANON off NR_MAPPED
Date: Tue, 13 Jun 2006 09:36:46 +1000
References: <20060612211244.20862.41106.sendpatchset@schroedinger.engr.sgi.com> <20060612211326.20862.28655.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060612211326.20862.28655.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606130936.46969.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, Hugh Dickins <hugh@veritas.com>, Marcelo Tosatti <marcelo@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Dave Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 13 June 2006 07:13, Christoph Lameter wrote:
> swap_prefetch: add NR_ANON
>
> Separated out by request from Andrew.
>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Acked-by: Con Kolivas <kernel@kolivas.org>

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
