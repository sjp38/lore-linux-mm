Date: Mon, 24 Feb 2003 15:45:36 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] pte_alloc_kernel needs additional check
Message-ID: <20030224234536.GT10411@holomorphy.com>
References: <1046123680.13919.67.camel@plars> <20030224143341.0b3e1faa.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030224143341.0b3e1faa.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Paul Larson <plars@linuxtestproject.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Paul Larson <plars@linuxtestproject.org> wrote:
-	return pte_offset_kernel(pmd, address);
+	if (pmd_present(*pmd))
+		return pte_offset_kernel(pmd, address);
+	return NULL;

On Mon, Feb 24, 2003 at 02:33:41PM -0800, Andrew Morton wrote:
> Confused.  I cannot see a codepath which makes this test necessary?

Looks like it's OOM handling by analogy with pte_alloc_map().

-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
