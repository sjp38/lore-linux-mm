Date: Tue, 23 Jul 2002 20:27:41 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [RFC][PATCH] extended VM stats
Message-ID: <20020723202741.D27897@redhat.com>
References: <Pine.LNX.4.44L.0207151835120.12241-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L.0207151835120.12241-100000@imladris.surriel.com>; from riel@conectiva.com.br on Mon, Jul 15, 2002 at 07:00:54PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Jul 15, 2002 at 07:00:54PM -0300, Rik van Riel wrote:

> the patch below (against 2.5.25 + minimal rmap) implements a
> number of extra VM statistics, which should help us a lot in
> finetuning the VM for 2.6.

I'd love to see these available per-zone.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
