Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id E0D116B00EF
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 14:06:44 -0400 (EDT)
Message-ID: <5050CF33.4000909@tilera.com>
Date: Wed, 12 Sep 2012 14:06:43 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: Introduce HAVE_ARCH_TRANSPARENT_HUGEPAGE
References: <1347382036-18455-1-git-send-email-will.deacon@arm.com> <1347382036-18455-4-git-send-email-will.deacon@arm.com> <20120912153206.GT21579@dhcp22.suse.cz>
In-Reply-To: <20120912153206.GT21579@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, Steve Capper <steve.capper@arm.com>

On 9/12/2012 11:32 AM, Michal Hocko wrote:
> Makes sense if there are going to be more archs to support THP.

The tile architecture currently supports it in our in-house tree,
though we haven't returned it to the community yet.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
