Date: Wed, 10 May 2006 16:04:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mm: cleanup swap unused warning
In-Reply-To: <200605102132.41217.kernel@kolivas.org>
Message-ID: <Pine.LNX.4.64.0605101604330.7472@schroedinger.engr.sgi.com>
References: <200605102132.41217.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: linux list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Wed, 10 May 2006, Con Kolivas wrote:

> Are there any users of swp_entry_t when CONFIG_SWAP is not defined?

Yes, a migration entry is a form of swap entry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
