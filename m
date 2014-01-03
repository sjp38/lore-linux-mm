From: Dave Hansen <dave@sr71.net>
Subject: Re: [RFC PATCHv3 00/11] Intermix Lowmem and vmalloc
Date: Fri, 03 Jan 2014 10:23:32 -0800
Message-ID: <52C70024.1060605@sr71.net>
References: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Laura Abbott <lauraa@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Kyungmin Park <kmpark@infradead.org>, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On 01/02/2014 01:53 PM, Laura Abbott wrote:
> The goal here is to allow as much lowmem to be mapped as if the block of memory
> was not reserved from the physical lowmem region. Previously, we had been
> hacking up the direct virt <-> phys translation to ignore a large region of
> memory. This did not scale for multiple holes of memory however.

How much lowmem do these holes end up eating up in practice, ballpark?
I'm curious how painful this is going to get.
