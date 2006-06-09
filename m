From: Con Kolivas <kernel@kolivas.org>
Subject: Re: zoned VM stats: nr_slab is accurate, fix comment
Date: Sat, 10 Jun 2006 08:44:29 +1000
References: <Pine.LNX.4.64.0606091122560.520@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0606091122560.520@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606100844.29953.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Saturday 10 June 2006 04:26, Christoph Lameter wrote:
> nr_slab is accurate with the zoned VM stats. Remove the comment
> that states otherwise in swap_prefetch.c

Thanks

> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Acked-by: Con Kolivas <kernel@kolivas.org>

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
