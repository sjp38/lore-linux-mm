Date: Thu, 22 Jun 2006 10:19:56 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 00/14] Zoned VM counters V6
Message-Id: <20060622101956.0bf6941f.akpm@osdl.org>
In-Reply-To: <20060622164004.28809.8446.sendpatchset@schroedinger.engr.sgi.com>
References: <20060622164004.28809.8446.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jun 2006 09:40:04 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> V5->V6
> - Restore the removal of individual counters from the page state that
>   was deferred into a later patch when going from V2->V3. This also
>   caused the removal of get_page_state_node and get_page_state() to
>   drop out of the patch that converted nr_unstable.

argh.  I'm happy with the patches I have now - they compile at each step
and the machine doesn't hang.

> - Fix mailing list address.

A single patch for this would be good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
