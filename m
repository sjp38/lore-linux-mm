From: Andi Kleen <ak@suse.de>
Subject: Re: mempolicies: fix policy_zone check
Date: Sat, 5 Aug 2006 03:49:49 +0200
References: <Pine.LNX.4.64.0608041646550.5573@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608041646550.5573@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200608050349.49114.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Saturday 05 August 2006 01:54, Christoph Lameter wrote:

> So move the highest_zone() function from mm/page_alloc.c into
> include/linux/gfp.h.  On the way we simplify the function and use the new
> zone_type that was also introduced with the zone reduction patchset plus we
> also specify the right type for the gfp flags parameter.

The function is a bit big to inline. Better keep it in page_alloc.c, but
make it global.

Other than that it looks ok.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
